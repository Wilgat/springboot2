**file**: docs/requirements/requirement-shell-cli-zero-arguments.md  
**Status**: Active (Version 1.2.0)  
**Philosophy**: CIAO / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered)

> ### Hybrid supersession (read first — this product)
>
> | Situation | Empty argv **MUST** mean |
> |-----------|---------------------------|
> | **Not installed** | **Type O install-ensure** (`maybe_install` / `perform_self_install`) — portable Cases A below |
> | **Installed** (local or global) | **Domain default run** (`cmd=run`: SDKMAN/Java/Maven/project + `build_and_run`) — **not** install-ensure success no-op |
>
> Portable Type O text that says “already installed → install no-op only” is **superseded for installed empty argv** by this hybrid and by `requirement-springboot2-domain.md`. First-install / `curl \| bash` path remains install-ensure. **MUST NOT** dump help for installed bare `springboot2`.

## 1. Purpose

This requirement is the **project Single Source of Truth** for **zero-argument (empty argv) dispatcher behavior** of the springboot2 bash (`#!/bin/bash`) Type 0 CLI, specialized as a **Type O hybrid** (install when absent; domain run when installed).

### 1.0 Product type (template dual-model)

| Field | Value for springboot2 |
|-------|------------------------|
| **Empty-argv type** | **Type O — Online-install hybrid** (not Type N) |
| **Rationale** | Product advertises `curl … \| sh` one-liner install; not-installed empty argv is install-ensure; **installed** empty argv is domain run (not help, not install no-op) |

Type N (non-online-install → empty argv = help) does **not** apply to this product.

It defines what happens when the tool is invoked with **no command and no flags**, including the classic one-liner:

```sh
curl -fsSL https://raw.githubusercontent.com/Wilgat/springboot2/main/springboot2 | bash
```

Empty argv detect cases:

| Case | Meaning | Empty-argv outcome (this product) |
|------|---------|-----------------------------------|
| **Not installed** | No managed binary at the resolved install path(s) | Install-ensure |
| **Installed (local)** | Managed binary at the user path (`USER_BIN` / `${HOME}/.local/bin/springboot2`) | **Domain run** (hybrid supersession) |
| **Installed (global)** | Managed binary at the global path (`GLOBAL_BIN` / `/usr/local/bin/springboot2`) | **Domain run** (hybrid supersession) |

**Scope:** Empty-argv routing, detect cases (global / local / absent), hybrid install vs domain run, force boundary, exit status, interaction with TTY / quiet / json.  
**Out of scope (own requirements):** Full command catalog (`requirement-shell-cli-interface.md`); domain pipeline depth (`requirement-springboot2-domain.md`); download/checksum detail (`requirement-shell-automatic-checksum.md`); full self-update/uninstall lifecycle (`requirement-shell-self-management.md`); output function catalog (`requirement-shell-output-requirements.md`); general idempotency matrix beyond empty-argv rows (`requirement-shell-idempotency.md`).

---


### Identity SSOT (this product — do not diverge)

| Field | Live value (ship unit `./springboot2`) |
|-------|----------------------------------------|
| **APP_NAME** | `springboot2` |
| **VERSION** | `2.0.1` |
| **REPO_USER** / **REPO_NAME** | `Wilgat` / `springboot2` |
| **SCRIPT_URL** | `https://raw.githubusercontent.com/Wilgat/springboot2/main/springboot2` |
| **Shebang / runtime** | `#!/bin/bash` (SDKMAN requires bash) |
| **Dispatcher** | `main_spring_boot_app` (not seed `app_main`) |
| **Output SSOT** | `output_text` / `output_json` / `output_json_error` (+ wrappers `info`/`success`/`warn`/`error`/`die`) |
| **Install SSOT** | `perform_self_install` / `maybe_install` / `is_installed` / `get_installed_version` |

Live scalars are owned by the ship unit Config block. Requirement **cores** stay portable; **Implementation Notes** must match the table above. On conflict with Config, use product identity protocol (ask; do not invent dual owners). Domain Spring Boot ops (`setup_sdkman`, `setup_java`, `setup_maven`, `setup_springboot_project`, `build_and_run`) are **in addition** to Type 0 lifecycle.

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Definitions (portable + project)

