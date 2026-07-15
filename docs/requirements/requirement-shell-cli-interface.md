**file**: docs/requirements/requirement-shell-cli-interface.md  
**Status**: Active (Version 1.0.0)  
**Philosophy**: CIAO / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered)

## 1. Purpose

This requirement is the **project Single Source of Truth** for the **POSIX shell CLI interface** of the springboot2 tool: command surface, privilege typing, global flags, dispatcher behavior, output modes, and interactive vs non-interactive rules.

It defines a **Type 0–centric self-managed shell CLI** (install / update / uninstall of the tool itself). It does **not** invent Type 1 host-bootstrap or Type 2 system-user app-ops commands unless a future requirement adds them.

**Scope:** User-facing command names, flags, dispatch, privilege labels, and mode contracts.  
**Out of scope (own requirements when specialized):** Online-install checksum mechanics detail, self-management safety beyond the command surface, shell coding style, full output-function catalog (cited, not re-owned).

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

### 2.1 Command surface (portable shape)

Every CIAO-Lite shell CLI **MUST** expose a documented command set. Commands **MUST** map to exactly one privilege type. Unclassified commands are incomplete design.

| Category | Privilege | Meaning | Portable examples |
|----------|-----------|---------|-------------------|
| **Type 0 – Self-management / CLI lifecycle** | Invoking user (no elevation required for user-owned install) | Manage the CLI binary and diagnostics | `version`, `about`, `help`, `version-check`, `self-update`, `self-uninstall` |
| **Type 0 – Install CLI binary** | Invoking user (root → global path; non-root → user path) | First-time or explicit placement of the CLI | `install`; empty argv **Type O install-ensure** (not installed / local / global) — `requirement-shell-cli-zero-arguments.md` |
| **Type 1 – Host preparation** | Elevated (internal escalation when designed) | Host packages, system user create, Docker engine | *Not in scope for current product surface* |
| **Type 2 – App ops under system user** | Dedicated least-privilege system user | App install/configure/runtime under app identity | *Not in scope for current product surface* |

**Execution rules (core):**

1. Type 0 commands **MUST** run as the invoker without requiring a dedicated system user.
2. Type 1 (when added later) **MUST** use controlled internal escalation; normal users **MUST NOT** be forced to manually prefix every privileged sub-step as a permanent UX rule.
3. Type 2 (when added later) **MUST** run as the dedicated system user (context switch if needed). Mixing Type 1 host bootstrap with Type 2 app toolchain in one command is forbidden (see incident policy under system-user / three-layer privilege terms).
4. Privilege type for each command **MUST** be documented in help and in this requirement’s Implementation Notes.

### 2.2 Global flags (portable)

| Flag | Env / state | Behavior |
|------|-------------|----------|
| `--quiet`, `-q` | `QUIET=1` | Suppress non-error human output; errors and fatal paths still visible |
| `--json` | `JSON=1` (implies quiet) | Machine-readable structured output; no human banner text |
| `--debug` | `DEBUG=1` | Extra diagnostics when designed (must not break JSON purity on stdout) |
| `--force` | Force/reinstall policy vars | Skip safe confirms or force reinstall only where documented; never silent security bypass |

Additional flags **MAY** be added only when documented here (or a superseding requirement) and wired in the dispatcher.

### 2.3 Dispatcher and entry rules (portable)

1. **Single entry:** A single main dispatcher (e.g. `main_spring_boot_app`) **MUST** parse global flags and route commands.
2. **Unknown command:** **MUST** fail loudly with a clear error and pointer to `help` (via output SSOT).
3. **Zero-arg install-ensure:** Empty argv **MUST** mean install-ensure (not help). Not installed → install (TTY may confirm; non-interactive / quiet / json auto). Already installed (global or local) → success no-op (“already installed”), not help and not blind reinstall. Full contract: `requirement-shell-cli-zero-arguments.md`.
4. **Idempotent install skip:** Install **MUST** no-op when already installed unless force/reinstall policy is set.
5. **No raw user I/O:** User-facing messages **MUST** go through the centralized `out_*` system (see output template/term).

