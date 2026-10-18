require 'cgi'
require 'json'
require 'aws-sdk-lambda'
require 'aws-sdk-s3'

# Publishes what `glazed status` prints to https://rubykaigi.net/glazed
module GlazedStatus
  READER_FUNCTION = ENV.fetch('READER_FUNCTION')
  STATE_S3_BUCKET = ENV.fetch('STATE_S3_BUCKET')
  STATE_S3_KEY = ENV.fetch('STATE_S3_KEY')
  OUTPUT_S3_BUCKET = ENV.fetch('OUTPUT_S3_BUCKET')
  OUTPUT_S3_KEY = ENV.fetch('OUTPUT_S3_KEY')
  MAX_ATTEMPTS = 3

  @s3 = Aws::S3::Client.new
  @lambda = Aws::Lambda::Client.new(http_read_timeout: 100)

  class ReaderError < StandardError; end

  def self.etag_of(bucket, key)
    @s3.head_object(bucket:, key:).etag
  rescue Aws::S3::Errors::NotFound
    nil
  end

  def self.read_status
    response = @lambda.invoke(function_name: READER_FUNCTION, payload: JSON.generate(status: {}))
    payload = response.payload.read
    raise ReaderError, "#{READER_FUNCTION}: #{payload}" if response.function_error

    JSON.parse(payload)
  end

  # Publishes only a snapshot of the state's current version, over the page it was taken after.
  # The page's ETag is read before the snapshot, so a newer page makes the write fail.
  def self.publish
    published = etag_of(OUTPUT_S3_BUCKET, OUTPUT_S3_KEY)
    status = read_status
    version = status.fetch('version') { raise ReaderError, 'reader returned no version of the state' }

    latest = etag_of(STATE_S3_BUCKET, STATE_S3_KEY)
    if latest != version
      puts "aborted: state is #{latest}, snapshot is #{version}"
      return false
    end

    args = {
      bucket: OUTPUT_S3_BUCKET,
      key: OUTPUT_S3_KEY,
      body: render_html(status),
      content_type: 'text/html; charset=utf-8',
    }
    if published
      args[:if_match] = published
    else
      args[:if_none_match] = '*'
    end
    @s3.put_object(**args)
    puts "published: state #{version}, #{status.fetch('nodes').size} nodes"
    true
  end

  def self.handler(event:, context:)
    p(event:)
    attempts = 0
    begin
      attempts += 1
      publish
    rescue Aws::S3::Errors::PreconditionFailed, Aws::S3::Errors::ConditionalRequestConflict => e
      if attempts < MAX_ATTEMPTS
        puts "page changed meanwhile, retrying: #{e.class}"
        retry
      end
      puts "aborted: page keeps changing: #{e.class}"
      false
    end
  end

  def self.render_html(status)
    data = JSON.generate(status, script_safe: true)
    <<~EOF
      <!DOCTYPE html>
      <html lang="en">
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <meta name="glazed-state-version" content="#{CGI.escapeHTML(status.fetch('version'))}">
        <title>glazed</title>
        <style>
          :root {
            color-scheme: light dark;
            --paper: #eef1f3;
            --ink: #1b2631;
            --muted: #566573;
            --rule: #c9d1d8;
            --bad: #b3261e;
            --bad-wash: #f9e3e0;
            --ok: #1f6f5c;
            --warn: #8a5a00;
            --run: #1f5fa8;
          }
          @media (prefers-color-scheme: dark) {
            :root:not([data-theme="light"]) {
              --paper: #14191f;
              --ink: #e3e8ec;
              --muted: #97a3ae;
              --rule: #2d3640;
              --bad: #ff8a80;
              --bad-wash: #3a1f1d;
              --ok: #6fcfb4;
              --warn: #e0b04c;
              --run: #7db4f0;
            }
          }
          :root[data-theme="dark"] {
            --paper: #14191f;
            --ink: #e3e8ec;
            --muted: #97a3ae;
            --rule: #2d3640;
            --bad: #ff8a80;
            --bad-wash: #3a1f1d;
            --ok: #6fcfb4;
            --warn: #e0b04c;
            --run: #7db4f0;
          }
          body {
            margin: 0 auto;
            padding: 1.25rem 1rem 3rem;
            max-width: 72rem;
            background: var(--paper);
            color: var(--ink);
            font-family: system-ui, -apple-system, "Segoe UI", sans-serif;
            line-height: 1.5;
          }
          h1 { margin: 0; font-size: 1.4rem; font-weight: 650; }
          .about { margin: 0.1rem 0 0.25rem; color: var(--muted); }
          #summary { margin: 0 0 1rem; color: var(--muted); }
          #summary.stale { padding: 0.3rem 0.6rem; background: var(--bad-wash); color: var(--ink); border-left: 0.3rem solid var(--bad); }
          .scroll { overflow-x: auto; }
          table { border-collapse: collapse; width: 100%; }
          th, td { padding: 0.3rem 0.8rem 0.3rem 0; border-bottom: 1px solid var(--rule); text-align: left; vertical-align: top; }
          th { font-weight: 600; color: var(--muted); white-space: nowrap; }
          td { font-size: 0.95rem; }
          td.node { font: 0.9rem/1.5 ui-monospace, "SF Mono", Menlo, Consolas, monospace; font-weight: 600; white-space: nowrap; }
          td.node a { text-decoration: underline dotted; text-underline-offset: 0.2em; }
          td.node a:hover, td.node a:focus-visible { text-decoration-style: solid; }
          td.when { white-space: nowrap; }
          td.status-running { color: var(--run); font-weight: 600; }
          td.status-due { color: var(--warn); font-weight: 600; }
          td.status-overdue { color: var(--warn); font-weight: 600; }
          td.result-ok { color: var(--ok); font-weight: 600; }
          td.result-failed { color: var(--bad); font-weight: 600; white-space: nowrap; }
          td.notes { font: 0.85rem/1.4 ui-monospace, "SF Mono", Menlo, Consolas, monospace; color: var(--muted); }
          td.notes { min-width: 22rem; }
          td.notes div { overflow-wrap: anywhere; }
          footer { margin-top: 2rem; color: var(--muted); font-size: 0.9rem; max-width: 70ch; }
          footer p { margin: 0.25rem 0; }
          a { color: inherit; }
          @media (max-width: 48rem) {
            .scroll { overflow-x: visible; }
            table, tbody { display: block; }
            thead { position: absolute; left: -9999px; }
            tr { display: flex; flex-direction: column; padding: 0.7rem 0; border-bottom: 1px solid var(--rule); }
            td { display: grid; grid-template-columns: 5.5rem 1fr; gap: 0 0.5rem; padding: 0.1rem 0; border: 0; }
            td::before { content: attr(data-label); color: var(--muted); font: 400 0.95rem/1.5 system-ui, -apple-system, "Segoe UI", sans-serif; }
            td[data-label="Result"] { order: -1; }
            td[data-label="Workflow"] { order: 1; }
            td:empty { display: none; }
            td.node { order: -1; display: block; padding-bottom: 0.25rem; font-size: 1.05rem; }
            td.node::before { content: none; }
            td.when, td.result-failed { white-space: normal; }
            td.notes { min-width: 0; }
          }
        </style>
      </head>
      <body>
        <header>
          <h1>glazed</h1>
          <p class="about">Configuration backups of the RubyKaigi network devices.</p>
          <p id="summary"></p>
        </header>
        <main>
          <div class="scroll">
            <table>
              <thead>
                <tr><th>Workflow</th><th>Node</th><th>Status</th><th>Due</th><th>Last run</th><th>Result</th><th>Notes</th></tr>
              </thead>
              <tbody id="rows"></tbody>
            </table>
          </div>
          <noscript><p>This page needs JavaScript. The data is the JSON in <code>#status-data</code>.</p></noscript>
        </main>
        <footer>
          <p>Snapshot of state version #{CGI.escapeHTML(status.fetch('version'))}, read at #{CGI.escapeHTML(status.fetch('generated_at'))}. Statuses are worked out in your browser from the times in the snapshot, so they stay current between updates.</p>
          <p>Each node name links to its latest redacted configuration on GitHub.</p>
          <p>The snapshot is also machine-readable: parse the JSON in <code>script#status-data</code>.</p>
          <p>Source: <a href="https://github.com/ruby-no-kai/rubykaigi-net/tree/master/tf/glazed">rubykaigi-net//tf/glazed</a></p>
        </footer>
        <script type="application/json" id="status-data">#{data}</script>
        <script>
          const data = JSON.parse(document.getElementById('status-data').textContent);
          const STALE_SECONDS = 1800;
          const LABELS = ['Workflow', 'Node', 'Status', 'Due', 'Last run', 'Result', 'Notes'];
          const time = (s) => (s ? new Date(s) : null);
          const span = (sec) => {
            sec = Math.max(0, Math.round(sec));
            const m = Math.floor(sec / 60), h = Math.floor(m / 60), d = Math.floor(h / 24);
            if (d > 0) return `${d}d${h % 24}h`;
            if (h > 0) return `${h}h${m % 60}m`;
            if (m > 0) return `${m}m${sec % 60}s`;
            return `${sec}s`;
          };
          const relative = (t, now) => {
            const sec = (t - now) / 1000;
            return sec < 0 ? `${span(-sec)} ago` : `in ${span(sec)}`;
          };
          const iso = (t) => t.toISOString().slice(0, 19) + 'Z';
          const CONFIG_URL = 'https://github.com/ruby-no-kai/rubykaigi-net/blob/master/glazed/hosts/';
          const status = (n, now) => {
            const lease = time(n.lease_until);
            if (n.lease_owner && lease && lease > now) return 'running';
            const due = time(n.due_at);
            if (!due || due > now) return 'waiting';
            return (now - due) / 1000 > data.poll_seconds ? 'overdue' : 'due';
          };
          const cell = (tr, text, className) => {
            const td = document.createElement('td');
            td.textContent = text;
            if (className) td.className = className;
            tr.appendChild(td);
            return td;
          };
          const render = () => {
            const now = new Date();
            const rows = document.getElementById('rows');
            rows.replaceChildren();
            const nodes = [...data.nodes].sort((a, b) => a.workflow.localeCompare(b.workflow) || a.node.localeCompare(b.node));
            const counts = {};
            for (const n of nodes) {
              const st = status(n, now);
              counts[st] = (counts[st] || 0) + 1;
              const tr = document.createElement('tr');
              cell(tr, n.workflow);
              const nodeCell = cell(tr, '', 'node');
              const link = document.createElement('a');
              link.href = CONFIG_URL + encodeURIComponent(n.node);
              link.textContent = n.node;
              nodeCell.appendChild(link);
              cell(tr, st, `status-${st}`);
              const due = time(n.due_at);
              cell(tr, due ? (st === 'running' ? iso(due) : `${iso(due)} (${relative(due, now)})`) : '-', 'when');
              const started = time(n.last_started_at), finished = time(n.last_finished_at);
              cell(tr, started ? `${iso(started)} (${finished && finished >= started ? ((finished - started) / 1000).toFixed(1) + 's' : 'running'})` : '-', 'when');
              if (n.last_failed) cell(tr, `failed ×${n.consecutive_failures || 1}`, 'result-failed');
              else if (finished) cell(tr, 'ok', 'result-ok');
              else cell(tr, '-');
              const notes = document.createElement('td');
              notes.className = 'notes';
              const lines = [];
              if (n.last_failed && n.last_error) lines.push(n.last_error);
              const window = time(n.signal_window_started_at);
              if (window && (!started || window > started)) lines.push(`signal pending since ${iso(window)}`);
              const lease = time(n.lease_until);
              if (n.lease_owner && lease) lines.push(`lease ${n.lease_owner} until ${iso(lease)}`);
              for (const line of lines) {
                const div = document.createElement('div');
                div.textContent = line;
                notes.appendChild(div);
              }
              tr.appendChild(notes);
              LABELS.forEach((label, k) => tr.children[k].setAttribute('data-label', label));
              rows.appendChild(tr);
            }
            const age = (now - new Date(data.generated_at)) / 1000;
            const summary = document.getElementById('summary');
            const parts = Object.entries(counts).map(([k, v]) => `${v} ${k}`).join(', ');
            summary.textContent = `${nodes.length} nodes` + (parts ? ` (${parts})` : '') + `. Snapshot taken ${span(age)} ago.`;
            summary.className = age > STALE_SECONDS ? 'stale' : '';
          };
          render();
          setInterval(render, 15000);
        </script>
      </body>
      </html>
    EOF
  end

end

def handler(event:, context:)
  GlazedStatus.handler(event:, context:)
end

if $0 == __FILE__
  handler(event: {}, context: {})
end
