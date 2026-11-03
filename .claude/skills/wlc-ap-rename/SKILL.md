---
name: wlc-ap-rename
description: Rename the venue APs on the WLC back from their location names (ap-tra-01, ap-lb0-12, ...) to their asset tags (rk-apm19a10, rk-aph26a5, ...) during teardown, room by room just before each room's cables are pulled, so next year's metrics don't inherit this year's names. Use when NOC staff ask to put AP names back, reset AP names for 撤去/撤収, prepare the AP rename for teardown, or schedule renames against the teardown timetable, even if they just say "APの名前戻して".
---

# Putting AP names back at teardown

During the conference each AP on wlc-01 carries a location name. Before the APs are collected, each one gets its asset tag back as its name, so that when they join next year's WLC the metrics don't show stale location names. Background: https://scrapbox.io/rknet/撤去 (「APの回収」).

An AP has to be renamed while it is still joined, because an unplugged AP disappears from the WLC. So renames follow the teardown timetable room by room, a few minutes before each room's cables are pulled.

Device access goes through the `ssh-cli` skill (dialect `aireos`). Read it first.

## What to get from the user

These live outside the repository and change every year:

- The asset sheet (`ap-name-set command` in the NOC spreadsheet) mapping location name, Ethernet MAC and asset tag. Ask for it as TSV in a file.
- The teardown timetable: when each room may be torn down.
- Which location code belongs to which room. The codes (`tra`, `trb`, `fo0`, `lb0`, ...) name places in that year's L1 diagram, not tracks, so ask for the diagram instead of guessing. APs in rooms missing from the timetable (staff rooms, the NOC rack, lobbies) need a time from the user.
- For Slack reports: the channel and how to post (see Slack below).

## Preparing

1. Open a session to wlc-01, save `show ap summary`, and run `scripts/build_plans.rb SHEET.tsv SUMMARY OUTDIR` (work under `tmp/ap-rename/`, which git ignores). It writes one file per location with `config ap name <asset> <current name>` lines, keyed by the name each AP has on the WLC now, and lists every disagreement with the sheet: APs missing from the sheet, sheet rows not on the WLC, names that differ. Resolve each with the user; an AP absent from the sheet needs its asset tag from them.
2. Group the location files into time slots with the user, and `scripts/apply_plan.sh FILE --dry-run` each slot against the live WLC.
3. Agree on the schedule: by default the rename runs 5 minutes before each slot's cable-pull time, and 5 minutes before that the session is checked and the rename is announced on Slack for the crew pulling cables, such as 「5分後(16:35)に trb 9台のAP名を戻す。セッションOK」. Ask the user whether they also want it as a push notification. Send it even when everything is fine: it is what lets people get ready, and step in if they need to.

Every slot changes the WLC configuration, so get the user's go-ahead for the schedule as a whole, and again after any change to it.

## Running a slot

`scripts/apply_plan.sh FILE` runs the slot on the open session, saves the configuration, and checks every new name in `show ap summary`. It stops at the first anomaly. On failure, report the output and wait for the user rather than retrying, since half a slot may already be renamed.

Keep the session alive between slots with `scripts/keepalive.sh` in the background.

## Things that bite

- **Session lifetime.** The WLC closes idle CLI sessions after its CLI login timeout (5 minutes in 2026, see `show sessions`), and ssh_cli's own idle timeout is an hour unless opened with `--idle-timeout 0`. `keepalive.sh` covers the first. It pauses while `apply_plan.sh` holds its lock, because a command typed between `save config` and its `y` would answer the question.
- **Reopening.** ssh_cli keeps a failed session around for 30 seconds, and `open` under the same name in that window returns the old failure. `close` it before opening again.
- **bastion and 1Password.** Each new SSH connection signs at bastion through 1Password, which asks for Touch ID and can't be answered while the Mac is locked. If the session drops outside a slot, notify the user. A ControlMaster for bastion in `~/.ssh/config` lets reconnects reuse one signed connection, but that is the user's SSH configuration, so propose it rather than add it.
- **save config.** AireOS asks `(y/n)`, which ssh_cli does not recognise as a question, and the aireos dialect answers "no" to the save question at logout. A rename that was never saved is lost. `apply_plan.sh` handles both.
- **Renames.** `config ap name` is entered on one line from the exec prompt: the aireos dialect's prompt pattern does not match `config>`. It takes the current AP name or its MAC as the last argument. The AP may reboot, which is acceptable at teardown.
- **Scheduled prompts.** Session-scoped schedulers live only in the running Claude Code process, and fire only when it is idle, so avoid long work near slot times. The Mac must stay awake with the lid open: a background `caffeinate -i` prevents idle sleep. Screen lock is fine.
- **Finished APs disappear.** After cables are pulled, renamed APs leave `show ap summary`, so verify each slot right after it runs, not at the end.

## Slack

The NOC channel (`#rkYY-net`) is shared over Slack Connect, and the Slack MCP refuses to post to such channels. Ask the user for an incoming webhook URL in a file and post with `scripts/post_slack.sh FILE < message`. Never print the URL. Besides the announcement 5 minutes ahead, post after a slot succeeds, in this form:

```
AP名を資産番号に戻した (tra+off+lb0, 23台)
- ap-tra-01 → rk-aph19a20
- ...
save config 済み / show ap summary で確認済み
```

If posting is not possible, show the message for the user to paste.