### 2.4 Output and mode contracts (portable)

| Mode | Contract |
|------|----------|
| Human (default TTY) | Prefixed messages via Output SSOT; colors only when TTY and not quiet/json |
| Quiet | Suppress info/success/plain noise; still show errors / fatal |
| JSON | Force quiet; emit structured JSON via `output_json` / `output_json_error`; no mixed human lines on success path |
| Non-interactive | Never hang on prompts; use safe defaults or `--force`/env policy |

Destructive Type 0 actions (e.g. uninstall) **MUST** confirm when interactive unless force policy is set; non-interactive **MUST NOT** block on stdin.

### 2.5 Help surface (portable)

`help` **MUST** list:

- Usage line  
- Every supported command with one-line purpose  
- Privilege category (at least Type 0 vs elevated vs system-user when those exist)  
- Global flags  

In JSON mode, help **MUST NOT** dump long human text; return a short structured success/note object instead.

### 2.6 Implementation Notes (this project)

| Item | Value for springboot2 |
|------|------------------------|
| **Product / binary name** | `springboot2` (`APP_NAME`, default `springboot2`) |
| **Primary executable** | Repo root `./springboot2` (bash `#!/bin/bash`, single-file for `curl \| sh`) |
| **Dispatcher** | `main_spring_boot_app` (always invoked at end of script: `main_spring_boot_app "$@"` — no `${0##*/}` / APP_NAME basename gate; required for `curl \| sh`) |
| **Output SSOT** | `output_text` + wrappers (`info`, `success`, `warn`, `error`, `die`, `plain`, `output_json`, …) |
| **Version SSOT** | `VERSION` default `2.0.1` (script header / config block: `VERSION="2.0.1"`) |
| **Install paths** | Global: `GLOBAL_BIN` default `/usr/local/bin`; User: `USER_BIN` default `${HOME}/.local/bin` |
| **Remote channel env (help surface)** | `REPO_USER` / `REPO_NAME` (defaults `Wilgat` / `springboot2`); `SCRIPT_URL` composed default `https://raw.githubusercontent.com/${REPO_USER}/${REPO_NAME}/main/${APP_NAME}` (literal product default: `https://raw.githubusercontent.com/Wilgat/springboot2/main/springboot2`; override via env). **`help` / `about` MUST list these operator channel vars as designed — MUST NOT list `CHECKSUM`** (install-path runtime pin only; see `requirement-shell-automatic-checksum.md`) |
| **Type 1 / Type 2 commands** | **None** on current surface — this tool is CLI lifecycle only |
| **Dedicated system user** | **Not required** for Type 0 CLI self-management |

#### Supported commands (normative for this project)

| Command | Type | Handler (current) | Required behavior |
|---------|------|-------------------|-------------------|
| *(no args — empty argv)* | Type 0 | `main_spring_boot_app` → `maybe_install` / `perform_self_install` | **Type O install-ensure** (not Type N help): not-installed / local / global; never help; see `requirement-shell-cli-zero-arguments.md` |
| `install` | Type 0 | `perform_self_install` | Install binary for current privilege (root→global, user→local); idempotent unless force reinstall |
| `version` | Type 0 | `main_spring_boot_app` / version dispatch in `main_spring_boot_app` | Print local version; JSON object when `--json` |
| `about` | Type 0 | `show_about_spring_boot_app` | Diagnostics: install presence, global/local paths, user, shell, TTY; JSON when `--json`; **no `CHECKSUM` field** |
| `version-check` | Type 0 | `version_check` | Compare local vs remote `VERSION` from `SCRIPT_URL`; fail clearly if URL unset/unreachable |
| `self-update` | Type 0 | `self_update` | Fetch remote version; reinstall when policy allows; reuse install primitives |
| `self-uninstall` | Type 0 | `self_uninstall` | Remove managed binary; PATH cleanup only if `~/.local/bin` empty (user installs) |
| `help` | Type 0 | `show_spring_boot_help` | Full usage in human mode; short JSON note in JSON mode; Environment lists channel vars only — **not** `CHECKSUM` |

