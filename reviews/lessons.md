# Lessons — springboot2

Durable failure modes. **Always re-check on product review.**

| ID | Mode | Prevention | Status |
|----|------|------------|--------|
| L-SILENT-01 | `curl \| bash` / empty argv under `set -u` aborts with **0-byte** stdout+stderr when sourcing `.bashrc` or `sdkman-init.sh` (unset `SDKMAN_*`) | `util_source_external_safe`; never discard product stderr on one-liner path; suite **`assert_not_silent`** · **TP-CURL-02..04** · **TP-U-04** · INC-20260720-001 | open watch |
| L-OP-01 | First install exits after **binary-only** place (Type O-S) while product claims Type O-P combined ensure | Empty argv / first pipe **MUST** continue into payload; **TP-LC-01** · **TP-CURL-02** · `requirement-shell-cli-zero-arguments` · `requirement-shell-payload-online-install` | open watch |
| L-PAYLOAD-01 | `uninstall` removes CLI or `self-uninstall` removes project (layer confusion) | Help + dispatcher: **payload** `install`/`uninstall` vs **ship-unit** `self-*`; **TP-LC-03** · **TP-DOM-09** · **TP-CLI-03** | open watch |
| L-CSUM-01 | Broken companion verify or companion digest not updated after ship-unit edit | Shape A companion path + Shape B `CHECKSUM` pin; regenerate `springboot2.sha256` after any ship-unit change; **TP-CSUM-02..05** · **TP-CLI-01** | open watch |
| L-DOWNGRADE-01 | Silent self-update to **older** remote without `--force` | Refuse downgrade with loud error; **TP-LC-08** | open watch |
| L-HOME-01 | `set -u` expands bare `${HOME}` before safe default | Defensive HOME/XDG defaults before path use; **TP-CLI-11** / storage isolation | open watch |
| L-PRESERVE-01 | Domain run wipes existing user project without `--reset`/`--force` | Preserve by default; regenerate only missing pieces; **TP-DOM-05** · **TP-DOM-06** | open watch |
| L-HELP-01 | Help advertises domain/ship commands not routed (or CHECKSUM as UX verb) | Help↔dispatcher alignment; CHECKSUM env not help row; **TP-CLI-03** · **TP-CSUM-05** · **TP-DOM-01** | open watch |
| L-CLASS-01 | Software-dev workspace missing `requirement-class-software-dev.md` | Class law Active + registry row Area `class` | **closed** 2026-08-10 |
| L-DOMAIN-NAME-01 | Domain SSOT basename not `requirement-domain-*` | Renamed to `requirement-domain-springboot2.md` | **closed** 2026-08-10 |
| L-MOD-01 | Modular/prefix hygiene claimed without **TP-*** primary | **TP-MOD-01** / **TP-MOD-02** have in `tests/test_cli.sh` | **closed** 2026-08-10 |
| L-DOCS-01 | Requirements README inventory drift | README refreshed to class + 10 shell + domain | **closed** 2026-08-10 |
| L-HK-01 | `harness-knowledge.md` said six peer classes after eleven-class model | Wording **eleven**; re-check after H2 | **closed** 2026-08-11 |
| L-HK-02 | Local harness lag vs RAM genesis after H2 | Re-H2 on housekeeping; counts should match GENESIS_SSOT | **closed** 2026-08-11 (re-sync) |

**Intentionally out of scope for default lessons:** Type 1 sudoers elev tables, real public-network SDKMAN install as Core CI (stubbed under isolated `HOME`), Spring Boot 3.x retarget without product decision.
