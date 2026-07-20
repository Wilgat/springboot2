**file**: docs/requirements/requirement-shell-modular-function-design.md  
**Status**: Active (Version 1.0.0)  
**Philosophy**: CIAO / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered)

## 1. Purpose

This requirement is the **project Single Source of Truth** for **modular function organization** of the springboot2 bash shell CLI.

It defines modular function organization for a **monolithic yet modular** single-file shell tool that remains `curl | sh` compatible.

**Scope:** Function prefixes, documentation headers, Protection Zones, single-file modularity, SSOT ownership by prefix, surgical change rules.  
**Out of scope (cited, not re-owned):** Command surface (`requirement-shell-cli-interface.md`); self-management behavior (`requirement-shell-self-management.md`); idempotency matrix (`requirement-shell-idempotency.md`); full POSIX coding style beyond modular structure.

**Core idea:** Modularity is achieved through **clear function boundaries, consistent prefixes, and full CIAO documentation** — **not** by splitting the main CLI into multiple shipped files.

---


### Identity SSOT (this product — do not diverge)

| Field | Live value (ship unit `./springboot2`) |
|-------|----------------------------------------|
| **APP_NAME** | `springboot2` |
| **VERSION** | `2.3.1` |
| **REPO_USER** / **REPO_NAME** | `Wilgat` / `springboot2` |
| **SCRIPT_URL** | `https://raw.githubusercontent.com/Wilgat/springboot2/main/springboot2` |
| **Shebang / runtime** | `#!/bin/bash` (SDKMAN requires bash) |
| **Dispatcher** | `app_main` (A naming) |
| **Output SSOT** | `out_text` / `out_json` / `out_json_error` (+ wrappers `out_info`/`out_success`/`out_warn`/`out_error`/`out_die`) |
| **Install SSOT** | `inst_perform_install` / `inst_maybe_install` / `inst_is_installed` / `inst_get_version` |

Live scalars are owned by the ship unit Config block. Requirement **cores** stay portable; **Implementation Notes** must match the table above. On conflict with Config, use product identity protocol (ask; do not invent dual owners). Domain Spring Boot ops (`setup_sdkman`, `setup_java`, `setup_maven`, `setup_springboot_project`, `run_springboot_project`) are **in addition** to Type 0 lifecycle.

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Overall architecture (portable)

CIAO-Lite shell CLIs distributed as one-liners **MUST** use:

| Rule | Meaning |
|------|---------|
| **Single executable** | One primary script file for the installable CLI (required for `curl \| sh`) |
| **Logical modules** | Functions grouped by **strict prefixes**, not by separate runtime files |
| **Documented units** | Every public helper carries a defensive header and safe defaults |
| **Requirements extract policy** | Durable rules live in `requirement-*.md`; code comments encode intent and Protection Zones |

Optional multi-file layout under `src/` for future authoring **MAY** exist only if a build or pack step still produces **one** installable artifact and this requirement is updated. Until then, `./springboot2` remains the single shipped script.

### 2.2 Official function families (this product — §3.1 option 1 A naming)

**Naming law:** Product helpers **MUST** use bootstrap A (`selfmanaged`) **prefix families**. Live ship unit is SSOT for *which* helpers exist; **prefixes** align to A.

**Normative prefix families (live `./springboot2`):**

| Prefix | Category | Purpose | Normative live names |
|--------|----------|---------|----------------------|
| `out_` | Output SSOT | All user/machine product output | `out_text`, `out_json`, `out_json_error`, `out_info`, `out_success`, `out_warn`, `out_error`, `out_die`, `out_plain`, `out_msg_n`, `out_empty_line`, `out_double_line` |
| `inst_` | Install & self-management | Install, update, uninstall, detect | `inst_perform_install`, `inst_maybe_install`, `inst_is_installed`, `inst_get_version`, `inst_self_update`, `inst_self_uninstall` |
| `app_` | CLI surface | Entry, help, about | `app_main`, `app_help`, `app_about` |
| `ver_` | Semver helpers | Compare / remote check | `ver_gt`, `ver_check` |
| `path_` | PATH integration | Profile PATH lines | `path_add_shell`, `path_in_path` |
| `util_` | Shared non-domain | Storage, hash, integrity, atomic write | `util_resolve_storage`, `util_source_user_shell_config`, `util_sha256_file`, `util_verify_download_integrity`, `util_write_file_atomic`, `util_get_install_bin_path` |
| `prompt_` | Interactive confirm | Yes/no | `prompt_yes_no` |
| `setup_` / domain | Spring Boot ops | Toolchain / project / run | `setup_*`, `check_alpine_requirements`, `run_springboot_project` |