#### Global flags (normative wiring for this project)

| Flag | Required wiring |
|------|-----------------|
| `--quiet`, `-q` | Set `QUIET=1` in `main_spring_boot_app` |
| `--json` | Set `JSON=1` and `QUIET=1` in `main_spring_boot_app` |
| `--debug` | Set `DEBUG=1` in `main_spring_boot_app` |
| `--force` | Parsed by `main_spring_boot_app` → `FORCE=1` and `FORCE_REINSTALL=1`; used by install reinstall, self-update (incl. deliberate downgrade), and uninstall confirm skip |

#### Dispatcher acceptance criteria (this project)

1. Unknown token after flag parse → `die` with pointer to `springboot2 help`.  
2. Zero-arg → install-ensure: not installed → install; already installed (local or global) → already-installed success (not help); failures non-zero.  
3. Command routing table in `main_spring_boot_app` **must** include every row in the command table above.  
4. Help text **must** stay aligned with that table (no orphan commands, no listed-but-unrouted commands).  
5. User-facing strings **must not** use raw `echo`/`printf` outside Output SSOT (protected low-level helpers excepted only if already CIAO-marked and not for general messages).

#### Explicitly out of scope until a new requirement

- Type 1: `prerequisites`, `create-user`, Docker host install, etc.  
- Type 2: app `start`/`stop`/`configure` under a system user  
- Domain product subcommands unrelated to CLI lifecycle  

