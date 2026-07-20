**file**: docs/requirements/requirement-shell-cli-zero-arguments.md  
**Status**: Active (Version 1.3.0)  
**Philosophy**: CIAO / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered)

> ### Payload installer law (read first — this product)
>
> springboot2 is a **[payload installer](../terminologies/payload-installer.md)** (**Type O-P**): empty argv / `curl \| bash` **MUST** reduce install steps via **combined ensure** — ship-unit self-install (and non-interactive self-update when policy requires) **plus** payload (SDKMAN / Java / Maven / project / optional run).
>
> | Situation | Empty argv **MUST** mean |
> |-----------|---------------------------|
> | **Not installed** | Ship-unit install-ensure **then continue into payload ensure** — **MUST NOT** exit after binary place alone |
> | **Installed** (local or global) | Non-interactive: ship-unit **auto-upgrade** when remote newer / policy; **always payload ensure** (`cmd=run` domain pipeline) — **not** help; **not** pure binary “already installed” no-op |
>
> Portable Type O-S “already installed → install no-op only” and “first pipe = binary only” are **superseded** by Type O-P and `requirement-springboot2-domain.md`. **MUST NOT** dump help for bare `springboot2`. **MUST NOT** silent-success one-liner with no message and no install.

## 1. Purpose

This requirement is the **project Single Source of Truth** for **zero-argument (empty argv) dispatcher behavior** of the springboot2 bash (`#!/bin/bash`) CLI, specialized as a **Type O-P payload installer** (combined self-install/self-update + domain payload ensure).

### 1.0 Product type (template dual-axis model)

| Field | Value for springboot2 |
|-------|------------------------|
| **Empty-argv type** | **Type O-P — Online payload installer** (not Type N; not Type O-S script-alone) |
| **Rationale** | Product advertises `curl … \| bash` to set up a full Spring Boot environment (CLI + SDKMAN/Java/Maven/project), not only place a script file |

Type N (non-online-install → empty argv = help) does **not** apply. Type O-S (binary-only ensure) does **not** apply.

It defines what happens when the tool is invoked with **no command and no flags**, including the classic one-liner:

```sh
curl -fsSL https://raw.githubusercontent.com/Wilgat/springboot2/main/springboot2 | bash
```

Empty argv detect cases:

| Case | Meaning | Empty-argv outcome (this product — Type O-P) |
|------|---------|-----------------------------------------------|
| **Not installed** | No managed binary at the resolved install path(s) | Ship-unit install **then payload ensure** (do not exit after binary only) |
| **Installed (local)** | Managed binary at the user path (`USER_BIN` / `${HOME}/.local/bin/springboot2`) | Non-interactive ship-unit upgrade policy + **payload ensure** (domain run) |
| **Installed (global)** | Managed binary at the global path (`GLOBAL_BIN` / `/usr/local/bin/springboot2`) | Same as local for global path |

**Scope:** Empty-argv routing, Type O-P combined ensure, detect cases (global / local / absent), force boundary, exit status, TTY / quiet / json, **loud one-liner outcomes**.  
**Out of scope (own requirements):** Full command catalog (`requirement-shell-cli-interface.md`); domain pipeline depth (`requirement-springboot2-domain.md`); download/checksum detail (`requirement-shell-automatic-checksum.md`); full self-update/uninstall lifecycle detail (`requirement-shell-self-management.md` — reused on empty argv for upgrade policy); output function catalog (`requirement-shell-output-requirements.md`); general idempotency matrix beyond empty-argv rows (`requirement-shell-idempotency.md`).

---


### Identity SSOT (this product — do not diverge)

