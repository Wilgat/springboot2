# What to review — springboot2

**Living checklist** (review plan). Product: **springboot2** bash Type O-P payload online installer + Spring Boot **2.7.18** domain.  
**Class:** software-development · domain SSOT present · **online Type O-P** install.  
**Always load first:** `reviews/lessons.md`

**Last plan update:** 2026-08-10

---

## Pre-flight

| # | Check | Notes |
|---|--------|--------|
| P1 | Read `docs/requirements/index.md` | class + 10 shell REQs + domain (`requirement-domain-springboot2`) |
| P2 | Confirm ship unit `./springboot2` + companion `.sha256` | `VERSION` / `APP_NAME` / `SCRIPT_URL` SSOT |
| P3 | Load `reviews/lessons.md` and re-check every open L-* | Mandatory |
| P4 | Run suite | `./tests/run.sh` — record PASS/FAIL/SKIP |
| P5 | Confirm product class still **Type O-P** | Combined ensure; not Type O-S binary-only; not Type N help-default |
| P6 | Confirm Type 1 elev / sudoers product law still **absent** | CL-SHELL-TTY-PRIVILEGE-TRAPS **N/A** unless elev law is added |
| P7 | Confirm command layer split | `install`/`uninstall` = payload · `self-update`/`self-uninstall` = CLI only |
| P8 | Confirm domain pin | `SPRINGBOOT_VER=2.7.18` — no casual modernize |

---

## Product law surfaces

| Surface | Path | Review focus |
|---------|------|--------------|
| Class | `requirement-class-software-dev.md` | Residual stack; own-or-point peers |
| Domain | `requirement-domain-springboot2.md` | Pins, pipeline, preserve/reset, help↔dispatcher |
| CLI interface | `requirement-shell-cli-interface.md` | Commands, flags, dispatch, modes |
| Zero-arguments | `requirement-shell-cli-zero-arguments.md` | Type O-P empty argv / combined ensure |
| Payload online install | `requirement-shell-payload-online-install.md` | Layer split; first pipe not binary-only |
| Self-management | `requirement-shell-self-management.md` | `version-check`, `self-update`, `self-uninstall`, about |
| Automatic checksum | `requirement-shell-automatic-checksum.md` | Shape A companion primary; CHECKSUM not help |
| Output | `requirement-shell-output-requirements.md` | `out_*` SSOT; JSON purity |
| Storage | `requirement-shell-cli-storage.md` | `util_resolve_storage`; isolation |
| Idempotency | `requirement-shell-idempotency.md` | Re-run safety |
| Interactive vs noninteractive | `requirement-shell-interactive-vs-noninteractive.md` | TTY vs pipe; confirm gates |
| Modular design | `requirement-shell-modular-function-design.md` | Prefix families; no template authority in source |

**Intentionally absent (do not “restore” without owner order):** Type 1 sudoers elev allowlists, local-only install pair without online channel, Spring Boot 3.x/4.x retarget.

---

## High-risk paths (ship unit)

| Path / symbol | Risk | Lesson |
|--------------|------|--------|
| `util_source_external_safe` / SDKMAN source | Silent nounset abort on pipe | L-SILENT-01 |
| `app_main` empty argv / Type O-P | Binary-only first install | L-OP-01 |
| `payload_install` / `payload_uninstall` | Wrong layer vs `inst_*` self-* | L-PAYLOAD-01 |
| `inst_perform_install_*checksum*` | Integrity false pass / false fail | L-CSUM-01 |
| `inst_self_update` / `ver_gt` | Silent downgrade | L-DOWNGRADE-01 |
| HOME / `util_resolve_storage` | `set -u` path explosion | L-HOME-01 |
| `setup_springboot_project` | Wipe user project | L-PRESERVE-01 |
| `app_help` | Advertised but unrouted; CHECKSUM UX leak | L-HELP-01 |
| `check_alpine_requirements` / `setup_sdkman` | Alpine/bash fail closed | domain law |
| Global bin / `sudo` path place | Not elev law tables — do not invent Type 1 TP as Core | Type 1 N/A |

---

## Type 1 elevation — review plan gate

| Gate | Status |
|------|--------|
| Product claims Type 1 / sudoers elev tables | **No** |
| CL-SHELL-TTY-PRIVILEGE-TRAPS | **N/A** |
| Elevation TP dual rows (negative fail + interactive probe) | **n/a** |

---

## Tests surface

| Check | Path |
|-------|------|
| Suite entry | `./tests/run.sh` |
| CLI | `tests/test_cli.sh` |
| Install lifecycle | `tests/test_install_lifecycle.sh` |
| Online curl / silent class | `tests/test_online_curl_install.sh` |
| Domain | `tests/test_domain.sh` |
| TP map | `reviews/test-plan.md` |
| RTM | `reviews/requirement-test-matrix.md` |

**Last suite run (agent host):** 2026-08-11 housekeeping — **PASS=174 FAIL=0 SKIP=1**

---

## Product user docs (when reviewing release readiness)

| Check | Path |
|-------|------|
| README install / Type O-P honesty | `README.md` |
| Changelog vs `VERSION` | `CHANGELOG.md` vs `2.3.2` |
| SECURITY integrity / contact | `SECURITY.md` |
| Companion digest present | `springboot2.sha256` |
| Requirements registry honesty | `docs/requirements/index.md` |

---

## Explicit non-goals for default review

- Real public SDKMAN/Java network install as Core CI (stubs under isolated `HOME` are intentional)  
- Type 1 host package elevation / sudoers fragment product surface  
- Full genesis harness tree completeness inside this product repo  
- Reverse-copy domain pins into unrelated bootstrap seeds  

---

## Publish steps (after a review run)

1. Write `reviews/reports/YYYY-MM-DD-<scope>.md`  
2. Update `reviews/index.md`  
3. Merge new modes into `reviews/lessons.md`  
4. Update TP rows in `reviews/test-plan.md` when bugs close or new gaps found  
5. Do not leave the only copy of findings in session scratch  
