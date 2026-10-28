# rknet docs

Notes on how the RubyKaigi / Kaigi on Rails network is built and run, written for NOC staff and for the Claude Code skills in `.claude/skills/rknet-*`, which read these files instead of keeping their own copies.

| Doc | Content |
|---|---|
| [`topology.md`](topology.md) | Sites, backbone and venue paths, interface description format, VLANs and subnets, Wi-Fi SSIDs and AP naming, dependent services, expected-down targets |
| [`cloudprober.md`](cloudprober.md) | Cloudprober instances, target updates, metrics and configuration |
| [`resolver.md`](resolver.md) | DNS resolver for attendees and infrastructure, Internet egress, DNS transports and client discovery |
| [`event-operations.md`](event-operations.md) | Who does what during an event (humans and the monitor, configurator and optimizer sessions), readiness, start-of-day and teardown checklists |
| [`wifi/troubleshooting.md`](wifi/troubleshooting.md) | Wi-Fi problems found on the WLC with evidence: the 180 s DHCP removal, option 82/108, FlexConnect versus local mode, load balancing, ghost entries, DNS for IPv6-only clients, "no IPv4" reports |
| [`wifi/power-steering.md`](wifi/power-steering.md) | Spreading clients off radios at the client cap by Tx power: what worked, RF profiles, both levers, power-level tables |
| [`wifi/aireos.md`](wifi/aireos.md) | AireOS command behaviour (confirm prompts, WLAN restarts, load balancing, test WLANs) and a Junos `commit confirmed` change |
| [`wifi/client-tests.md`](wifi/client-tests.md) | Commands to give a Mac user and how to read the output |
| [`sops/ap-naming.md`](sops/ap-naming.md) | SOP: naming APs from the deployment map at setup, resetting them to asset tags area by area at teardown |
| [`sops/ap-groups.md`](sops/ap-groups.md) | SOP: assigning APs to rk-hi / rk-med (RF profile) by area |
| [`sops/ap-mode.md`](sops/ap-mode.md) | SOP: converting APs between local and FlexConnect mode, including the one-time FlexConnect setup |
| [`sops/es-mapping.md`](sops/es-mapping.md) | SOP: mapping edge switches by asset tag to `es-<area>-NN` names through DNS CNAMEs, with fixed DHCP assignments so no per-event IP configuration is needed |
| [`hiatus.md`](hiatus.md) | What is down between conferences, what is not an incident, the glazed `hiatus` switch, entering and leaving |
| [`asset-tags.md`](asset-tags.md) | Asset tag format and equipment kinds |
| [`events/`](events/) | One directory per event: daily records, change logs, wiring, and what was left in place |

Keep general lessons in the topic docs and the event's own timeline in `events/<event>/`. Values in the topic docs are snapshots; each says when it was last checked.