### 2.7 Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 1 – Caution** (https://github.com/cloudgen/ciao): Unknown commands fail loud; force and prompts gate destructive ops; quiet/json never hide fatal errors incorrectly.  
- **CIAO Principle 2 – Intentional** (https://github.com/cloudgen/ciao): Every command has one privilege type, one handler, and documented flags.  
- **CIAO Principle 3 – Anti-fragile** (https://github.com/cloudgen/ciao): Works under TTY, `curl | sh`, quiet, and JSON; root vs user install paths.  
- **CIAO Principle 4 / 12 – Single source of output & security/traceability** (https://github.com/cloudgen/ciao): Central `out_*`; JSON/human separation.  
- **CIAO Principle 5 – Single point of entry** (https://github.com/cloudgen/ciao): `main_spring_boot_app` is the dispatcher SSOT.  
- **CIAO Principle 8 – Least-privilege user** (https://github.com/cloudgen/ciao): Type 0 default for CLI self-care; no invented system-user requirement for binary lifecycle.  
- **CIAO Principle 14 – Interactive vs non-interactive** (https://github.com/cloudgen/ciao): No hang in non-interactive; prompts only when appropriate.  
- **CIAO Principle 18 – Over-protect** (https://github.com/cloudgen/ciao): Protection Rule below blocks privilege and UX regressions.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** Fail loud on bad input; never silent wrong privilege context.  
- **Intentional:** Command table + help + dispatcher stay synchronized.  
- **Anti-fragile:** Per-user and global install; network/remote optional until `SCRIPT_URL` set.  
- **Over-protect:** Do not collapse Type 0/1/2, remove JSON quiet contract, or reintroduce raw output for user messages.  
- **SSOT:** `APP_NAME` / `VERSION` / flags at config defaults; output via Output SSOT; dispatch via `main_spring_boot_app`.  
- **Idempotency:** Already-installed install path is a no-op unless force reinstall.  
- **Respect old working logic:** Surgical changes only; preserve Protection Zones and battle-tested install/self-management helpers unless explicitly redesigning.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Remove or rename the normative Type 0 commands without updating this requirement and help together.  
2. Add Type 1 or Type 2 commands that mix host bootstrap with app toolchain in a single privileged install (three-layer privilege: Type 0 tool self-management must stay separate from Type 1 host bootstrap and Type 2 system-user app ops).  
3. Force manual `sudo` as the only UX for every elevated sub-step when internal escalation is the designed pattern (when Type 1 is introduced).  
4. Bypass Output SSOT with raw user-facing `echo`/`printf` for normal messages.  
5. Break the contract that `--json` implies quiet and machine-oriented output.  
6. Drop zero-arg install-ensure for the classic `curl | sh` path (including already-installed success no-op) without an explicit requirement change (`requirement-shell-cli-zero-arguments.md`).  
7. Document flags in help that the dispatcher does not parse (or leave `--force` documented-only).  
8. Invent a dedicated system user as mandatory for Type 0 CLI self-management without a specialized architecture requirement.

**Violating this rule is a critical CLI interface regression.**

---

## 5. Definition of done (CLI interface)

This requirement is satisfied for the springboot2 shell CLI when all of the following hold:

1. Every command in §2.6 is routed and documented.  
2. Global flags in §2.6 are parsed and honored.  
3. Output modes match §2.4 (including JSON purity).  
4. Install privilege paths remain invoker-based (root/global vs user/local).  
5. No Type 1/2 surface claims exist without matching specialized requirements.  
6. Protection Rule items are not violated in code or docs.  
7. Traceability: implementation changes cite this file path / key `requirement-shell-cli-interface`.

---

## 6. Related artifacts

| Artifact | Role |
|----------|------|
| `docs/requirements/requirement-shell-self-management.md` | Lifecycle command semantics |
| `docs/requirements/requirement-shell-output-requirements.md` | Output SSOT and channels |
| `docs/requirements/requirement-shell-interactive-vs-noninteractive.md` | TTY / automation mode behavior |
| `docs/requirements/requirement-shell-cli-zero-arguments.md` | Empty argv install-ensure (not installed / local / global) |
| `docs/requirements/requirement-shell-idempotency.md` | Re-run safety for ensure ops |
| `docs/requirements/requirement-shell-modular-function-design.md` | Prefix ownership (`app_`, `inst_`, `out_*`) |
| `docs/requirements/index.md` | Registry SSOT |
| `./springboot2` | Implementation under test |

---

**Last Updated**: 2026-07-12  
**Owner**: springboot2 project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; CIAO Principles 1, 2, 3, 5, 8, 14, 18 (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).


**Empty argv (this product):** See `requirement-shell-cli-zero-arguments.md` § Empty argv specialization — installed empty argv is **domain run**, not install-ensure no-op.


### Live function inventory (ship unit — not seed prefixes)

**Product law inventory** (live `./springboot2` — §3.1 option 2; not seed `out_*`/`inst_*`/`app_*`):

| Area | Live names |
|------|------------|
| Output | `output_text`, `output_json`, `output_json_error`, `info`, `success`, `warn`, `error`, `die`, `plain`, `msg`, `msg_n` |
| Install / lifecycle | `perform_self_install`, `maybe_install`, `is_installed`, `get_installed_version`, `get_install_bin_path`, `self_update`, `self_uninstall`, `version_check`, `version_gt` |
| Dispatch | `main_spring_boot_app`, `show_spring_boot_help`, `show_about_spring_boot_app` |
| Domain | `setup_sdkman`, `setup_java`, `setup_maven`, `setup_springboot_project`, `build_and_run`, `check_alpine_requirements` |
| PATH | `add_to_shell_path`, `in_path`, per-shell helpers as present |

Compliance claiming seed-prefix inventory as Implemented is **false** until rename or notes mark **target vs live**.


### Domain surface (this product)

In addition to Type 0 lifecycle, **springboot2** exposes domain setup/run:

| Command / flag | Behavior (live) |
|----------------|-----------------|
| empty argv when installed / `run` | Setup env + project + build/run |
| `--project-dir <path>` | Project directory |
| `--no-run` | Setup only |
| `--reset` | Documented in help/README; verify dispatcher coverage on disk |
| `status` / `reinstall` | May appear in help — **Gap** if not routed in `main_spring_boot_app` |
| `install` subcommand | **Not** a separate case; auto-install when not installed + empty argv |

Type 0-only “no domain” claims are **not** sufficient product law for this ship unit.
