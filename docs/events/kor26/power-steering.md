# Kaigi on Rails 2026 power-steering record (JST)

Worked example and state carried into later days. Source: the optimizer and configurator sessions and `tmp/txpower/` snapshots.

## Day 1 (2026-10-16)

| Time | Change | By | Result |
|---|---|---|---|
| 11:09:31 | `config rf-profile tx-power-max 17 rk-5g-hi` (from 30), effective at the ~11:12 TPC run | configurator | tra radios 20–23 → ≤17 dBm; tra-14 96 → 69, back at 99 ten minutes later |
| 11:33:00–11:34:00 | tra-04 (level 2 of 6), tra-13, tra-05, tra-14 (level 4 of 8), all 14 dBm | configurator | tra-13 100→61, tra-05 97→69, tra-14 91→51; load moved to tra-23/22/06/03 (+15–23 each); tra-04 refilled to 93 within seconds |
| 11:47:12 | tra-23 level 2 of 6 (14 dBm) | configurator | handed power steering to the optimizer at 11:49 |
| 14:18:27 | ap-off-01 level 3 (16 dBm on ch132) for retries, not the cap | configurator, user request | retry ratio fell; the optimizer had judged it not a power problem |
| 14:49:40 / 14:50:52 / 14:58:41 | trb-12, trb-13, trb-11 level 4 (14 dBm) | optimizer, first blanket-approval steps | trb rejects (4–14/min since 14:36) stopped; 5 in total 14:55–15:09. trb-13 hit 98 one minute after trb-12 (cascade) |
| 15:10:24 | lb1-01 level 4 (14 dBm) | optimizer | lobby rejects about 20 around the step, then none |
| 15:22:26 | lb1-03 level 2 of 6 (14 dBm), failed-frame test | optimizer | ratio 24.9% → 16.1% → 23.7%, not improved; test stopped, lb1-03 left at 14 dBm |
| 18:39:26 | lb1-01 level 5 (11 dBm), refilled to 100–104 | optimizer | rejects stopped; 38 ghost entries appeared |
| 18:40:37 | lb1-31 level 4 (14 dBm), absorbed lb1-01's load (92–97) | optimizer | 39 ghost entries appeared |
| 20:30–20:34 | 23 tra/fo0 APs to local mode (reboot) | configurator | static levels survived; channels reshuffled to 36–140 |

Short spikes that fell back without action: lb1-01 100 → 62 in 4 min, tra-25 94 → 68, trb-11 100 → 79, lb0-03 93 → 55, lb0-21 172 → 140, trb-01 88–90 → 60.

Not done: the rollback at a break. The venue emptied after 18:30 and the static levels and the 17 dBm profile cap stayed overnight.

## State at Day 2 12:04 (`show advanced 802.11a txpower`)

Read at 13:37 from `show advanced 802.11a summary` (slot 1): trb-11 4/6 8 dBm ch44, lb1-01 5/8 11 dBm ch132, lb1-03 2/6 14 dBm ch36, lb1-31 4/8 14 dBm ch140, off-01 3/8 16 dBm ch124. A grep of the txpower table by AP name had mixed the two radios of XOR APs.

| AP | Level | dBm | Channel | Note |
|---|---|---|---|---|
| tra-04 | 2/6 | 14 | 56 | |
| tra-05 | 4/8 | 14 | 104 | |
| tra-13 | 4/8 | 14 | 120 | |
| tra-14 | 4/8 | 14 | 128 | |
| tra-23 | 2/6 | 14 | 48 | |
| trb-11 | 4/6 | 8 | 44 | drifted from 14 dBm: moved from ch120 (8-level table) to ch44 (6-level table) overnight |
| trb-12 | 4/8 | 14 | 108 | |
| trb-13 | 4/8 | 14 | 136 | |
| lb1-01 | 5/8 | 11 | 132 | |
| lb1-03 | 2/6 | 14 | 36 | |
| lb1-31 | 4/8 | 14 | 140 | |
| off-01 | 3/6 | 10 | 40 | configurator's; drifted from 16 dBm on ch132, back to 16 dBm (3/8, ch124) at 13:37 |

rk-5g-hi `tx-power-max` is still 17.

## Day 2 (2026-10-17) through 12:54

No optimizer change. 976 clients at 11:55. trb-01 88 (auto) and trb-12 86–87 held and fell back. Prometheus showed lb0-21 at 200/200 while the WLC listed 172–173 (cap 200, 22 dBm); a one-level 22 → 19 dBm step was offered only if it approached 190 or rejects appeared. Lobby lb1-33/01/31 showed 25–56% failed frames at lunch and was left alone.

Afternoon steps (trb-04, trb-12 to 11 dBm, trb-01, trb-02, tra-15) are in [`day2.md`](day2.md#afternoon-from-1255).