| Term | Definition for springboot2 |
|------|----------------------------|
| **Type O** | Online-install empty-argv product type: empty argv = install-ensure (this product). |
| **Type N** | Non-online-install empty-argv type: empty argv = help — **out of scope** for springboot2. |
| **Empty argv / zero-arg** | `$# -eq 0` at entry to `main_spring_boot_app` (no command tokens; classic `curl \| sh` with no trailing args). |
| **Install-ensure** | Converge to “managed `springboot2` binary present”; either perform install or success no-op. |
| **Not installed** | `is_installed` returns false (`get_installed_version` → `not installed`). |
| **Installed (local)** | Executable at `${USER_BIN}/springboot2` (default `USER_BIN=${HOME}/.local/bin`) observed by install-detect SSOT. |
| **Installed (global)** | Executable at `${GLOBAL_BIN}/springboot2` (default `GLOBAL_BIN=/usr/local/bin`) observed by install-detect SSOT. |
| **Force / reinstall** | `FORCE_REINSTALL=1` from `--force` (and related force wiring in `main_spring_boot_app`). Required only for deliberate replace, not for ensure. |

### 2.2 Single meaning of empty argv (hybrid)

1. When **argv is empty** and the tool is **not installed**, `main_spring_boot_app` **MUST** run **install-ensure** — **MUST NOT** route to `show_spring_boot_help`.  
2. When **argv is empty** and the tool is **installed**, `main_spring_boot_app` **MUST** run **domain default** (`cmd=run` / setup + optional `build_and_run`) — **MUST NOT** treat that path as install-ensure-only success no-op, and **MUST NOT** dump help. Full domain law: `requirement-springboot2-domain.md`.  
3. Explicit `springboot2 help` remains the only full-usage path for help text.  
4. Bootstrap **MUST** always call `main_spring_boot_app "$@"` so pipe one-liners reach this contract (no `${0##*/}` product-name gate).  
5. Empty argv **MUST NOT** require the user to pass `install` or `install --force` merely because a previous install already succeeded (installed re-runs go to domain, not “you must force install”).

### 2.3 Normative case matrix

| Case | Detect condition (project) | Empty argv, force off (this product) | Empty argv / deliberate install force |
|------|----------------------------|--------------------------------------|---------------------------------------|
| **A. Not installed** | `is_installed` false | Install into privilege-correct path (§2.4) | Same first-time install |
| **B. Installed — local** | User binary present via detect SSOT | **Domain run** (hybrid supersession) — **no help**; **not** portable “install no-op only” | Explicit install/`self-update`/`--force` reinstall policy owns binary replace — not bare empty argv |
| **C. Installed — global** | Global binary present via detect SSOT | **Domain run** (hybrid supersession) — **no help**; **not** portable “install no-op only” | Same as B for deliberate reinstall paths |

**Portable Type O “already-installed = install no-op”** remains a useful seed pattern for pure lifecycle CLIs. **This product soft-supersedes Cases B/C force-off columns** with domain run (banner at top). Do not claim pure install no-op as Implemented for installed bare `springboot2`.

**Already-installed rules (Cases B and C, empty argv, force off) — hybrid:**

1. **MUST NOT** dump full help.  
2. **MUST** enter domain pipeline (default `run`) per live `main_spring_boot_app` and `requirement-springboot2-domain.md`.  
3. Binary reinstall is **not** implied by empty argv alone; use `self-update` / force install policy when deliberate replace is needed.  
4. Detect **MUST** treat either global or local managed binary as installed when that is how `is_installed` / `get_installed_version` resolve paths (project SSOT today prefers global when executable there, else user path).  
5. Exit status and messaging for domain run follow domain + output requirements (build/run may long-run / exec; `--no-run` may exit 0 after setup).

### 2.4 Case A — not installed (modes)

| Mode | Required empty-argv behavior |
|------|------------------------------|
| **Interactive** (TTY stdin+stdout, not quiet/json) | `maybe_install`: note + `prompt_yes_no`; yes → `perform_self_install`; no → skip without help dump |
| **Non-interactive** (non-TTY / `curl \| sh`) | Auto-install message + `perform_self_install` (via `maybe_install` non-TTY branch) |
| **Quiet or JSON** | `perform_self_install` directly (no prompt) |
| **Failure** (network, checksum, I/O) | Non-zero exit; no fake success; no help-only output |

**Placement privilege:**

| Invoker | Target |
|---------|--------|
| root (`id -u` 0), e.g. `curl … \| sudo bash` | `${GLOBAL_BIN}/springboot2` → `/usr/local/bin/springboot2` |
| non-root | `${USER_BIN}/springboot2` → `${HOME}/.local/bin/springboot2` |

