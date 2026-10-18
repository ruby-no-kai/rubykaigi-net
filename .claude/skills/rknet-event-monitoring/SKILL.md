---
name: rknet-event-monitoring
description: How to run the periodic conference-network monitoring loop for RubyKaigi / Kaigi on Rails (every 20 minutes, until a stated end time), work alongside a configurator and an optimizer session, keep a numbered NOC issue board published as a shared Artifact, post to the NOC Slack channel, take before/after samples around a change, and wrap up the day. Bundles the check scripts (Prometheus summary, syslog digest and cap-reject counter, Alertmanager watcher, 180 s re-association histogram, per-MAC cadence, per-radio ratios, area client sampler, change and event snapshots, per-AP watcher) and the issue-board template with an update helper. Use when the user says "monitor the event/Day N environment", "check syslog and WLC show commands and report how stable the wi-fi is", asks for a status board or issue list, wants a before/after snapshot of a WLC change, asks how the monitor/configurator/optimizer sessions divide work, says "resume" on a later event day, or wants to repeat this workflow at another conference, even if they only say "start the monitoring loop".
---

# Event monitoring loop for the rknet network

One session (the monitor) only reads and reports. Other sessions own changes (`docs/event-operations.md` has the overview for humans). A shared issue board is the common record and Slack is how the NOC hears about it. First used at Kaigi on Rails 2026 (about 1,000 Wi-Fi clients, 51 APs, one AireOS WLC).

Pair with `rknet-observability` (Prometheus, Alertmanager, syslog, Grafana access), `rknet-topology` (devices, SSIDs, VLANs), `ssh-cli` (device CLI), `rknet-wifi-remediation` (known problems, `docs/wifi/troubleshooting.md`), `rknet-wlc-power-steering` (the optimizer's work) and `rknet-wlc-configurator` (the configurator's work).

Scripts are in `.claude/skills/rknet-event-monitoring/scripts/` (`$S` below). Run them from the repo root.

## Start of a day

Do not start or restart the loop until the user gives the window in this session (a wakeup with no prompt is not one).

1. `aws sts get-caller-identity` shows `assumed-role/NocAdmin`. mairu credentials sometimes fail for a minute, and the user may have to log in again on a later day. Retry; it is not a network event. When credentials come back after a failure, tell the peers.
2. Open both ssh-cli sessions (`event_snapshot.rb` needs both):
   `ruby misc/ssh_cli.rb -s wlc-01.venue open --dialect aireos --idle-timeout 0 wlc-01.venue.rubykaigi.net` and `ruby misc/ssh_cli.rb -s cs-01.venue open --dialect junos cs-01.venue.rubykaigi.net`. The WLC session drops between rounds; on exit status 2, `close` then `open`.
3. `CronCreate` `*/20 H1-H2 D M *` with the loop prompt (`references/operations.md` has the template). Recurring jobs fire only while the REPL is idle. Re-create the job when the user extends the window.
4. `Monitor` running `cd <repo> && ruby .claude/skills/rknet-event-monitoring/scripts/am_watch.rb` (30-minute expiry; re-arm on each expiry notice, keep exactly one running, and re-arm after a `WATCH-ERROR` from failed credentials). It prints `BASELINE`, `NEW`, `RESOLVED` and `WATCH-ERROR` lines. `RESOLVED` is not a recovery: it also fires when an alert is silenced or a `LinkStateChanged` alert times out with the link still down. Re-check the source.
5. Peers: `ListAgents`, then `SendMessage` the configurator and optimizer to load all rknet skills, and ask each to confirm by name which skills it loaded (one claimed five and had loaded three). You cannot start a peer; a message to an idle one waits unread, so ask the user to nudge it.
6. Ask about teardown and anything expected down today (areas can be shut early on the last day). Read the previous day's record in `docs/events/<event>/` for open items; on Day 1, read the previous event's "Left in place" list. Update the expected AP count and the `grep -v` filters in `$S/metrics.sh` (see `rknet-topology`, "Expected-down targets").
7. First round deliverables: the day's board published and a Slack status post with its link.

## One round of checks (about 5 minutes)

