# SOP: AP group assignment

An AP's group picks its RF profile: client cap, Tx power limits, data rates and load-balancing settings ([`../wifi/power-steering.md`](../wifi/power-steering.md#where-settings-live-rf-profiles-override-global)).

| AP group | 5 GHz RF profile | Use |
|---|---|---|
| rk-hi | rk-5g-hi (100 clients per radio) | high density: session rooms |
| rk-med | rk-5g-med (200 clients per radio) | medium density: lobbies, foyers, offices |

The default is rk-hi for session rooms and rk-med elsewhere, but decide per venue from how people actually gather: a foyer that fills at every break, or a lobby with sponsor booths, can need rk-hi. At Kaigi on Rails 2026 tra, trb, lb1, fo0 and noc were rk-hi; lb0, int and off were rk-med.

## Steps

1. Agree the area-to-group rules with the NOC, as patterns on AP names (run [`ap-naming.md`](ap-naming.md) first so names are final).
2. Save `show ap summary` and `show wlan apgroups` into `tmp/`.
3. Generate the batch; the first matching rule wins and APs already in their group are skipped:

   ```
   ruby .claude/skills/rknet-wlc-configurator/scripts/ap_batch.rb group tmp/apsum-....txt \
     rk-hi='^ap-tr[a-c]-' rk-hi='^ap-lb1-' rk-med=. --apgroups tmp/apgroups-....txt > tmp/ap-group.txt
   ```

4. Pilot one AP: apply its line alone, note whether the controller asks for confirmation and whether the AP rejoins (watch `show ap summary`). Group changes were not observed at Kaigi on Rails 2026; assume the AP restarts and drops its clients until the pilot shows otherwise.
5. Apply the rest with `.claude/skills/rknet-wlc-configurator/scripts/wlc_batch.sh` (`!` lines answer a y/n prompt) area by area, before doors or at a break.
6. Verify with `show wlan apgroups` (members per group) and `show ap config general <ap>` (`Cisco AP Group Name`).

Changing an AP's group is a disruptive change during an event. It needs the user's approval and a Slack note with the rollback (the previous group from step 2).