**Strict naming rules (this product):**

1. New helpers **must** use a prefix from the table (or add a row here in the same change).  
2. User-facing messages **must** go through `out_*` only.  
3. Domain ops **must not** replace Type 0 lifecycle entry points (`inst_*` / `app_main`).  
4. Do **not** reintroduce pre-A bare names (`info`/`success`/`die`/`perform_self_install`/`main_spring_boot_app`) as product law.  
5. Prefer small, single-purpose functions; preserve Protection Zones.  
6. Shared non-domain helpers **SHOULD** use `util_*`.  
7. Domain setup = `setup_*`; domain run = `run_springboot_project`.  
8. One `app_main` entry; presentation helpers use `app_help` / `app_about`.  
9. Install stays under `inst_*` — no second parallel install stack.

### 2.2.1 Findings closure (prefix review P1–P7 → A rename)

| ID | Finding | Resolution (2026-07-15) |
|----|---------|-------------------------|
| **P1** | No single global prefix like bootstrap A | **Fixed** — adopted A prefixes (`out_`/`inst_`/`app_`/…) |
| **P2** | Bare wrappers outside `out_*` string | **Fixed** — wrappers are `out_info`/`out_success`/… |
| **P3** | Install not one prefix | **Fixed** — `inst_*` family |
| **P4** | Domain `setup_*` vs bare `build_and_run` | **Fixed** — `run_springboot_project` |
| **P5** | `main_*` vs `show_*` mix | **Fixed** — `app_main` / `app_help` / `app_about` |
| **P6** | Unprefixed util helpers | **Fixed** — `util_*` (storage, integrity, bin path, atomic write) |
| **P7** | Seed prefixes absent on disk | **Fixed** — live ship unit uses A prefixes |

### 2.3 Function documentation standards (mandatory)

Every non-trivial function **MUST** include a defensive header of this shape (trivial one-line wrappers may inherit documentation from their parent SSOT function, but still require the correct prefix).

#### 2.3.1 Product-source documentation authority

Optional `ALIGNMENT` / `See` / “fully synchronized with” lines in **product source** (`./springboot2`) **MUST** cite only **live** `docs/requirements/requirement-*.md` paths that exist on disk and appear in `docs/requirements/index.md`.

| Allowed in product source comments | Forbidden in product source comments |
|------------------------------------|--------------------------------------|
| Live `requirement-shell-*.md` (and other live `requirement-*.md` registered in `index.md`) | Non-requirement paths under `docs/` as product-law authority |
| Short incident IDs for lessons (optional; no required path) | Invented or stale `requirement-*.md` names |
| | Harness / template / skill filenames as ALIGNMENT targets |

Product-source law is only the live registry under `docs/requirements/`. Local workspace material outside this folder is not product-source authority (see INC-20260712-002).

```sh
# =============================================================================
# function_name() - Short one-line purpose
# =============================================================================
#
# GENERAL PURPOSE:
# Clear explanation of what this function does and why it exists.
#
# CIAO PRINCIPLES APPLIED:
# - Caution (Principle 1): ...
# - Intentional (Principle 2): ...
# - Anti-fragile (Principle 3): ...
# - Over-protect (Principle 18): ...
#
# !!! DO NOT MODIFY OR SIMPLIFY THIS FUNCTION !!!
# Designed to be reusable in other CIAO-Lite projects.
#
# Lessons Learned (CIAO Reflection):
# [Date]: [Short note when fixing regressions or improving defensive comments]
#
# Last reviewed: YYYY-MM-DD
# =============================================================================

function_name() {
    # --- Safe Variable Defaults ---
    : "${VAR:=default}"

    # Main logic...
}
```

**Mandatory elements for critical / reusable helpers:**

| Element | Rule |
|---------|------|
| GENERAL PURPOSE | States objective and why the function exists |
| CIAO principles | Filled meaningfully for non-trivial logic |
| DO NOT MODIFY / Protection intent | Present on reusable and security-sensitive helpers |
| Safe variable defaults | `: "${VAR:=default}"` at top of body for globals the function relies on |
| Lessons Learned | Add when fixing regressions; do not delete history |

### 2.4 Ownership and SSOT by family (this product)