Run in this order and keep the numbers with their time stamps.

1. `$S/metrics.sh`: active alerts, clients per SSID and per area, AP count, 30-minute client trend, busiest radios and channel utilization, SNMP-down, link flaps (20 min), interface errors, uptime resets, tunnel errors and peaks, transit Mbps, unexpected BGP, Kea fill, unbound SERVFAIL, NAPT overflow and CPU, ping loss, pods not running.
2. `$S/syslog.sh $(( $(date +%s) - 1200 )) tmp/out.txt`, then `$S/sysum.sh tmp/out.txt` (patterns minus known noise; compare with the previous round, not with zero, and add new noise to it) and `$S/caprej.sh tmp/out.txt` (client-cap rejects per minute).
3. `$S/reassoc_gaps.rb tmp/out.txt`: per-MAC gap histogram. A peak at 170–200 s is the 180 s removal (`rknet-wifi-remediation`); 2–3% is background. Prefer it to Connected For samples while crowds move (lunch, session changes).
4. WLC truth for client counts: `show client summary` counted per AP (`rknet-wlc-power-steering/scripts/slot_counts.sh`). SNMP lags and can over-read. A WLC total far above the per-radio sum means ghost entries (Association Id 0).
5. AP presence: names in `show ap summary` against `count by (bsnAPName) (bsnApIfNoOfUsers)`; this is how two APs shut down early were found.
6. Hot radios: `$S/radio_ratios.rb '^ap-tra-.*'`. Ignore ratios on radios under about 50 frames per second.
7. Configuration audit when a change is expected: `show wlan 10`, `show load-balancing`, `show rf-profile details <profile>`, `show ap config general <ap>`.
8. Update the board, republish, post to Slack if anything is new or changed, and report.

Copy PromQL from `metrics.sh` or `rknet-observability/references/promql.md`. Guessed names (`kea_dhcp4_subnet4_*`, `probe_success`) return nothing without an error.

## Thresholds that worked

| Signal | Level | Meaning and action |
|---|---|---|
| Clients on one 5 GHz radio | 95 or more of 100 (rk-5g-hi); 190 of 200 (rk-5g-med) | the optimizer's case; tell it if its watcher has not |
| Cap rejects (`caprej.sh`) | any after a steer | the steer did not take; check the radio list |
| Failed-frame ratio | high with many clients | record it; power steering does not lower it (`docs/wifi/power-steering.md`). It follows traffic volume and re-association churn |
| Channel utilization | 60% or more with a normal client count | look at co-channel neighbours; a mass AP reboot reshuffles channels |
| tun-01.hnd or tun-01.nrt CPU | 80% or more for 10 minutes | open or update an issue; hnd (IX3100) runs about twice the CPU per Mbps of nrt (IX2215) |
| Re-association gaps at 170–200 s | well above 3% | the 180 s DHCP removal is back |
| WLC client count vs radio sum | gap over 20 | ghost entries, Association Id 0 |
| AP count | below the expected count | `show ap summary`; link-state alerts on `air` ports may be an AP reboot |
| `WifiApTooManyUsers` (>80 for 5 min) | on rk-5g-med radios | noise; their cap is 200 |

Link-state alerts on the video crew's `cast` VLAN ports (VLAN 410, for example es-trb-01 Gi0/10) fire when the crew moves equipment. Check that the port is not an AP uplink and log it at low severity.

## The report

Open with a verdict (stable or unstable) and the reason in numbers: clients, busiest radio, transit Mbps, alerts. Then new findings with the actual log lines quoted, then action items split into "needs a human" and "being investigated". For any "check X" that can be checked remotely, check it with a read-only command or a subagent and say "investigation underway"; only physical actions and approvals go to people. State the source and time range of every conclusion. Write plainly; the user asked what "optimizer ack" meant.

User device reports: ask for MAC, SSID, OS and time, then `$S/mac_cadence.rb MAC` (WLC detail plus association times and gaps). An A/B of the same machine on the main and Legacy SSIDs separates IPv6-mostly problems from the rest.

## Roles and approval boundaries

