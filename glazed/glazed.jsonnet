// glazed configuration for backing up device configurations, on AWS Step Functions (tf/glazed) and by hand.
// ./gen-glazed.rb renders it to gen/glazed/glazed.json, which tf/glazed uploads for the Lambda function.

// Set true in-between conferences, when venue hosts are shut down.
local hiatus = true;

local node(dialect, name, site) = {
  name: '%s.%s' % [name, site],
  host: '%s.%s.rubykaigi.net' % [name, site],
  dialect: dialect,
};
local ssm(name) = { ssm: { name: '/glazed/prd/%s' % name } };
// NEC IX, IOS and AireOS log in with a password (AireOS inside the SSH session); Junos with a key.
local password = { password: ssm('password') };
// Regular expressions hidden from redacted configurations; tf/glazed holds the sensitive ones.
local redactPattern(note) = { ref: ssm('redact-pattern/%s' % note), regexp: true, note: note };
local redactPatternInline(note, pattern) = { ref: { value: pattern }, regexp: true, note: note };

local junos(name, site) = node('junos', name, site) + {
  params: { junos_license: 'false' },
  transport_options: { ssh: { keys: [{ raw: ssm('ssh-key') }], keys_only: true } },
};
local ix(name, site) = node('nec_ix', name, site) + password;
local ios(name, site) = node('ios', name, site) + password;
local wlc(name, site) = node('aireos', name, site) + password;

{
  inventory: [{
    inline: {
      defaults: { username: 'glazed' },
      nodes: std.flattenArrays([
        [junos('br-01', site) for site in ['hnd', 'nrt', 'itm']],
        [ix('tun-01', site) for site in ['hnd', 'nrt', 'itm']],
        [ix('recon-01', 'nrt')],

        // venue
        [junos(name, 'venue') for name in ['er-01', 'er-02', 'cs-01']],
        [ix(name, 'venue') for name in ['tun-01', 'tun-02', 'nat-41', 'nat-42']],
        [wlc('wlc-01', 'venue')],
        [ios(name, 'venue') for name in ['es-tra-01', 'es-tra-02', 'es-fo0-01', 'es-trb-01', 'es-trb-02', 'es-lb0-01', 'es-lb0-02', 'es-lb1-01']],

        // lab
        // [junos(name, 'tkyk') for name in ['er-99', 'cs-99', 'es-99']],
        // [junos('test-cs-01', 'nrt'), ix('tun-99', 'tkyk')],
        // [wlc(name, 'tkyk') for name in ['wlc-90', 'wlc-99']],
      ]),
    },
  }],

  storages: {
    raw: { s3: { bucket: 'rk-infra', prefix: 'glazed/raw/' } },
    redacted: { s3: { bucket: 'rk-infra', prefix: 'glazed/redacted/' } },
    state: { s3: { bucket: 'rk-infra', prefix: 'glazed/state/' } },
    github: {
      github: {
        repository: 'ruby-no-kai/rubykaigi-net',
        branch: 'config-staging',
        subdirectory: 'glazed/hosts',
        // Exchanged at tf/sts-cat; see github-token.rb
        token: { command: { exec: ['ruby', '-e', importstr 'github-token.rb'] } },
      },
    },
  },

  workflows: {
    backup: {
      steps: [
        { name: 'fetch', fetch: { output: 'raw', storage: 'raw' } },
        {
          name: 'redact',
          redact: {
            input: 'raw',
            output: 'redacted',
            storage: 'redacted',
            // Base64, such as from `openssl rand -base64 32`. Keep it stable: a new key changes every digest at once.
            redaction: {
              mode: 'MODE_HMAC',
              hmac_key: ssm('hmac-key'),
              secrets: [
                redactPattern(note)
                for note in ['nrt-ngnx', 'nrt-ngnn', 'hnd-ngnx', 'hnd-ngnn', 'itm-ngn', 'hnd-uplink']
              ] + [
                redactPatternInline('caf-no', 'CAF\\d{10}'),
              ],
            },
          },
        },
        // tf/glazed runs this step on the glazed-github function, outside the VPC.
        { name: 'github', publish: { input: 'redacted', storage: 'github' } },
      ],
    },
  },

  orchestrator: {
    state: { sqlite: { storage: 'state', key: 'state.sqlite3' } },
    workflows: {
      backup: {
        schedule: if hiatus then { interval: '86400s' } else { interval: '900s', retry_interval: '60s' },
        schedule_rules: if hiatus then [
          { match: { name_regexp: '.*\\.venue' }, schedule: { interval: '604800s' } },
        ] else [],
        debounce: { delay: '60s', max_wait: '600s' },
        lease: '1800s',
      },
    },
  },
}
