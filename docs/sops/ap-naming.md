# SOP: AP naming and name reset

APs carry their asset tag ([`../asset-tags.md`](../asset-tags.md), for example `rk-aph19a14`) as their name between events. At an event each AP gets a location name (`ap-<area>-<position>`, see [`../topology.md`](../topology.md#wi-fi)) while it is deployed, and goes back to its asset tag just before it is pulled.

Which AP goes where is not planned in advance: whoever mounts an AP records its asset tag against the location, so setup does not wait on finding a specific unit.

## Inputs (prepared by humans)

1. The deployment map: one row per AP with its `ap-*` name and asset tag.
2. The asset list: asset tag with Ethernet MAC and/or serial number.

Any spreadsheet paste works (tab, comma or space separated, any column order, header rows are ignored). The MAC must be the Ethernet MAC printed on the AP, which is what `show ap summary` lists; traps and BSSIDs use the radio MAC, which differs.

## Naming APs at setup

1. Save the controller's view: `show ap summary` into `tmp/apsum-<MMDD-HHMM>.txt`.
2. Generate the batch:

   ```
   ruby .claude/skills/rknet-wlc-configurator/scripts/ap_batch.rb name tmp/apsum-....txt MAP ASSETS > tmp/ap-name.txt
   ```

   It matches each row to an AP by Ethernet MAC (falling back to the current name), writes `config ap name <new> <current>` per AP, skips APs already named, and lists on stderr: map rows not on the controller yet, APs on the controller but not in the map, duplicate names or MACs, a target name another AP already holds, and names over 32 characters.
3. Resolve the stderr list with the humans. An AP that has not joined yet is normal during setup; run the SOP again once it has.
4. Apply with `.claude/skills/rknet-wlc-configurator/scripts/wlc_batch.sh tmp/ap-name.txt`.
5. Verify: `show ap summary` again; the `name` run should now print only "already named" lines.

Renaming does not reboot the AP or drop its clients, and it keeps the AP group and mode (an AP renamed at Kaigi on Rails 2026 teardown kept 98 clients and its join time).

## Resetting names at teardown

Rooms finish at different times and the last session is a single-track keynote, so APs come down area by area during the last day. The NOC gives a teardown schedule (area and time); reset each area's names right before its pull.

1. For each slot in the schedule, generate that area only:

   ```
   ruby .claude/skills/rknet-wlc-configurator/scripts/ap_batch.rb reset tmp/apsum-....txt MAP ASSETS --only '^ap-trb-' > tmp/ap-reset-trb.txt
   ```

2. Apply at the scheduled time with `wlc_batch.sh`, then post one Slack line per area (`*Config change (HH:MM JST)*: wlc-01.venue reset N ap-trb-* APs to asset-tag names before the pull`).
3. Tell the monitoring side before each reset: Prometheus labels, dashboards and alert rules key on the AP name, so an area's APs vanish from area queries the moment they are renamed while still serving clients.
4. After the last area, `show ap summary` should list only asset-tag names. Note any AP that left under an `ap-*` name in the event's record ([`../events/`](../events/)); it needs a reset at the next setup.

## Pitfalls

- Name clashes: renaming to a name another AP still holds fails. Rename the holder first; the script reports these.
- The AP's own CDP announcements can keep the previous name for a while; trust `show ap summary`.
- `unknown-*` names in Prometheus mean an AP the controller has not named.