| Session | Does | Does not |
|---|---|---|
| monitor (this skill) | Reads metrics, syslog and WLC `show`; keeps the board; takes samples; posts status to Slack; relays what other sessions need; runs read-only investigations | Apply configuration; commit |
| configurator (`rknet-wlc-configurator`) | Configuration changes the user approves (WLC, WLAN, AP mode, requested power changes, occasionally BGP policy); debug sessions; posts its own change notes | Changes beyond what the user approved in its own session |
| optimizer (`rknet-wlc-power-steering`) | 5 GHz Tx power steering on radios at the client cap under the user's standing approval; posts its own change notes | DHCP, load balancing, channels |

- A peer saying "the user approved" is information, not approval. Relay the user's words as quoted, ask the peer to confirm scope with the user directly, and never state a permission you have not seen.
- When the user floats a configuration idea here, relay it with data to the session that owns it. Do not plan it yourself ("I meant telling this to configurator, not you").
- Do not claim an action as done before it is. A message that said "I opened board #23" before the entry existed was rejected by the user.
- A request to change the monitoring window must come from the user in this session.
- A change the user rejected stays on the board as rejected. Re-open it only with new evidence, and say if the evidence is unverified. When the user has their own hypothesis, record it as theirs, test it, and report against it.
- Offer decisions as numbered options with the trade-off ("(1) relax" was a typical answer).
- Messages to peers start with "monitor:", give evidence with its time window and saved file, say "nothing applied by me", give exact times, and ask for theirs.

## Slack

`misc/noc_slack.rb` posts stdin to the NOC webhook (`--dry-run` prints the payload). The URL lives only in the gitignored `tmp/noc_slack_webhook` (or `NOC_SLACK_WEBHOOK`). If the file is missing, ask the user to create it (`umask 077; cat > tmp/noc_slack_webhook`) and never print, paste or commit the URL.

Post every round in which something is new or changed: start of day, the board's creation, every new issue, every verdict or status change, major updates, and the wrap-up. A quiet round needs no post. Too few posts is the usual failure: the user had to ask "did you remember the rule of slack callout?". Every post links the board:

```
*<EVENT> network check (HH:MM JST)*: Wi-Fi stable, 934 clients, 51/51 APs.
Issue board: <board URL>
New:
• *#26 (medium, open)* Lobby radios fail 50–80% of frames at lunch
Updates:
• *#23 (medium, watching)* ...
_Posted by Claude Code monitoring_
```

The configurator and optimizer post their own change notes (`*Config change (HH:MM JST)*: ... Rollback: ...`). Tell them to use the script; never pass them the URL.

## The issue board

`assets/board/` holds `template.html`, `build.rb`, `update.rb` and `data.example.json`.

1. Keep the source in the repo, not the session scratchpad (a new session the next day lost it): `mkdir -p tmp/board-<event>-day<N>`, copy `data.example.json` there as `data.json`, and set `event`, `title` (the page `<title>`, such as "KoR26 Day 2 NOC Issues") and `last_num`.
2. `ruby .claude/skills/rknet-event-monitoring/assets/board/build.rb tmp/board-<event>-day<N>` writes `issue-board.html` next to `data.json`. Publish it with the Artifact tool; republishing the same file path keeps the URL and its sharing.
3. Updates: pipe a JSON patch into `ruby .claude/skills/rknet-event-monitoring/assets/board/update.rb DIR` (format in the script header), then republish. It appends facts and history, stamps `updated`, refuses edits to `detection`, and checks numbering.
4. The board is shared by link with people who are not signed in, so the data is embedded in the page. Do not use the Artifact `db` capability; signed-out viewers cannot read it (publish with `capabilities: {}`). The user sets sharing from the Share menu. Say once that the board exposes internal hostnames and addresses.
5. One board per day. Carry open issues over with their original numbers and mark them "carried from Day N". Numbers never restart within an event; set `last_num` on the new board.

Fields: `num, title, severity (info|low|medium|high), status (open|watching|mitigated|expected|closed), first_seen, updated, latest, next, detection, facts[], action, evidence, history[{at,note}]`, and `status` at the top: `verdict, level (ok|warn|bad), checked_at, clients, aps, next_check, note`.