| Field | Live value (ship unit `./springboot2`) |
|-------|----------------------------------------|
| **APP_NAME** | `springboot2` |
| **VERSION** | `2.3.0` |
| **REPO_USER** / **REPO_NAME** | `Wilgat` / `springboot2` |
| **SCRIPT_URL** | `https://raw.githubusercontent.com/Wilgat/springboot2/main/springboot2` |
| **Shebang / runtime** | `#!/bin/bash` (SDKMAN requires bash) |
| **Dispatcher** | `app_main` (A naming) |
| **Output SSOT** | `out_text` / `out_json` / `out_json_error` (+ wrappers `out_info`/`out_success`/`out_warn`/`out_error`/`out_die`) |
| **Install SSOT** | `inst_perform_install` / `inst_maybe_install` / `inst_is_installed` / `inst_get_version` |

Live scalars are owned by the ship unit Config block. Requirement **cores** stay portable; **Implementation Notes** must match the table above. On conflict with Config, use product identity protocol (ask; do not invent dual owners). Domain Spring Boot ops (`setup_sdkman`, `setup_java`, `setup_maven`, `setup_springboot_project`, `run_springboot_project`) are **in addition** to Type 0 lifecycle.

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Definitions (portable + project)

| Term | Definition for springboot2 |
|------|----------------------------|
| **Type O-P** | [Payload installer](../terminologies/payload-installer.md): empty argv = combined ship-unit + payload ensure (this product). |
| **Type O-S** | Script-alone online tool — **out of scope** as product class (binary-only). |
| **Type N** | Non-online-install empty-argv type: empty argv = help — **out of scope** for springboot2. |
| **Empty argv / zero-arg** | `$# -eq 0` at entry to `app_main` (no command tokens; classic `curl \| sh` with no trailing args). |
| **Ship-unit install-ensure** | Converge to “managed `springboot2` binary present” (install / upgrade / force replace). |
| **Payload ensure** | Domain pipeline: SDKMAN / Java / Maven / project + optional `run_springboot_project` (`requirement-springboot2-domain.md`). |
| **Combined ensure** | Ship-unit layer then payload layer without requiring a second user command. |
| **Not installed** | `inst_is_installed` returns false (`inst_get_version` → `not installed`). |
| **Installed (local)** | Executable at `${USER_BIN}/springboot2` (default `USER_BIN=${HOME}/.local/bin`) observed by install-detect SSOT. |
| **Installed (global)** | Executable at `${GLOBAL_BIN}/springboot2` (default `GLOBAL_BIN=/usr/local/bin`) observed by install-detect SSOT. |
| **Force / reinstall** | `FORCE_REINSTALL=1` from `--force` / `reinstall` (and related wiring in `app_main`). Required only for deliberate replace, not for ensure. |

### 2.2 Single meaning of empty argv (Type O-P combined ensure)

1. When **argv is empty** and the tool is **not installed**, `app_main` **MUST** run **ship-unit install** then **payload ensure** — **MUST NOT** route to `app_help`, and **MUST NOT** exit after binary place alone.  
2. When **argv is empty** and the tool is **installed**, `app_main` **MUST**:  
   - **Non-interactive** (non-TTY / quiet / json / classic pipe re-run): apply **ship-unit auto-upgrade** when remote is newer or force policy requires (reuse `inst_self_update` / `inst_perform_install` primitives); then **payload ensure**.  
   - **Interactive**: **MUST** still run **payload ensure** (domain default `cmd=run`); ship-unit upgrade **MAY** follow explicit `self-update` if TTY policy documents not auto-upgrading, but **MUST NOT** dump help or binary-only no-op as full success.  
3. Explicit `springboot2 help` remains the only full-usage path for help text.  
4. Bootstrap **MUST** always call `app_main "$@"` so pipe one-liners reach this contract (no `${0##*/}` product-name gate).  
5. Empty argv **MUST NOT** require the user to pass `install` or a second invocation merely to get SDKMAN/Java/Maven after first pipe.  
6. Outcomes **MUST** be loud: visible progress/success via `out_*` or non-zero failure — **silent exit 0 with no install is forbidden** (INC-20260720-001).

### 2.3 Normative case matrix (Type O-P)