| Concern | Owning live family | Rule |
|---------|-------------------|------|
| User-facing output | `out_*` | No raw user messages outside `out_*` |
| Install + CLI lifecycle | `inst_*` | One install orchestrator; self-update reuses it |
| Version compare / remote check | `ver_*` | Keep pure compare portable |
| PATH / shell profile | `path_add_shell` / `path_in_path` | Duplicate-safe append |
| CLI entry / dispatch | `app_main` | Single dispatcher; no second parallel main |
| Interactive confirm | `prompt_yes_no` | Non-interactive safe behavior |
| Domain product ops | `setup_*` / `run_springboot_project` | Domain only; not Type 0 replace |
| Shared utils | `util_*` | Non-domain helpers greppable by prefix; storage resolve owned with `requirement-shell-cli-storage` |

### 2.5 Surgical change and reuse rules (portable)

1. **Respect existing working functions** — high bar before rewriting protected helpers.  
2. **Surgical edits** — change the smallest function that fulfills the request; do not rewrite the whole script.  
3. **No merge for “cleanliness”** — do not collapse prefix boundaries or remove Protection Zones.  
4. **Reusable helpers** marked DO NOT MODIFY remain sacred unless the user explicitly redesigns them.  
5. **Duplicates** — if two functions with the same name exist, that is a defect; keep one authoritative definition.

### 2.6 Implementation Notes (this project)

| Item | Value for springboot2 |
|------|------------------------|
| **Product / binary** | `springboot2` (`APP_NAME`) |
| **Single shipped script** | Repo root `./springboot2` (bash `#!/bin/bash`; A prefixes + domain helpers — see Live function inventory) |
| **`src/` directory** | Present but empty — **not** a multi-file runtime layout yet |
| **Domain helpers** | Live domain uses `setup_*` / `run_springboot_project` (not `springboot2_*` prefix) |
| **Bootstrap** | Direct execution when `${0##*/}` is `springboot2` or `springboot2.sh` → `app_main "$@"` |

#### Live inventory (authoritative — §3.1 option 1 A naming + P1–P7 closed)

Re-read `./springboot2`. This table **is** product law:

| Area | Live examples |
|------|----------------|
| Output | `out_text`, `out_json`, `out_json_error`, `out_info`, `out_success`, `out_warn`, `out_error`, `out_die`, `out_plain`, `out_msg_n`, `out_empty_line`, `out_double_line` |
| Install / lifecycle | `inst_perform_install`, `inst_maybe_install`, `inst_is_installed`, `inst_get_version`, `inst_self_update`, `inst_self_uninstall` |
| Dispatch / UX | `app_main`, `app_help`, `app_about` |
| Version | `ver_gt`, `ver_check` |
| Domain | `setup_sdkman`, `setup_java`, `setup_maven`, `setup_springboot_project`, `run_springboot_project`, `check_alpine_requirements` |
| PATH / prompts | `path_add_shell`, `path_in_path`, `prompt_yes_no` |
| Util / integrity | `util_resolve_storage`, `util_source_user_shell_config`, `util_sha256_file`, `util_verify_download_integrity`, `util_write_file_atomic`, `util_get_install_bin_path` |

#### Structural notes

| Issue | Status |
|-------|--------|
| A prefixes `out_*`/`inst_*`/`app_*` | **Product law** — §3.1 option 1 |
| Thin wrappers (`out_success`, …) | **Required form** — only via `out_text` |
| Domain helpers | **Live** — `setup_*` + `run_springboot_project` |
| Dual-inventory debt | **Closed** — code + requirements use A names |
| Prefix review P1–P7 | **Closed** — §2.2.1 (renamed to A) |

#### New function checklist (this project)

When adding a function to `./springboot2`:

1. Choose the correct prefix from §2.2 / this inventory.  
2. Add the defensive header (full for non-trivial logic).  
3. Add safe variable defaults.  
4. Route user messages only through `out_*`.  
5. Do not introduce a second install or update path.  
6. Update this requirement’s inventory table if a **new** prefix category is introduced.  
7. Cite `requirement-shell-modular-function-design` in the change summary.

