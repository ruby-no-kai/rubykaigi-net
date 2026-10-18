# SOP: AP naming and name reset

APs carry their asset tag ([`../asset-tags.md`](../asset-tags.md), for example `rk-aph19a14`) as their name between events. At an event each AP gets a location name (`ap-<area>-<position>`, see [`../topology.md`](../topology.md#wi-fi)) while it is deployed, and goes back to its asset tag just before it is pulled. Background: https://scrapbox.io/rknet/撤去 (section "APの回収").

The name is stored on the AP itself. An AP collected under its location name joins next year's controller with that name, and metrics show this year's location for an AP mounted somewhere else.

Which AP goes where is not planned in advance: whoever mounts an AP records its asset tag against the location, so setup does not wait on finding a specific unit.

## Inputs (prepared by humans)

1. The deployment map: one row per AP with its `ap-*` name and asset tag. In 2026 this was the `ap-name-set command` sheet of the NOC spreadsheet (columns `true-name`, `mac-addr`, `asset-tag`); ask for it as TSV in a file under `tmp/`.
2. The asset list: asset tag with Ethernet MAC and/or serial number.

Any spreadsheet paste works (tab, comma or space separated, any column order, header rows are ignored). The MAC must be the Ethernet MAC printed on the AP, which is what `show ap summary` lists; traps and BSSIDs use the radio MAC, which differs. The map can miss APs that were not mounted by the usual crew (ap-noc-01 was missing in 2026); the script reports them.

## Naming APs at setup

1. Save the controller's view: `show ap summary` into `tmp/apsum-<MMDD-HHMM>.txt`.
2. Generate the batch:

   ```
   ruby .claude/skills/rknet-wlc-configurator/scripts/ap_batch.rb name tmp/apsum-....txt MAP ASSETS > tmp/ap-name.txt
   ```

   It matches each row to an AP by Ethernet MAC (falling back to the current name), writes `config ap name <new> <current>` per AP and a final `save config`, skips APs already named, and lists on stderr: map rows not on the controller yet, APs on the controller but not in the map, APs whose current name differs from the map, duplicate names or MACs, a target name another AP already holds, and names over 32 characters.
3. Resolve the stderr list with the humans. An AP that has not joined yet is normal during setup; run the SOP again once it has.
4. Apply with `.claude/skills/rknet-wlc-configurator/scripts/wlc_batch.sh tmp/ap-name.txt`.
5. Verify: `show ap summary` again; the `name` run should now print only "already named" lines.

Renaming does not reboot the AP or drop its clients, and it keeps the AP group and mode (an AP renamed at Kaigi on Rails 2026 teardown kept 98 clients and its join time). `config ap name` also accepts the AP's MAC instead of its current name as the last argument.

## Resetting names at teardown

An unplugged AP disappears from the controller and can no longer be renamed, so each AP is reset while still joined, a few minutes before its cable is pulled. Rooms finish at different times and the last session is a single-track keynote, so APs come down area by area during the last day. In 2026 all 51 APs were reset this way.

### Inputs

- The teardown timetable: when each room may be torn down.
- Which location code belongs to which room. Codes (`tra`, `trb`, `fo0`, `lb0` …) name places in that year's L1 diagram, not tracks; ask for the diagram instead of guessing. APs in rooms missing from the timetable (staff rooms, the NOC rack, lobbies) need a time from the NOC.
- The deployment map and asset list from setup.

### Preparing

1. Generate one file per slot from a fresh `show ap summary` and resolve its stderr list with the NOC:

   ```
   ruby .claude/skills/rknet-wlc-configurator/scripts/ap_batch.rb reset tmp/apsum-....txt MAP ASSETS --only '^ap-(trb)-' > tmp/ap-reset-trb.txt
   ```

2. Agree the schedule with the NOC. Default: the reset runs 5 minutes before the slot's pull time; 5 minutes before that, check the session and announce on Slack for the crew, for example `AP name reset for trb (9 APs) at 16:35, in 5 minutes. WLC session OK.` Send the announcement even when all is fine; it lets people get ready or step in. Ask whether a push notification is wanted as well.
3. The schedule as a whole needs the NOC's go-ahead, and again after any change to it.

### Running a slot

1. Regenerate the slot's file from a fresh `show ap summary` (APs already reset are skipped, so a slot that stopped midway can simply run again).
2. Apply with `wlc_batch.sh`. It stops at the first error; then report and wait for the NOC rather than retrying, since half the slot may be renamed.
3. Verify right away with `show ap summary`: finished areas vanish from it once their cables are pulled.
4. Report on Slack with `ruby misc/noc_slack.rb` (the NOC channel is shared over Slack Connect, where the Slack MCP cannot post):

   ```
   AP names reset to asset tags (tra+off+lb0, 23 APs)
   - ap-tra-01 → rk-aph19a20
   - ...
   Saved; confirmed in show ap summary.
   _Posted by Claude Code configurator_
   ```

5. Tell the monitoring side before each reset: Prometheus labels, dashboards and alert rules key on the AP name, so an area's APs vanish from area queries the moment they are renamed while still serving clients.

After the last area, `show ap summary` should list only asset-tag names. Note any AP that left under an `ap-*` name in the event's record ([`../events/`](../events/)); it needs a reset at the next setup.

### Keeping the session alive through the day

- The WLC closes idle CLI sessions after its CLI login timeout (5 minutes in 2026, `show sessions`). Run `.claude/skills/rknet-wlc-configurator/scripts/wlc_keepalive.sh` in the background between slots; it pauses while a batch holds the lock so it never types into a `(y/n)` question.
- A new connection signs at bastion through 1Password, which asks for Touch ID and cannot be answered while the Mac is locked. Keep the one session alive rather than reopening it, and tell the user at once if it drops outside a slot. A `ControlMaster` for bastion in `~/.ssh/config` would let reconnects reuse one signed connection; that is the user's SSH configuration to change.
- ssh_cli keeps a failed session for 30 seconds and `open` under the same name in that window returns the old failure; `close` it first.
- Scheduled prompts in a Claude Code session live only in that process and fire only when it is idle, so avoid long work near slot times. Keep the Mac awake with the lid open (`caffeinate -i` in the background); a locked screen is fine.

## Pitfalls

- `save config`: the rename is applied at once but not saved, and ssh_cli's AireOS dialect answers "n" to the save question at logout. Every generated batch ends with `! save config`.
- Name clashes: renaming to a name another AP still holds fails. Rename the holder first; the script reports these.
- Enter `config ...` on one line from the exec prompt; ssh_cli's prompt pattern does not match the `config>` sub-prompt.
- The AP's own CDP announcements can keep the previous name for a while; trust `show ap summary`.
- `unknown-*` names in Prometheus mean an AP the controller has not named.