| Case | Detect condition (project) | Empty argv, force off (this product) | Empty argv / deliberate install force |
|------|----------------------------|--------------------------------------|---------------------------------------|
| **A. Not installed** | `inst_is_installed` false | Ship-unit install (§2.4) **then payload ensure** | Same + force placement as designed |
| **B. Installed — local** | User binary present via detect SSOT | Non-interactive upgrade policy + **payload ensure** — **no help** | `self-update` / `reinstall` / `--force` for deliberate binary replace |
| **C. Installed — global** | Global binary present via detect SSOT | Same as B for global path | Same as B |

**Portable Type O-S “already-installed = install no-op”** is seed pattern for script-alone CLIs only. **This product is Type O-P.** Do not claim binary-only no-op or first-pipe-binary-only as Implemented for springboot2 empty argv.

**Already-installed rules (Cases B and C, empty argv, force off) — Type O-P:**

1. **MUST NOT** dump full help.  
2. **MUST** enter domain/payload pipeline (default `run`) per live `app_main` and `requirement-springboot2-domain.md`.  
3. Non-interactive: **MUST** attempt ship-unit upgrade when version-check says remote is newer (or document temporary Gap until implemented).  
4. Detect **MUST** treat either global or local managed binary as installed when that is how `inst_is_installed` / `inst_get_version` resolve paths.  
5. Exit status and messaging for domain run follow domain + output requirements (build/run may long-run / exec; `--no-run` may exit 0 after setup).

### 2.4 Case A — not installed (modes) — ship unit then payload

| Mode | Required empty-argv behavior |
|------|------------------------------|
| **Interactive** (TTY stdin+stdout, not quiet/json) | Confirm/install ship unit as designed; on success **continue to payload ensure** (do not exit binary-only) |
| **Non-interactive** (non-TTY / `curl \| sh`) | Auto ship-unit install + **payload ensure** without hang |
| **Quiet or JSON** | Ship-unit install + payload ensure without prompts; JSON purity for structured paths |
| **Failure** (network, checksum, I/O, payload) | Non-zero exit; no fake success; no help-only output; **no silent no-op** |

**Placement privilege:**

| Invoker | Target |
|---------|--------|
| root (`id -u` 0), e.g. `curl … \| sudo bash` | `${GLOBAL_BIN}/springboot2` → `/usr/local/bin/springboot2` |
| non-root | `${USER_BIN}/springboot2` → `${HOME}/.local/bin/springboot2` |

### 2.5 Equivalence / non-equivalence

| Invocation | Contract (this product) |
|------------|-------------------------|
| Empty argv, not installed | Combined ensure (ship unit + payload) |
| Empty argv, installed | Upgrade policy (non-interactive) + payload ensure — **not** binary-only no-op |
| Explicit `self-update` | Ship-unit upgrade lifecycle (may not run payload unless fallthrough designed) |
| `reinstall` | Force ship unit then domain pipeline (live) |
| `help` | Usage only — **not** empty-argv default |

### 2.6 Forbidden empty-argv outcomes

1. Dump full help when Case A/B/C should ensure.  
2. Silent success when Case A should install (no message, no binary).  
3. Exit after ship-unit install without payload ensure (Type O-S collapse).  
4. Treat Case B/C empty argv as binary-only success no-op while claiming Type O-P compliance.  
5. Require `--force` solely because detect says installed (for normal re-run / domain use).  
6. Blind re-download every empty-argv run without force (unless upgrade policy requires).  
7. Basename-gate main so `curl \| sh` never hits the empty-argv branch.  
8. Detect only one of global/local incorrectly contrary to `inst_is_installed` family SSOT.

### 2.7 Implementation Notes (this project)

