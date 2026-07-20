**file**: docs/requirements/requirement-shell-payload-online-install.md  
**Status**: Active (Version 1.0.0)  
**Philosophy**: CIAO / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered)

## 1. Purpose

This requirement is the **project Single Source of Truth** for springboot2 as a **Type O-P [payload online installer](../terminologies/payload-installer.md)**: one-liner / empty-argv **combined ensure** of the CLI ship unit **and** Spring Boot payload, with a strict command split between **ship-unit self-care** and **payload install/uninstall**.

**Not the same as** script-alone online install (Type O-S / `template-online-install.md` only). Portable mold: `template-payload-online-install.md`.

**Scope:** Product class O-P; combined empty-argv; command vocabulary (`install`/`uninstall` vs `self-update`/`self-uninstall`); success/error message cases for both layers; ownership map.  
**Out of scope (cited):** Ship-unit download/checksum algorithms (`requirement-shell-automatic-checksum.md`, install primitives in self-management); Spring Boot pins/order detail (`requirement-springboot2-domain.md`); full flag catalog depth (`requirement-shell-cli-interface.md`); output function catalog (`requirement-shell-output-requirements.md`).

---

### Identity SSOT (this product — do not diverge)

| Field | Live value (ship unit `./springboot2`) |
|-------|----------------------------------------|
| **APP_NAME** | `springboot2` |
| **VERSION** | `2.3.1` |
| **Product class** | **Type O-P — payload online installer** |
| **REPO_USER** / **REPO_NAME** | `Wilgat` / `springboot2` |
| **SCRIPT_URL** | composed GitHub raw default |
| **Dispatcher** | `app_main` |
| **Ship-unit SSOT** | `inst_perform_install` / `inst_maybe_install` / `inst_self_update` / `inst_self_uninstall` |
| **Payload SSOT** | `payload_install` / `payload_uninstall` + domain `setup_*` / `run_springboot_project` |

---

## 2. Core rules

### 2.1 Class

| Field | Value |
|-------|--------|
| **Type** | **O-P** (not O-S, not Type N) |
| **Purpose** | Reduce install steps: CLI + SDKMAN/Java/Maven/project (+ optional run) |
| **One-liner** | `curl -fsSL …/springboot2 \| bash` must self-install CLI **and** enter payload ensure |

### 2.2 Command split (normative)

| Command | Layer | Behavior |
|---------|-------|----------|
| *(empty argv)* | Combined | Ship-unit ensure (+ non-interactive `self-update` when newer) **then** payload default (`run` pipeline unless flags say otherwise) |
| `install` | **Payload** | Payload ensure only (`payload_install`: Alpine check → SDKMAN → Java → Maven → project). **No** ship-unit download. Does **not** run app unless product later adds `--run`. |
| `uninstall` | **Payload** | Remove managed **project payload** (`PROJECT_DIR`) only; confirm unless `--force`. **MUST NOT** remove CLI binary. |
| `self-update` | **Ship unit** | Channel upgrade of CLI binary |
| `self-upgrade` | **Ship unit** | Alias of `self-update` |
| `self-uninstall` | **Ship unit** | Remove managed CLI binary only |
| `version-check` | Ship unit | Local vs remote VERSION |
| `version` / `about` / `status` / `help` | Meta | Diagnostics / usage |
| `run` | Payload + run | Domain setup + build/run |
| `reinstall` | Ship + payload | Force ship-unit reinstall then payload ensure (with preserve/`--no-run` as flagged) |

### 2.3 Empty argv (combined ensure)

1. Bootstrap **MUST** always call `app_main "$@"` (no basename gate).  
2. Not installed → ship-unit install; on success **continue** to payload (default `run` path). **MUST NOT** `exit` after binary-only success.  
3. Installed + non-interactive → apply ship-unit upgrade policy (`inst_self_update` / already-latest OK) then payload.  
4. Installed + interactive empty argv → payload default run; ship upgrade may be via explicit `self-update` if TTY policy skips auto-upgrade — still **MUST** payload-ensure.  
5. Failures non-zero and **loud** (INC-20260720-001).

### 2.4 Message coverage (must implement)

| Case | Exit | Message path |
|------|------|--------------|
| Ship install OK | 0 | `out_success` path |
| Ship install fail | ≠0 | `out_error` / JSON error code |
| Payload `install` OK | 0 | `out_success` + project_dir |
| Payload `install` fail | ≠0 | which step failed |
| Payload `uninstall` OK | 0 | `out_success` |
| Payload `uninstall` need confirm | ≠0 | `confirm_required` |
| `self-uninstall` need confirm | ≠0 | `confirm_required` |
| `self-update` already latest | 0 | `out_success` |
| Combined empty argv silent | **forbidden** | — |

### 2.5 Implementation Notes

| Item | Value |
|------|--------|
| **Handlers** | `install` → `payload_install`; `uninstall` → `payload_uninstall`; `self-update`/`self-upgrade` → `inst_self_update`; `self-uninstall` → `inst_self_uninstall` |
| **Empty argv** | Ship ensure without exit-on-success; fall through to domain/run |
| **Payload pins** | `requirement-springboot2-domain.md` |
| **Tests** | `tests/test_install_lifecycle.sh`, `test_domain.sh`, `test_cli.sh` — must detect binary-only first pipe and missing subcommands |

### 2.6 Protection Rule

**MUST NOT:**

1. Treat springboot2 as Type O-S script-alone.  
2. Map `uninstall` → CLI removal or `self-uninstall` → project wipe as primary.  
3. Exit after first ship-unit install without payload on empty argv.  
4. Silent one-liner success.  
5. Advertise `install`/`uninstall` in help without dispatcher routes.

---

## 3. Definition of done

1. Requirement registered in `docs/requirements/index.md`.  
2. Ship unit implements command split + combined empty argv.  
3. Help ↔ dispatcher aligned.  
4. Tests cover payload install/uninstall, self-*, combined ensure, loud failures.  
5. Domain pins remain in `requirement-springboot2-domain.md`.

## 4. Related

| Artifact | Role |
|----------|------|
| `template-payload-online-install.md` | Portable mold |
| `requirement-shell-cli-zero-arguments.md` | Empty-argv detail |
| `requirement-shell-self-management.md` | self-* only |
| `requirement-springboot2-domain.md` | Payload content |
| `requirement-shell-cli-interface.md` | Full command table |
| INC-20260720-001 | Silent curl\|bash |

## 5. Revision history

| Date | Change |
|------|--------|
| 2026-07-20 | v1.0.0 Initial Type O-P product law; install/uninstall vs self-* |
