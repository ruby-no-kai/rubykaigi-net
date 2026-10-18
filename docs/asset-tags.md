# Asset tags

Every piece of NOC equipment carries an asset tag, and APs carry theirs as the AP name on the WLC between events ([`sops/ap-naming.md`](sops/ap-naming.md)).

```
<owner>-<kind><yy><purchase><number>[+<part>]
```

| Part | Meaning | Example |
|---|---|---|
| owner | `rk` RubyKaigi, `kor` Kaigi on Rails | `kor-cros23a1` |
| kind | Equipment kind, free-form (table below) | `aph` |
| yy | Last two digits of the purchase year; `00` for old stock with no known date | `19` |
| purchase | `a`, `b`, `c` … for the 1st, 2nd, 3rd purchase of that kind in that year | `rk-sx23b1` is the second 2023 SFP batch |
| number | 1, 2, 3 … within that purchase, not zero-padded | `rk-aph19a14` |
| `+<part>` | An accessory tracked with its parent | `rk-wlc19a1+psu` |

The tag is unique, so `rk-aph19a14` names one AP for its whole life.

## Kinds in use

| Kind | Equipment (models seen) |
|---|---|
| `aph` | Wi-Fi AP, high-end: AIR-AP2802I (19a, 26a) |
| `apm` | Wi-Fi AP, mid-range: AIR-AP1852I (19a) |
| `wlc` | Wireless LAN controller: AIR-CT3504-K9 (19a, 25a) |
| `wlclic` | WLC license: LIC-CT3504-1A |
| `srn`, `srnp` | Cisco Catalyst 3560CX-12TC / -12PC (`p` = PoE) |
| `srhp` | Cisco Catalyst 3560CX-8PC (8-port PoE) |
| `sruxp` | Juniper EX3400 |
| `rts` | Juniper SRX300 |
| `r` | NEC IX2215 |
| `cpu` | Servers |
| `poe` | PoE injectors (EIB-UG01-PF, -PF2) |
| `sx` | SFP 1000BASE-SX (`sx23b`, `sx26a` are Juniper-coded) |
| `gt` | SFP 1000BASE-T (SFP-GE-T) |
| `daf` | QSFP+ 40G direct-attach cables |
| `cros` | ChromeOS devices, usually Chromebooks (CX1101CMA-GJ0019) |
| `qr` | QR code and barcode scanners |
| `aco` | AC power cords (C15) |
| `pdg`, `pd` | Power strips, 3-pin (grounded) and 2-pin |
| `trolley` | Carts |
| `tool` | Tools |

A new kind needs no registration; pick a short lowercase code that does not collide with the ones above.