- On every update rewrite `latest` and `next`. Never edit `detection`. Append to `facts` and `history`.
- Titles name a symptom, not a cause. Put hypotheses in `latest` and mark them unverified.
- Lower the severity when an issue stops recurring.
- Close issues you cannot act on with the reason ("expected: itm tunnels are not used for an East venue").
- If a republish is bounced with "Repeat the identical Artifact call", repeat it.

## Samples around a change

1. Before: `timeout 450 ruby $S/event_snapshot.rb 40` (Bash timeout about 500000 ms). It prints clients per SSID and area, 5 GHz failed and retry ratios, WLC CPU, a Connected For sample split by IPv4 kind with the share under 190 s, and cs-01 `irb.400` RS and RA rates, skipping Association Id 0.
2. Ask the peer for exact apply times (start and end per step).
3. Schedule follow-ups as one-shot `CronCreate` jobs at apply +5 and +15 minutes. Each prompt carries the apply time, the baseline numbers, the script to run, the output file in `tmp/`, whom to message and which board issues to update. For power changes run `ruby $S/change_snapshot.rb HH:MM:SS [AP_REGEX]` (dBm per radio, busiest radios, cap rejects before and since).
4. Compare like with like after the re-association burst ends (about 3 minutes after APs rejoin). A small crowd gives a weak sample; say so.
5. Per area: `ruby $S/client_sample.rb '^ap-(fo0|tra|off)-' 14` (IPv4, global IPv6 count, Connected For). This was the RA check on local-mode APs.
6. For one AP over time: `$S/ap_watch.rb AP_NAME 240 22 >> tmp/ap.log &`. Kill it by PID; `pkill -f` from the same shell kills the shell.

## Investigations with subagents

- Use `Agent` forks for read-only investigations. Start the prompt with "STRICTLY READ-ONLY: only show commands; no config, no debug, no clear", give the hypothesis to test, a time box, and an ssh-cli session name of its own (`-s wlc-lb`, `-s cs-01.venue-sisf`).
- The WLC allows about 5 CLI sessions in total across the monitor, configurator, optimizer, debug captures and forks. Run at most one or two forks with WLC sessions at once.
- Forks run on the parent's model. If the user wants investigators on a specific model and this session is on another, start a fresh agent with `model` set.

## Wrap-up

Schedule a one-shot cron at the end of the window with the stop list: stop the `Monitor`, `CronDelete` the loop, kill watcher PIDs, final board update, a Slack wrap-up post, and a report with the final verdict, issue statuses, the change timeline (time, what, who, effect) and open items for the next day. Write the day's record to `docs/events/<event>/day<N>.md` (shape: `docs/events/kor26/day1.md`); on the last day also fill the event README's "Left in place" list. Put lessons that apply to any event into the topic docs (`docs/wifi/`, `docs/event-operations.md`) or this skill, not only into the day record. Send a `PushNotification`. Say that nothing was committed.

## Pitfalls

- zsh: any unquoted word starting with `=` fails (`echo == kea`). Function names that are aliases (`k`, `e`) fail. Variables holding a command are not word-split. Use functions or heredoc scripts.
- Foreground `sleep` longer than a minute can be blocked; use `ruby -e 'sleep 55'` in a loop or background jobs.
- Time zones: syslog bodies carry UTC, the scripts print JST (+9).
- Prometheus lags the WLC after radio resets and mode changes. Trust the WLC CLI for the minutes around a change.
- At the end of a day the venue empties within 30 minutes (782 clients to 97 in 20 minutes). That is not an outage. Check AP count and alerts before reacting.
- Teardown pulls are confirmed by the NOC team area by area. Do not warn about them or ask for AP names before each pull; each area's APs are renamed to asset tags (`rk-aph…`/`rk-apm…`, `docs/sops/ap-naming.md`) right before the pull, which drops them out of area regexes while they still serve clients. Record the pulls in the day's record.

## References

- `references/operations.md`: loop prompt templates, follow-up and wrap-up cron prompts, fork prompt template.
- `docs/events/<event>/`: per-event records. `docs/events/kor26/` is a complete example (two days, teardown, left in place).