### 2.5 Equivalence / non-equivalence

| Invocation | Contract (this product) |
|------------|-------------------------|
| Empty argv, not installed | Install-ensure (Case A) — same as first-time install path |
| Empty argv, installed | **Domain run** — **not** equivalent to install no-op |
| Explicit install / force install | Deliberate binary ensure/replace (when/if routed) |
| `self-update` | Lifecycle binary upgrade (self-management) |
| `help` | Usage only — **not** empty-argv default |

### 2.6 Forbidden empty-argv outcomes

1. Dump full help when Case B or C applies.  
2. Silent success when Case A should install.  
3. Treat Case B/C empty argv as install-ensure-only no-op (portable seed) while claiming live product compliance — hybrid supersession requires domain run.  
4. Require `--force` solely because detect says installed (for normal re-run / domain use).  
5. Blind re-download every empty-argv run without force.  
6. Basename-gate main so `curl \| sh` never hits the empty-argv / auto-install branch.  
7. Detect only one of global/local incorrectly so a present local install is treated as Case A (or the reverse) contrary to `is_installed` family SSOT.

### 2.7 Implementation Notes (this project)

| Item | Value for springboot2 |
|------|------------------------|
| **Empty-argv type** | **Type O — Online-install** (install-ensure; not Type N help-default) |
| **Product / binary** | `springboot2` (`APP_NAME`) |
| **Ship unit** | Repo root `./springboot2` |
| **Dispatcher** | `main_spring_boot_app` — empty-argv block **before** flag/command parse default help |
| **Install ensure** | `perform_self_install` (quiet/json and already-installed no-op) |
| **Friendly first install** | `maybe_install` (TTY confirm / non-TTY auto) when not installed and not quiet/json |
| **Detect SSOT** | `is_installed` ← `get_installed_version` |
| **Global path** | `GLOBAL_BIN` default `/usr/local/bin` |
| **Local path** | `USER_BIN` default `${HOME}/.local/bin` |
| **Force wiring** | `--force` → `FORCE=1` and `FORCE_REINSTALL=1` in `main_spring_boot_app` |
| **Output SSOT** | `success` / `info` / `output_json` / errors via `output_*` |
| **Channel** | `SCRIPT_URL` (compose from `REPO_USER` / `REPO_NAME` / `APP_NAME`) for download path inside install |
| **Tests** | `tests/test_cli.sh` (Case A failure when not installed); `tests/test_install_lifecycle.sh` (Case B local + Case C global already-installed → not help) |

#### Dispatcher algorithm (normative sketch)

```text
main_spring_boot_app:
  if [ $# -eq 0 ]; then
    if JSON or QUIET:
      perform_self_install; exit $?
    elif is_installed:
      perform_self_install   # Case B/C success no-op
      exit $?
    else
      maybe_install     # Case A
      exit $?
    fi
  fi
  # else parse flags/commands; default COMMAND=help only when argv non-empty and command is help/absent token rules
```

#### Message contract (already installed, human)

- Success: `${APP_NAME} is already installed.` (or equivalent via `success`)  
- Optional info: force / `self-update` only for deliberate reinstall or upgrade  
- **MUST NOT** print the full `show_spring_boot_help` usage body on this path

