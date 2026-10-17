# Prompts used by the monitor (KoR26)

Replace the event, day, dates, issue numbers and focus items. Scripts are under `.claude/skills/rknet-event-monitoring/scripts/`; never point a prompt at the session scratchpad, which the next session cannot see.

## The loop

Day 1, as typed by the user: `/loop 20m Monitor Kaigi on Rails 2026 Day 1 environment. /rknet-observability Check syslog and WLC show commands to discover potential issues, report how our wi-fi is stable/unstable, possible action items to deal with. until 19:00 JST today.` → `CronCreate` `*/20 9-18 16 10 *`.

Extension ("Extend as it says"): delete the job and re-create it with the new range (`*/20 9-21 16 10 *`). Add the planned change watch to the prompt:

```
... until 22:00 JST today (extended by the user). Includes the 20:25 before-snapshot (event_snapshot.rb) and the post-change watch
for configurator's 20:30 changes (WLAN 10 DHCP-required off, tra/fo0 APs to local mode): 180 s cadence, option 108/CLAT, RA/IPv6 health,
WLC CPU, Legacy IPv4.
```

Later days, `*/20 11-20 17 10 *`:

```
Monitor Kaigi on Rails 2026 Day 2 environment using the rknet-event-monitoring skill (and /rknet-observability, rknet-wifi-remediation).
Check syslog and WLC `show` commands for potential issues; report how stable the Wi-Fi is and action items. Day 2 focus: <open items from
the previous day's reference file>. Board: <today's board dir in tmp/>, continue issue numbering from #<last+1>. Until 21:00 JST today (2026-10-17).
```

## Follow-up sample after a peer's change

Two one-shot jobs at apply +5 and +15 minutes (`CronCreate` with `recurring: false`, for example `57 14 17 10 *`). Each prompt is self-contained:

```
Track B steering follow-up (optimizer applied static 14 dBm on ap-trb-12 slot 1 at 14:49:40 and ap-trb-13 slot 1 at 14:50:52 JST;
before: trb-12 90, trb-13 91-98, trb-11 85-88, rejects 3-12 per minute since 14:36). Open the wlc-01.venue ssh_cli session if closed.
Run `ruby .claude/skills/rknet-event-monitoring/scripts/change_snapshot.rb 14:49:40 '^ap-trb-'` and
`.claude/skills/rknet-wlc-power-steering/scripts/slot_counts.sh '^ap-trb-'`, save to tmp/txpower/<MMDD-HHMM>-trb-after.txt.
Report whether rejects fell and where the clients went; tell optimizer immediately if any radio is at 95 or more. Send the numbers to
`optimizer` via SendMessage and update issue #15 on the board (update.rb, republish).
```

Always include: what was applied, by whom, the exact apply time, the baseline numbers, the scripts, the output file, the recipient, the board issues, and the verdict to reach ("improved / not improved, with tx/s" when the peer's next step depends on it).

## Wrap-up

One-shot at the end of the window plus a few minutes (`3 22 16 10 *`):

```
It is after 22:00 JST on Kaigi on Rails 2026 Day 1: stop monitoring (TaskStop the Alertmanager Monitor, CronDelete the recurring monitor
job <id>, kill watcher PIDs <pids>). Then wrap up the day: final stability summary, issues #1-#N with status, remediation timeline (what
changed, when, by whom, effect), open action items for tomorrow; update and republish the board <url>; post the wrap-up to Slack;
write or update references/kor26-dayN.md in this skill. Do not commit.
```

## Read-only investigation fork

```
STRICTLY READ-ONLY: only show commands; no config, no debug, no clear. Use your own ssh-cli session
`ruby misc/ssh_cli.rb -s wlc-lb open --dialect aireos --idle-timeout 0 wlc-01.venue.rubykaigi.net` and close it when done.
Hypothesis to test (from the user): load balancing ping-pongs clients between areas. Evidence wanted: <commands, queries, time window>.
Time box 15 minutes. Report: verdict on the hypothesis, the raw lines that support it, the commands and windows used, files saved in tmp/.
```
