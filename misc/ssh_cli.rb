#!/usr/bin/env ruby
# Keeps an interactive session to a network device in a background daemon, so a coding agent can run one
# command per invocation. The session is a glazed NodeSession: glazed connects, logs in and runs the dialect's
# post-login commands. Output is redacted with glazed dialect patterns before it leaves the daemon.
#
# Setup: (cd glazed && bundle install)
# Usage: ruby misc/ssh_cli.rb --help
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../glazed/Gemfile', __dir__)
require 'bundler/setup'

require 'delegate'
require 'fileutils'
require 'json'
require 'optparse'
require 'securerandom'
require 'socket'

require 'net/ssh'
require 'glazed/dialects'
require 'glazed/node_session'
require 'glazed/proto'
require 'glazed/redactor'
require 'glazed/secrets_resolver'
require 'glazed/transports'

module SshCli
  # Sessions belong to one Claude Code session so concurrent agents never share a device session.
  # A short prefix of the ID keeps socket paths under the sun_path limit.
  SCOPE = ENV['CLAUDE_CODE_SESSION_ID']&.slice(0, 8) || 'shell'
  STATE_DIR = File.join(File.expand_path('../tmp/ssh-cli', __dir__), SCOPE)

  # Prompts waiting for the agent rather than the device, such as confirmations.
  INTERACTIVE_PROMPT = /(?:password|passphrase[^:]*|username|user|login):\s*\z|\((?:yes\/no)[^)]*\)\?\s*\z|\[y\/n\]\s*\z/i
  PAGER = /---\(more(?: \d+%)?\)---|<--- More --->|-- ?More ?--(?: or \(q\)uit)?/
  ANSI = /\e\[[0-9;?]*[ -\/]*[@-~]|\e[()][0-9A-Za-z]|\e[=>78]/
  LOGIN_PASSWORD = Glazed::Proto::V1::SecretRef.new(ssm: {name: 'arn:aws:ssm:ap-northeast-1:005216166247:parameter/noc/rk_password', region: 'ap-northeast-1'})
  KEY_LOGIN_DIALECTS = %w[junos]
  IDLE_TIMEOUT = 3600
  TRANSCRIPT_LINES = 10_000

  USAGE = <<~EOS
    Usage: #{$0} [-s NAME] <command> [options]

    Commands:
      open --dialect DIALECT [--mask-env VAR]... [--timeout SEC] [--idle-timeout SEC] HOST
          Connect and log in, then run the dialect's post-login commands, such as disabling the pager.
          DIALECT is a glazed dialect (junos, nec_ix, aireos, ios, awplus) and picks the prompt and secret patterns.
          Dialects other than junos log in with the NOC password, which the script reads itself and never prints.
          If the session is already open to the same host, it is reused without logging in again.
          The session ends after --idle-timeout seconds without commands (default 3600, 0 disables),
          or when the Claude Code process that opened it exits.
      run [--timeout SEC] COMMAND
          Run COMMAND and print its output, without the echo and the trailing prompt.
      send [--no-newline] [--ctrl KEY] [--secret-env VAR | --secret-ssm NAME] [--timeout SEC] [TEXT]
          Type raw input, such as an answer to a confirmation or ^C (--ctrl c), and print output up to the next prompt.
          --secret-* types a secret without it passing through argv or output; it is masked from then on.
      wait [--until RE] [--timeout SEC]
          Wait for a prompt (or RE) and print output that arrived since the last command.
      read [--tail N]
          Print the last N lines (default 50) of the session.
      list
          List sessions with their host and idle time.
      close [--all]
          Log out and end the session.

    Options:
      -s NAME   session name (default: default)

    Sessions are private to the Claude Code session (CLAUDE_CODE_SESSION_ID) that opened them.

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

  # Pages through output on dialects without a pager interaction of their own, such as Junos over a shell.
  GENERIC_PAGER = Glazed::Dialect::Interaction.new(
    pattern: /(?:#{PAGER})\s*\z/,
    responder: lambda do |cli, _buffer, match|
      cli.write(' ')
      Glazed::Dialect::Actions::Replace.new(content: match.pre_match + match.post_match)
    end,
  )

  class DeadlineExceeded < StandardError; end

  # Bounds a whole request, since CliSession only times out when the device stays silent.
  class DeadlineTransport < SimpleDelegator
    attr_writer :deadline

    def read(timeout:)
      return __getobj__.read(timeout:) unless @deadline

      remaining = @deadline - Process.clock_gettime(Process::CLOCK_MONOTONIC)
      raise DeadlineExceeded unless remaining.positive?

      __getobj__.read(timeout: [timeout, remaining].min)
    end
  end

  # Background process owning the session. Raw output stays in its memory; only redacted text leaves it.
  # Requests arrive one at a time, so the session is only ever driven from this one thread.
  class Daemon
    def initialize(name:, host:, dialect_name:, masks:, timeout:, idle_timeout:, owner_pid:)
      @name = name
      @host = host
      @dialect_name = dialect_name
      @timeout = timeout
      @idle_timeout = idle_timeout
      @owner_pid = owner_pid
      @patterns = Glazed::Dialects.find(dialect_name).sensitive_patterns + masks.map { SshCli.literal_pattern(it, note: 'mask') }
      @hmac_key = SecureRandom.bytes(32)
      @transcript = []
      @last_request_at = Time.now
      @session = nil
      @failure = nil
      @closed = false
    end

    def run
      @server = UNIXServer.new(SshCli.socket_path(@name))
      File.chmod(0o600, SshCli.socket_path(@name))
      File.write(SshCli.pid_path(@name), "#{Process.pid}\n")
      @log = File.open(SshCli.log_path(@name), 'a', 0o600)
      @log.sync = true

      connect
      serve
    ensure
      logout
      [SshCli.socket_path(@name), SshCli.pid_path(@name)].each { FileUtils.rm_f(it) }
    end

    private def connect
      secrets = Glazed::SecretsResolver.new
      password = (secrets.secret(LOGIN_PASSWORD) unless KEY_LOGIN_DIALECTS.include?(@dialect_name))
      node = Glazed::Proto::V1::Node.new(name: @host, host: @host, dialect: @dialect_name, username: Net::SSH::Config.for(@host)[:user] || ENV.fetch('USER'))
      @transport = DeadlineTransport.new(Glazed::Transports.find('ssh').new(host: @host, port: nil, username: node.username, password:, secrets:))
      # The shell keeps state between commands, such as configuration mode, which exec channels would lose.
      session = Glazed::NodeSession.new(node:, transport: @transport, timeout: @timeout, exec: false, interactions: [GENERIC_PAGER], secrets:)
      session.open
      @patterns += [SshCli.literal_pattern(password.value, note: 'login')] if password
      @session = session
    rescue Glazed::Error, Net::SSH::Exception, SystemCallError, SocketError => e
      @failure = "cannot log in to #{@host}: #{e.class}: #{e.message.lines.first&.strip}"
      @log.write("#{@failure}\n")
    end

    private def serve
      loop do
        # Linger after the session ends so the agent can still read the final output or the failure.
        break if (@closed || @failure) && !@server.wait_readable(30)
        break if idle? || owner_gone?
        next unless @closed || @failure || @server.wait_readable(1)

        client = @server.accept
        request = JSON.parse(client.gets || '{}')
        @last_request_at = Time.now unless request['op'] == 'info'
        response = handle(request)
        client.puts(JSON.generate(response))
        client.close
        break if request['op'] == 'close'
      end
    end

    private def idle? = @idle_timeout.positive? && Time.now - @last_request_at > @idle_timeout

    private def owner_gone?
      return false unless @owner_pid

      Process.kill(0, @owner_pid)
      false
    rescue Errno::ESRCH
      true
    end

    private def handle(request)
      op = request.fetch('op')
      return op_info if op == 'info'
      return {error: @failure} if @failure

      case op
      when 'opened' then {output: ''}
      when 'run' then op_run(request)
      when 'send' then op_send(request)
      when 'wait' then op_wait(request)
      when 'read' then op_read(request)
      when 'close' then op_close
      else {error: "unknown op #{op.inspect}"}
      end
    end

    private def op_info
      {host: @host, dialect: @dialect_name, idle: (Time.now - @last_request_at).round, closed: @closed || !@failure.nil?}
    end

    private def op_run(request)
      command = request.fetch('command')
      timeout = request.fetch('timeout')
      drive(timeout:) { cli.command(command, timeout:).output }
    end

    private def op_send(request)
      if (secret = request['secret'])
        @patterns += [SshCli.literal_pattern(secret, note: 'sent')]
      end
      timeout = request.fetch('timeout')
      drive(timeout:) do
        cli.write(request.fetch('text'))
        expect_output(cli.prompt, INTERACTIVE_PROMPT, timeout:)
      end
    end

    private def op_wait(request)
      timeout = request.fetch('timeout')
      patterns = request['until'] ? [Regexp.new(request['until'])] : [cli.prompt, INTERACTIVE_PROMPT]
      drive(timeout:) { expect_output(*patterns, timeout:) }
    end

    private def op_read(request)
      {output: @transcript.last(request.fetch('tail')).join("\n")}
    end

    private def op_close
      logout
      {output: ''}
    end

    private def cli = @session.cli

    # Output up to and including the match, so the agent sees the prompt it is expected to answer.
    private def expect_output(*patterns, timeout:)
      match = cli.expect(*patterns, timeout:)
      match.pre_match + match[0]
    end

    # Runs a request against the session within its deadline.
    # Output that arrived before a timeout is returned rather than left for the next request.
    private def drive(timeout:)
      @transport.deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + timeout
      {output: deliver(yield)}
    rescue Glazed::TimeoutError, DeadlineExceeded
      {output: deliver(cli.discard), timed_out: true}
    rescue Glazed::ConnectionClosed
      @closed = true
      {output: deliver(cli.discard), closed: true}
    ensure
      @transport.deadline = nil
    end

    private def deliver(raw)
      text = Glazed::Redactor.new(patterns: @patterns, mode: :hmac, key: @hmac_key).call(SshCli.clean(raw))
      @log.write("#{text}\n")
      @transcript.concat(text.split("\n", -1))
      @transcript.shift(@transcript.size - TRANSCRIPT_LINES) if @transcript.size > TRANSCRIPT_LINES
      text
    end

    # The device may already be gone, and the session ends either way.
    private def logout
      session = @session or return
      @session = nil
      @closed = true
      @transport.deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + 5
      session.logout
    rescue Glazed::Error, DeadlineExceeded, IOError, SystemCallError
      nil
    ensure
      session&.close
    end
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
      dialect_name = nil
      masks = []
      timeout = 30
      idle_timeout = IDLE_TIMEOUT
      OptionParser.new do |o|
        o.on('--dialect NAME') { dialect_name = Glazed::Dialects.find(it) && it }
        o.on('--mask-env VAR') { masks << ENV.fetch(it) }
        o.on('--timeout SEC', Float) { timeout = it }
        o.on('--idle-timeout SEC', Float) { idle_timeout = it }
      end.parse!(@argv)
      host = @argv.shift
      abort(USAGE) unless host && dialect_name && @argv.empty?
      return reuse(host:, dialect_name:) if alive?(@name)

      FileUtils.mkdir_p(STATE_DIR, mode: 0o700)
      FileUtils.rm_f(SshCli.socket_path(@name))
      daemon = Daemon.new(name: @name, host:, dialect_name:, masks:, timeout:, idle_timeout:, owner_pid: ENV['CLAUDE_PID']&.then { Integer(it) })
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

      respond(client.request(op: 'opened'))
      warn "[ssh_cli: logged in to #{host}]"
    end

    private def reuse(host:, dialect_name:)
      info = client.request(op: 'info')
      unless info.fetch(:host) == host && info.fetch(:dialect) == dialect_name
        raise Error, "session #{@name.inspect} is open to #{info.fetch(:host)} (#{info.fetch(:dialect)}); close it or pick another -s"
      end

      respond(client.request(op: 'opened'))
      warn "[ssh_cli: reusing session #{@name}]"
    end

    private def cmd_run
      timeout = 30
      OptionParser.new { |o| o.on('--timeout SEC', Float) { timeout = it } }.parse!(@argv)
      abort(USAGE) if @argv.empty?
      respond(client.request(op: 'run', command: @argv.join(' '), timeout:))
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
        "#{secret || @argv.join(' ')}#{newline ? "\n" : ''}"
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
        unless alive?(name)
          puts "#{name}\tstale"
          next
        end

        info = Client.new(name).request(op: 'info')
        state = info.fetch(:closed) ? 'closed' : "idle #{info.fetch(:idle)}s"
        puts [name, info.fetch(:dialect), state, info.fetch(:host)].join("\t")
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
    rescue Aws::Errors::ServiceError, Aws::Errors::MissingCredentialsError, Aws::Sigv4::Errors::MissingCredentialsError => e
      raise Error, "cannot read #{name} from SSM (#{e.class}: #{e.message.lines.first&.strip})"
    end
  end
end

SshCli::Cli.new(ARGV).run if $0 == __FILE__