### 2.7 Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 1 – Caution** (https://github.com/cloudgen/ciao): Small, prefixed units with safe defaults reduce accidental cross-cutting edits.  
- **CIAO Principle 2 – Intentional** (https://github.com/cloudgen/ciao): Prefixes encode ownership; GENERAL PURPOSE encodes why.  
- **CIAO Principle 3 – Anti-fragile** (https://github.com/cloudgen/ciao): Focused functions can be reviewed and reused; single file survives minimal environments.  
- **CIAO Principle 5 – Single point of entry** (https://github.com/cloudgen/ciao): `app_main` is the dispatcher SSOT.  
- **CIAO Principle 6 – General purpose requirement** (https://github.com/cloudgen/ciao): Public helpers document GENERAL PURPOSE.  
- **CIAO Principle 7 – Reusable function protection** (https://github.com/cloudgen/ciao): DO NOT MODIFY on reusable helpers.  
- **CIAO Principle 18 – Over-protect** (https://github.com/cloudgen/ciao): Protection Zones and prefix table defend against AI “cleanup” regressions.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** Prefer additive helpers over rewriting protected orchestrators.  
- **Intentional:** Prefix = category; headers = intent; no mystery bare functions.  
- **Anti-fragile:** Monolithic ship unit + modular internals; works under `curl | sh`.  
- **Over-protect:** Never strip Protection Zones or merge categories for aesthetics.  
- **Simplicity but Safety:** Simplify only non-protected, non-security paths; keep intentional verbosity in headers.  
- **Surgical changes:** Edit the owning function; do not reformat the whole file casually.  
- **SSOT:** Output, install, version compare, and dispatch each have one owning family.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Merge functions or remove the prefix-based grouping system.  
2. Delete or weaken Protection Zones and `!!! DO NOT MODIFY OR SIMPLIFY THIS FUNCTION !!!` comments.  
3. Remove or hollow out GENERAL PURPOSE / CIAO PRINCIPLES APPLIED sections on protected helpers.  
4. Refactor the shipped CLI into multiple runtime files in a way that breaks `curl | sh` single-artifact install without an explicit redesign requirement.  
5. Violate the official function prefix table (including inventing bare `main`/`install`/`help`).  
6. Put domain product logic under dispatch/help entry, or bury Type 0 lifecycle under domain-only helpers without an explicit requirement change.  
7. Remove or weaken safe variable defaults at the top of functions.  
8. Introduce a second parallel dispatcher or a second install/update orchestrator “for clarity.”  
9. Leave duplicate function definitions with the same name as intentional design.  
10. Cite `template-*.md` or `skill-*.md` in product source as behavioral authority, or invent missing `requirement-*.md` paths in headers (§2.3.1).

**Modularity is prefixes + documentation + boundaries — not multi-file sprawl for the installable artifact.**

---

## 5. Definition of done (shell modular function design)

A modular-structure change for springboot2 is **not done** if any of the following fail:

1. Every new function uses an approved prefix from this requirement.  
2. Critical helpers retain defensive headers and Protection intent.  
3. The ship unit remains a single `curl | sh`-compatible script unless redesign is approved.  
4. Output remains under Output SSOT; install lifecycle under lifecycle helpers; dispatch under `app_main`.  
5. No bare unprefixed public functions introduced.  
6. Inventory / this requirement updated when a new prefix category is added.  
7. Duplicate same-name function definitions are not introduced (and known duplicates are scheduled for removal when touched).  
8. Changes cite `requirement-shell-modular-function-design`.  
9. Product source headers do not cite non-requirement docs as authority; any ALIGNMENT paths resolve under `docs/requirements/`.

---

## 6. Related artifacts

| Artifact | Role |
|----------|------|
| `docs/requirements/requirement-shell-cli-interface.md` | Command surface owned by `app_main` dispatch |
| `docs/requirements/requirement-shell-self-management.md` | Lifecycle owned by install/self_* helpers |
| `docs/requirements/requirement-shell-idempotency.md` | Re-run safety inside ensure helpers |
| `docs/requirements/requirement-shell-output-requirements.md` | `out_*` ownership |
| `docs/requirements/index.md` | Registry SSOT |
| `./springboot2` | Implementation under modular design rules |

---

**Last Updated**: 2026-07-12  
**Owner**: springboot2 project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; CIAO Principles 1, 2, 3, 5, 6, 7, 18 (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).


### Live function inventory (ship unit — A naming)

**Product law inventory** (live `./springboot2` — §3.1 option 1 (A naming); live `out_*`/`inst_*`/`app_*` (A naming)):

| Area | Live names |
|------|------------|
| Output | `out_text`, `out_json`, `out_json_error`, `out_info`, `out_success`, `out_warn`, `out_error`, `out_die`, `out_plain`, `out_plain`, `out_msg_n` |
| Install / lifecycle | `inst_perform_install`, `inst_maybe_install`, `inst_is_installed`, `inst_get_version`, `util_get_install_bin_path`, `inst_self_update`, `inst_self_uninstall`, `ver_check`, `ver_gt` |
| Dispatch | `app_main`, `app_help`, `app_about` |
| Domain | `setup_sdkman`, `setup_java`, `setup_maven`, `setup_springboot_project`, `run_springboot_project`, `check_alpine_requirements` |
| PATH | `path_add_shell`, `path_in_path`, per-shell helpers as present |

Compliance claiming seed-prefix inventory as Implemented is **false**. Live families above are product law (§3.1 option 1 (A naming); P1–P7 closed).
