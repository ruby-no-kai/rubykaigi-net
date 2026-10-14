#!/usr/bin/env ruby
# Keeps an interactive SSH session to a network device in a background daemon, so a coding agent can run one
# command per invocation. Output is redacted with glazed dialect patterns before it leaves the daemon.
#
# Setup: (cd glazed && bundle install)
# Usage: ruby misc/ssh_cli.rb --help
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../glazed/Gemfile', __dir__)
require 'bundler/setup'

require 'fileutils'
require 'io/console'
require 'json'
require 'optparse'
require 'pty'
require 'securerandom'
require 'socket'

require 'glazed/dialects'
require 'glazed/redactor'

module SshCli
  STATE_DIR = File.expand_path('../tmp/ssh-cli', __dir__)

  GENERIC_PROMPT = /[>#$%]\s?\z/
  # Prompts waiting for the agent rather than the device, such as passwords and host key confirmations.
  INTERACTIVE_PROMPT = /(?:password|passphrase[^:]*|username|user|login):\s*\z|\((?:yes\/no)[^)]*\)\?\s*\z|\[y\/n\]\s*\z/i
  PAGER = /---\(more(?: \d+%)?\)---|<--- More --->|-- ?More ?--/
  ANSI = /\e\[[0-9;?]*[ -\/]*[@-~]|\e[()][0-9A-Za-z]|\e[=>78]/
  SETTLE = 0.3

  USAGE = <<~EOS
    Usage: #{$0} [-s NAME] <command> [options]

    Commands:
      open --dialect DIALECT [--prompt RE] [--mask-env VAR]... [--timeout SEC] -- <ssh args...>
          Start a session; prints the banner up to the first prompt.
          DIALECT is a glazed dialect (junos, nec_ix, wlc, ios, awplus) and picks the prompt and secret patterns.
      run [--prompt RE] [--timeout SEC] COMMAND
          Run COMMAND and print its output, without the echo and the trailing prompt.
      send [--no-newline] [--ctrl KEY] [--secret-env VAR | --secret-ssm NAME] [--timeout SEC] [TEXT]
          Type raw input, such as an answer to a confirmation or ^C (--ctrl c).
          --secret-* types a secret without it passing through argv or output; it is masked from then on.
      wait [--until RE] [--timeout SEC]
          Wait for a prompt (or RE) and print output that arrived since the last command.
      read [--tail N]
          Print the last N lines (default 50) of the session.
      list
          List sessions.
      close [--all]
          End the session.

    Options:
      -s NAME   session name (default: default)

    Exit status: 0 ok, 1 timed out (output may be partial), 2 no such session or session closed.
    Secrets located by the dialect appear as [~REDACTED:dgst=...~], with a digest that is stable within a session.
  EOS

  class Error < StandardError; end

  def self.socket_path(name) = File.join(STATE_DIR, "#{name}.sock")
  def self.pid_path(name) = File.join(STATE_DIR, "#{name}.pid")
  def self.log_path(name) = File.join(STATE_DIR, "#{name}.log")

  def self.literal_pattern(value, note:)
    Glazed::Dialect::SensitivePattern.new(pattern: Regexp.new(Regexp.escape(value)), determiner: ->(m) { m.begin(0)...m.end(0) }, note:)
  end

  # Turns terminal output into plain text: escape sequences, pager prompts, carriage-return overwrites and backspaces.
  def self.clean(raw)
    text = raw.dup.force_encoding(Encoding::UTF_8).scrub.gsub(ANSI, '').gsub(PAGER, '').gsub("\r\n", "\n")
    text = text.split("\n", -1).map { |line| line.split("\r", -1).reject { it.strip.empty? }.last || '' }.join("\n")
    nil while text.gsub!(/[^\x08\n]\x08/, '')
    text.delete("\x08")
  end

  # Background process owning the PTY. The raw buffer stays in its memory; only redacted text leaves it.
  class Daemon
    def initialize(name:, ssh_args:, dialect:, prompt:, masks:)
      @name = name
      @ssh_args = ssh_args
      @prompt = prompt || dialect&.prompt_pattern || GENERIC_PROMPT
      @patterns = (dialect&.sensitive_patterns || []) + masks.map { SshCli.literal_pattern(it, note: 'mask') }
      @hmac_key = SecureRandom.bytes(32)
      @buffer = String.new(encoding: Encoding::BINARY)
      @cursor = 0
      @last_data_at = Time.now
      @pager_answered = 0
      @closed = false
      @lock = Mutex.new
      @cond = ConditionVariable.new
    end

    def run
      @server = UNIXServer.new(SshCli.socket_path(@name))
      File.chmod(0o600, SshCli.socket_path(@name))
      File.write(SshCli.pid_path(@name), "#{Process.pid}\n")
      @log = File.open(SshCli.log_path(@name), 'a', 0o600)
      @log.sync = true

      @pty_out, @pty_in, @ssh_pid = PTY.spawn({'TERM' => 'dumb'}, 'ssh', '-tt', *@ssh_args)
      @pty_out.winsize = [1000, 512]
      Thread.new { read_loop }

      serve
    ensure
      Process.kill(:HUP, @ssh_pid) if @ssh_pid && !@closed
      [SshCli.socket_path(@name), SshCli.pid_path(@name)].each { FileUtils.rm_f(it) }
    end

    private def read_loop
      loop do
        data = @pty_out.readpartial(65536)
        @lock.synchronize do
          @buffer << data
          @last_data_at = Time.now
          answer_pager
          @cond.broadcast
        end
      end
    rescue EOFError, Errno::EIO
      Process.wait(@ssh_pid)
      @lock.synchronize do
        @closed = true
        @cond.broadcast
      end
    end

    # Pages through output so commands return in full.
    # Only bytes after the previous answer count, so a pager prompt arriving in fragments is answered once.
    private def answer_pager
      from = [@pager_answered, @buffer.bytesize - 512].max
      tail = (@buffer.byteslice(from..) || '').dup.force_encoding(Encoding::UTF_8).scrub.gsub(ANSI, '')
      return unless tail.match?(PAGER_TAIL)

      @pty_in.write(' ')
      @pager_answered = @buffer.bytesize
    end

    PAGER_TAIL = /(?:#{PAGER})\s*\z/

    private def serve
      loop do
        # Linger after ssh exits so the agent can still read the final output.
        break if @closed && !@server.wait_readable(30)
        next unless @closed || @server.wait_readable(1)

        client = @server.accept
        request = JSON.parse(client.gets || '{}')
        response = handle(request)
        client.puts(JSON.generate(response))
        client.close
        break if request['op'] == 'close'
      end
    end

    private def handle(request)
      case request.fetch('op')
      when 'run' then op_run(request)
      when 'send' then op_send(request)
      when 'wait' then op_wait(request)
      when 'read' then op_read(request)
      when 'close' then op_close
      else {error: "unknown op #{request['op'].inspect}"}
      end
    end

    private def op_run(request)
      command = request.fetch('command')
      prompt = request['prompt'] ? Regexp.new(request['prompt']) : @prompt
      start = write("#{command}\r")
      result = wait_for(timeout: request.fetch('timeout')) do |raw|
        # The prompt counts only once the echoed command line has ended.
        raw.byteslice(start..)&.include?("\n") && prompt_at_end?(raw, prompt)
      end
      lines = result.fetch(:output).split("\n", -1)
      lines.shift if lines.first&.rstrip&.end_with?(command.strip)
      lines.pop if result.fetch(:matched)
      result.merge(output: lines.join("\n"))
    end

    private def op_send(request)
      text = request.fetch('text')
      if (secret = request['secret'])
        @lock.synchronize { @patterns += [SshCli.literal_pattern(secret, note: 'sent')] }
      end
      start = write(text)
      wait_for(timeout: request.fetch('timeout'), settle: 1.0) do |raw|
        raw.bytesize > start && (prompt_at_end?(raw, @prompt) || interactive_at_end?(raw))
      end
    end

    # Returns the buffer size before the write, so callers can ignore a prompt that was already there.
    private def write(text)
      @lock.synchronize do
        @last_data_at = Time.now
        @pty_in.write(text)
        @buffer.bytesize
      end
    end

    private def op_wait(request)
      pattern = request['until'] && Regexp.new(request['until'])
      wait_for(timeout: request.fetch('timeout')) do |raw|
        pattern ? SshCli.clean(raw).match?(pattern) : prompt_at_end?(raw, @prompt) || interactive_at_end?(raw)
      end
    end

    private def op_read(request)
      text = @lock.synchronize { redact(SshCli.clean(@buffer)) }
      {output: text.split("\n", -1).last(request.fetch('tail')).join("\n")}
    end

    private def op_close
      @lock.synchronize { @closed || Process.kill(:HUP, @ssh_pid) }
      {output: ''}
    end

    # Waits until the condition holds on a quiet buffer, or until the buffer has been quiet for +settle+ seconds,
    # then returns the redacted output since the previous response.
    private def wait_for(timeout:, settle: nil)
      deadline = Time.now + timeout
      @lock.synchronize do
        matched = false
        loop do
          idle = Time.now - @last_data_at
          if idle >= SETTLE && yield(@buffer)
            matched = true
            break
          end
          break if settle && idle >= settle
          break if @closed || Time.now >= deadline

          @cond.wait(@lock, [deadline - Time.now, SETTLE].min)
        end
        timed_out = !matched && !@closed && Time.now >= deadline
        {output: deliver, matched:, timed_out:, closed: @closed}
      end
    end

    # Responses cover whole lines, so line-anchored secret patterns see the full line even when output is split.
    private def deliver
      raw = @buffer.byteslice(@cursor..) || ''
      newline = raw.rindex("\n".b)
      @cursor += newline + 1 if newline
      text = redact(SshCli.clean(raw))
      @log.write("#{text}\n")
      text
    end

    private def redact(text) = Glazed::Redactor.new(patterns: @patterns, mode: :hmac, key: @hmac_key).call(text)

    private def last_line(raw) = SshCli.clean(raw).split("\n", -1).last || ''

    private def prompt_at_end?(raw, prompt) = last_line(raw.byteslice(-1024, 1024) || raw).match?(prompt)

    private def interactive_at_end?(raw) = last_line(raw.byteslice(-1024, 1024) || raw).match?(INTERACTIVE_PROMPT)
  end

  class Client
    def initialize(name)
      @name = name
    end

    def request(payload)
      sock = UNIXSocket.new(SshCli.socket_path(@name))
      sock.puts(JSON.generate(payload))
      JSON.parse(sock.gets || raise(Error, "session #{@name} closed without a response"), symbolize_names: true)
    rescue Errno::ENOENT, Errno::ECONNREFUSED
      raise Error, "no session #{@name.inspect}; start one with `open`"
    ensure
      sock&.close
    end
  end

  class Cli
    def initialize(argv)
      @argv = argv
      @name = 'default'
    end

    def run
      OptionParser.new do |o|
        o.banner = USAGE
        o.on('-s NAME') { @name = it }
      end.order!(@argv)
      command = @argv.shift or abort(USAGE)
      case command
      when 'open' then cmd_open
      when 'run' then cmd_run
      when 'send' then cmd_send
      when 'wait' then cmd_wait
      when 'read' then cmd_read
      when 'list' then cmd_list
      when 'close' then cmd_close
      else abort(USAGE)
      end
    rescue Error, OptionParser::ParseError, Glazed::Error => e
      warn "ssh_cli: #{e.message}"
      exit 2
    end

    private def client = Client.new(@name)

    private def cmd_open
      dialect = nil
      prompt = nil
      masks = []
      timeout = 30
      OptionParser.new do |o|
        o.on('--dialect NAME') { dialect = it == 'none' ? nil : Glazed::Dialects.find(it) }
        o.on('--prompt RE') { prompt = Regexp.new(it) }
        o.on('--mask-env VAR') { masks << ENV.fetch(it) }
        o.on('--timeout SEC', Float) { timeout = it }
      end.parse!(@argv)
      abort(USAGE) if @argv.empty?
      raise Error, "session #{@name.inspect} already exists" if alive?(@name)

      FileUtils.mkdir_p(STATE_DIR, mode: 0o700)
      FileUtils.rm_f(SshCli.socket_path(@name))
      daemon = Daemon.new(name: @name, ssh_args: @argv, dialect:, prompt:, masks:)
      pid = fork do
        Process.setsid
        exit!(0) if fork
        $stdin.reopen(File::NULL)
        $stdout.reopen(File::NULL)
        $stderr.reopen(SshCli.log_path(@name), 'a')
        daemon.run
        exit!(0)
      end
      Process.wait(pid)

      deadline = Time.now + 10
      sleep 0.05 until File.socket?(SshCli.socket_path(@name)) || Time.now > deadline
      raise Error, "session #{@name.inspect} failed to start; see #{SshCli.log_path(@name)}" unless File.socket?(SshCli.socket_path(@name))

      respond(client.request(op: 'wait', timeout:))
    end

    private def cmd_run
      opts = {timeout: 30}
      OptionParser.new do |o|
        o.on('--prompt RE') { opts[:prompt] = it }
        o.on('--timeout SEC', Float) { opts[:timeout] = it }
      end.parse!(@argv)
      abort(USAGE) if @argv.empty?
      respond(client.request(op: 'run', command: @argv.join(' '), **opts))
    end

    private def cmd_send
      newline = true
      ctrl = nil
      secret = nil
      timeout = 10
      OptionParser.new do |o|
        o.on('--no-newline') { newline = false }
        o.on('--ctrl KEY') { ctrl = it }
        o.on('--secret-env VAR') { secret = ENV.fetch(it) }
        o.on('--secret-ssm NAME') { secret = ssm_parameter(it) }
        o.on('--timeout SEC', Float) { timeout = it }
      end.parse!(@argv)
      text = if ctrl
        raise Error, '--ctrl takes a single letter' unless ctrl.match?(/\A[a-z@\[\\\]^_]\z/i)

        (ctrl.upcase.ord & 0x1f).chr
      else
        "#{secret || @argv.join(' ')}#{newline ? "\r" : ''}"
      end
      respond(client.request(op: 'send', text:, secret:, timeout:))
    end

    private def cmd_wait
      opts = {timeout: 30}
      OptionParser.new do |o|
        o.on('--until RE') { opts[:until] = it }
        o.on('--timeout SEC', Float) { opts[:timeout] = it }
      end.parse!(@argv)
      respond(client.request(op: 'wait', **opts))
    end

    private def cmd_read
      tail = 50
      OptionParser.new { |o| o.on('--tail N', Integer) { tail = it } }.parse!(@argv)
      respond(client.request(op: 'read', tail:))
    end

    private def cmd_list
      Dir[File.join(STATE_DIR, '*.sock')].each do |path|
        name = File.basename(path, '.sock')
        puts "#{name}\t#{alive?(name) ? 'alive' : 'stale'}"
      end
    end

    private def cmd_close
      all = false
      OptionParser.new { |o| o.on('--all') { all = true } }.parse!(@argv)
      names = all ? Dir[File.join(STATE_DIR, '*.sock')].map { File.basename(it, '.sock') } : [@name]
      names.each do |name|
        if alive?(name)
          Client.new(name).request(op: 'close')
        else
          FileUtils.rm_f([SshCli.socket_path(name), SshCli.pid_path(name)])
        end
        puts "closed #{name}"
      end
    end

    private def respond(response)
      raise Error, response.fetch(:error) if response[:error]

      output = response.fetch(:output)
      puts output unless output.empty?
      $stdout.flush
      if response[:timed_out]
        warn '[ssh_cli: timed out waiting for prompt; output may be partial. Use `wait` or `send --ctrl c`]'
        exit 1
      elsif response[:closed]
        warn '[ssh_cli: session closed]'
        exit 2
      end
    end

    private def alive?(name)
      pid = Integer(File.read(SshCli.pid_path(name)))
      Process.kill(0, pid)
      true
    rescue Errno::ENOENT, Errno::ESRCH, ArgumentError
      false
    end

    private def ssm_parameter(name)
      require 'aws-sdk-ssm'
      Aws::SSM::Client.new(region: 'ap-northeast-1').get_parameter(name:, with_decryption: true).parameter.value
    end
  end
end

SshCli::Cli.new(ARGV).run if $0 == __FILE__