### 2.8 Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 1 – Caution** (https://github.com/cloudgen/ciao): One-liner re-runs must not look like broken install or force unnecessary reinstall.  
- **CIAO Principle 2 – Intentional** (https://github.com/cloudgen/ciao): Empty argv has one meaning for not-installed, local, and global.  
- **CIAO Principle 3 – Anti-fragile** (https://github.com/cloudgen/ciao): Dual install paths + `curl \| sh` + TTY.  
- **CIAO Principle 5 – Single point of entry** (https://github.com/cloudgen/ciao): `main_spring_boot_app` owns empty-argv before help default.  
- **CIAO Principle 14 – Interactive vs non-interactive** (https://github.com/cloudgen/ciao): Case A auto under pipe; optional TTY confirm.  
- **CIAO Principle 18 – Over-protect** (https://github.com/cloudgen/ciao): Protection Rule against help-fallback regression.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** Real failures non-zero; healthy re-runs success with clear text.  
- **Intentional:** Help is never the empty-argv default for this install CLI.  
- **Anti-fragile:** Global and local detect; idempotent second one-liner.  
- **Over-protect:** Do not “simplify” empty-argv back to `COMMAND:=help` after first install.  
- **SSOT:** `is_installed` / `perform_self_install` / `maybe_install` / `output_*`.  
- **Idempotent ensure:** Case B/C force off → already installed, exit 0.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Route empty argv to `show_spring_boot_help` when Case B or C applies (or when Case A should install).  
2. Require `--force` for a healthy already-installed empty-argv re-run (local or global).  
3. Handle only Case A and leave B/C as accidental help fallthrough.  
4. Break dual-path detect so local or global installs are misclassified.  
5. Blindly reinstall on every empty-argv run without `FORCE_REINSTALL`.  
6. Exit 0 with no install and no already-installed acknowledgment when detect says installed.  
7. Reintroduce a basename-only gate that skips `main_spring_boot_app` under `curl \| sh`.  
8. Bypass `output_*` for empty-argv user messages.  
9. Contradict this file in peer requirements by documenting “already installed → help” as normative empty-argv behavior.

**Violating this rule is a critical zero-arg / online-install regression.**

---

## 5. Definition of done

This requirement is satisfied when all of the following hold:

1. Empty argv + not installed → Case A install path (TTY may confirm; non-TTY / quiet / json auto).  
2. Empty argv + local install present + force off → already-installed success; not help; no re-download.  
3. Empty argv + global install present + force off → already-installed success; not help; no re-download.  
4. Empty argv + install failure → non-zero exit.  
5. `--force` only for deliberate reinstall; not required for ensure.  
6. `help` works when invoked explicitly.  
7. Tests cover Case A failure (not installed, bad channel) and already-installed not-help for local (Case B) and global (Case C).  
8. Changes cite `requirement-shell-cli-zero-arguments`.

---

## 6. Related artifacts

| Artifact | Role |
|----------|------|
| `docs/requirements/requirement-shell-cli-interface.md` | Full command surface; empty-argv row must match this SSOT |
| `docs/requirements/requirement-shell-idempotency.md` | Ensure re-run / force boundary |
| `docs/requirements/requirement-shell-interactive-vs-noninteractive.md` | TTY vs pipe for Case A |
| `docs/requirements/requirement-shell-self-management.md` | self-update / uninstall (not empty-argv default) |
| `docs/requirements/requirement-shell-output-requirements.md` | output_* / JSON purity |
| `docs/requirements/requirement-shell-automatic-checksum.md` | Integrity on install download path |
| `docs/requirements/requirement-springboot2-domain.md` | Domain pipeline for installed empty argv / `run` |
| Repo root `./springboot2` | Implementation (`main_spring_boot_app`, `perform_self_install`/`is_installed` family) |
| `tests/test_cli.sh`, `tests/test_install_lifecycle.sh` | Regression coverage (may be phantom until real tests exist) |

---

## 7. Revision history

| Date | Change | Author / agent |
|------|--------|----------------|
| 2026-07-14 | Initial Active v1.0.0: empty argv = install-ensure for not-installed / local / global; forbid help fallthrough | Grok (owner request) |
| 2026-07-14 | v1.1.0: Classify product as Type O (online-install) under dual-type empty-argv template model | Grok |
| 2026-07-15 | v1.2.0: Promote hybrid supersession banner to top; soft-supersede portable Cases B/C force-off as domain run; cite domain requirement | Grok (authorized 1–3) |


### Empty argv specialization (springboot2 — domain Type O hybrid)

Normative summary lives in the **Hybrid supersession** banner at the top of this file and in §2.2–2.3. Condensed matrix:

| Situation | Required behavior for **this** product |
|-----------|----------------------------------------|
| **Not installed** + empty argv | Install-ensure (`maybe_install` / `perform_self_install`) |
| **Installed** + empty argv | **Domain default `cmd=run`**: SDKMAN/Java/Maven/project setup + `build_and_run` (not install no-op) — `requirement-springboot2-domain.md` |
| **Installed** + explicit lifecycle cmds | `version`, `version-check`, `self-update`, `self-uninstall`, `about`, `help` as dispatched |
| **Flags** | `--project-dir`, `--no-run`, `--force`, `--force-user`, `--force-root`, `--json`, `--quiet` |

Portable Type O “already installed = install-ensure success no-op” is **superseded for installed empty argv** by domain run. First-install / pipe path remains install-ensure. Do not claim seed-product empty-argv matrix as Implemented for installed bare `springboot2`.