| Item | Value for springboot2 |
|------|------------------------|
| **Empty-argv type** | **Type O-P — Payload installer** (combined ensure; not Type N; not Type O-S) |
| **Product / binary** | `springboot2` (`APP_NAME`) |
| **Ship unit** | Repo root `./springboot2` |
| **Dispatcher** | `app_main` — empty-argv block **before** flag/command parse default help |
| **Ship-unit ensure** | `inst_perform_install` / `inst_maybe_install` / `inst_self_update` (upgrade policy) |
| **Payload ensure** | Domain pipeline after ship unit: `setup_sdkman` → `setup_java` → `setup_maven` → `setup_springboot_project` → optional `run_springboot_project` |
| **Detect SSOT** | `inst_is_installed` ← `inst_get_version` |
| **Global path** | `GLOBAL_BIN` default `/usr/local/bin` |
| **Local path** | `USER_BIN` default `${HOME}/.local/bin` |
| **Force wiring** | `--force` → `FORCE=1` and `FORCE_REINSTALL=1` in `app_main` |
| **Output SSOT** | `out_success` / `out_info` / `out_json` / errors via `out_*` |
| **Channel** | `SCRIPT_URL` (compose from `REPO_USER` / `REPO_NAME` / `APP_NAME`) for download path inside install |
| **Live status** | Type O-P combined ensure implemented in `app_main` (no exit after ship place; non-interactive `inst_self_update` when installed; payload fallthrough). |
| **Tests** | `tests/test_cli.sh`; `tests/test_install_lifecycle.sh`; **required:** stdin-pipe smoke for loud Case A + not silent no-op |

#### Dispatcher algorithm (normative sketch — Type O-P target)

```text
app_main:
  if [ $# -eq 0 ]; then
    if not inst_is_installed:
      ship-unit install (inst_maybe_install / inst_perform_install per mode)
      on failure → exit non-zero
      # MUST NOT exit here on success — fall through to payload
    else
      if non-interactive and upgrade needed:
        ship-unit self-update / force policy
    fi
    # payload ensure (domain default run)
    cmd=run → domain pipeline
  fi
  # else parse flags/commands…
```

#### Message contract (human)

- Ship-unit progress/success and payload progress via `out_*`  
- Failures loud and non-zero  
- **MUST NOT** print the full `app_help` usage body on empty-argv ensure path  
- **MUST NOT** complete with zero output when install was expected

### 2.8 Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 1 – Caution** (https://github.com/cloudgen/ciao): One-liner must not be silent or look like success when nothing installed.  
- **CIAO Principle 2 – Intentional** (https://github.com/cloudgen/ciao): Empty argv means **combined ensure** for a payload installer.  
- **CIAO Principle 3 – Anti-fragile** (https://github.com/cloudgen/ciao): Dual install paths + `curl \| bash` + full environment converge.  
- **CIAO Principle 5 – Single point of entry** (https://github.com/cloudgen/ciao): `app_main` owns empty-argv before help default.  
- **CIAO Principle 14 – Interactive vs non-interactive** (https://github.com/cloudgen/ciao): Auto under pipe; upgrade policy non-interactive.  
- **CIAO Principle 18 – Over-protect** (https://github.com/cloudgen/ciao): Protection Rule against help-fallback and O-P→O-S collapse.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** Real failures non-zero and loud; healthy re-runs clear text.  
- **Intentional:** Help is never the empty-argv default; payload is part of first pipe.  
- **Anti-fragile:** Global and local detect; second one-liner upgrades + re-ensures environment.  
- **Over-protect:** Do not simplify empty-argv to help or binary-only exit.  
- **SSOT:** `inst_*` for ship unit; domain helpers for payload; `out_*` for messages.  
- **Idempotent ensure:** Payload and ship unit detect-then-ensure.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Route empty argv to `app_help` when ensure should run.  
2. Collapse Type O-P to Type O-S (exit after binary place; skip payload).  
3. Require `--force` for a healthy already-installed empty-argv re-run solely because the binary exists.  
4. Handle only Case A and leave B/C as accidental help fallthrough.  
5. Break dual-path detect so local or global installs are misclassified.  
6. Blindly reinstall ship unit every empty-argv run without force/upgrade policy.  
7. Exit 0 with **no message** and **no install** for a claimed one-liner (silent success).  
8. Reintroduce a basename-only gate that skips `app_main` under `curl \| bash`.  
9. Bypass `out_*` for empty-argv user messages.  
10. Document “already installed → help” or pure binary no-op as full empty-argv success for this product.

**Violating this rule is a critical zero-arg / payload-installer / online-install regression.**

---

## 5. Definition of done

This requirement is satisfied when all of the following hold:

1. Empty argv + not installed → ship-unit install **and** payload ensure (TTY may confirm ship unit; non-TTY / quiet / json auto).  
2. Empty argv + local/global install + force off → payload ensure; not help; non-interactive upgrade policy when applicable.  
3. Empty argv + install/payload failure → non-zero exit with visible error.  
4. One-liner never silent-success with no binary.  
5. `--force` / `reinstall` only for deliberate replace; not required for normal ensure.  
6. `help` works when invoked explicitly.  
7. Tests cover pipe smoke (not silent), Case A failure, Case B/C not-help.  
8. Changes cite `requirement-shell-cli-zero-arguments` and term `payload-installer`.

---

## 6. Related artifacts

| Artifact | Role |
|----------|------|
| `docs/terminologies/payload-installer.md` | Type O-P definition |
| `docs/requirements/requirement-shell-payload-online-install.md` | Product Type O-P class law (install/uninstall vs self-*) |
| `docs/templates/template-payload-online-install.md` | Portable O-P mold |
| `docs/terminologies/type-o-empty-argv.md` | Type O umbrella + O-S/O-P depth |
| `docs/requirements/requirement-shell-cli-interface.md` | Full command surface; empty-argv row must match this SSOT |
| `docs/requirements/requirement-shell-idempotency.md` | Ensure re-run / force boundary |
| `docs/requirements/requirement-shell-interactive-vs-noninteractive.md` | TTY vs pipe for Case A |
| `docs/requirements/requirement-shell-self-management.md` | self-update primitives reused on empty argv upgrade |
| `docs/requirements/requirement-shell-output-requirements.md` | `out_*` / JSON purity |
| `docs/requirements/requirement-shell-automatic-checksum.md` | Integrity on install download path |
| `docs/requirements/requirement-springboot2-domain.md` | Payload pipeline |
| Repo root `./springboot2` | Implementation (`app_main`, `inst_*`, domain helpers) |
| `docs/incidents/incident-20260720-001-curl-bash-silent-no-self-install.md` | Silent one-liner / no install incident |
| `tests/test_cli.sh`, `tests/test_install_lifecycle.sh` | Regression coverage |

---

## 7. Revision history

| Date | Change | Author / agent |
|------|--------|----------------|
| 2026-07-14 | Initial Active v1.0.0: empty argv = install-ensure for not-installed / local / global; forbid help fallthrough | Grok (owner request) |
| 2026-07-14 | v1.1.0: Classify product as Type O (online-install) under dual-type empty-argv template model | Grok |
| 2026-07-15 | v1.2.0: Promote hybrid supersession banner to top; soft-supersede portable Cases B/C force-off as domain run; cite domain requirement | Grok (authorized 1–3) |
| 2026-07-20 | v1.3.0: **Type O-P payload installer** law; combined ensure; first pipe must not exit binary-only; non-interactive upgrade; loud one-liner; live Gap honesty | Grok (owner request) |


### Empty argv specialization (springboot2 — Type O-P payload installer)

Normative summary lives in the **Payload installer law** banner at the top of this file and in §2.2–2.3. Condensed matrix:

| Situation | Required behavior for **this** product |
|-----------|----------------------------------------|
| **Not installed** + empty argv | Ship-unit install **then payload ensure** |
| **Installed** + empty argv | Non-interactive ship-unit upgrade policy + **domain default `cmd=run`** |
| **Installed** + explicit lifecycle cmds | `version`, `version-check`, `self-update`, `self-uninstall`, `about`, `help` as dispatched |
| **Flags** | `--project-dir`, `--no-run`, `--force`, `--force-user`, `--force-root`, `--json`, `--quiet` |

Portable Type O-S matrices are **not** full product law for springboot2.
