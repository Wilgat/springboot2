**file**: docs/requirements/requirement-shell-cli-storage.md  
**Status**: Active (Version 1.0.0)  
**Philosophy**: CIAO / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered)

## 1. Purpose

This requirement is the **project Single Source of Truth** for **shell CLI storage resolution** of the springboot2 bash (`#!/bin/bash`) Type 0 CLI: volatile scratch and app-scoped cache path selection, per-user isolation, central resolver ownership, and failure messaging via Output SSOT.

**Scope:** Resolve priority chain; isolation; `util_resolve_storage` contract; data-return vs user messages; coupling notes vs install staging and domain project dirs.  
**Out of scope (cited, not re-owned):** Binary install paths (`USER_BIN` / `GLOBAL_BIN` — CLI / self-management); domain project tree (`PROJECT_DIR` / `setup_springboot_project` / `run_springboot_project` — domain requirement); companion checksum; PATH shell-rc; atomic publish algorithms beyond “stage same FS as FINAL when renaming.”

---

### Identity SSOT (this product — do not diverge)

| Field | Live value (ship unit `./springboot2`) |
|-------|----------------------------------------|
| **APP_NAME** | `springboot2` |
| **VERSION** | `2.0.1` |
| **REPO_USER** / **REPO_NAME** | `Wilgat` / `springboot2` |
| **SCRIPT_URL** | `https://raw.githubusercontent.com/Wilgat/springboot2/main/springboot2` |
| **Shebang / runtime** | `#!/bin/bash` |
| **Dispatcher** | `main_spring_boot_app` (not seed `app_main`) |
| **Output SSOT** | `output_text` / `output_json` / `output_json_error` (+ wrappers) |
| **Storage resolver** | `util_resolve_storage` |
| **Fallback Config** | `STORAGE_DIR="${XDG_CACHE_HOME}/${APP_NAME}-${USERNAME}"` (with `XDG_CACHE_HOME` / `HOME` defaults) |

Live scalars are owned by the ship unit Config block. On conflict with Config, use product identity protocol (ask; do not invent dual owners).

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Single resolver SSOT

1. **MUST** keep **one** authoritative storage-resolve helper: live name **`util_resolve_storage`**.  
2. New code that needs a product scratch/cache **root** **MUST** call `util_resolve_storage` (or `mktemp` under a path it returned) — **MUST NOT** introduce parallel hard-coded `/tmp/springboot2` or bare `/dev/shm` dumps.  
3. Resolver **MUST** print the chosen directory path on **stdout** for `$(util_resolve_storage)` capture (data return — not product UI).  
4. User-visible failure/warn about storage **MUST** use Output SSOT (`die` / `error` / `warn` / JSON error as mode requires).

### 2.2 Live resolve priority (normative for this product)

First match that is available and writable:

| Order | Condition | Path shape |
|-------|-----------|------------|
| 1 | `/dev/shm` exists and is writable | `/dev/shm/${APP_NAME}-${USERNAME}` |
| 2 | `/tmp` is writable | `/tmp/${APP_NAME}-${USERNAME}` |
| 3 | Fallback | Create/use `STORAGE_DIR` (`${XDG_CACHE_HOME}/${APP_NAME}-${USERNAME}`) |

If tier 3 cannot be created → **MUST** fail closed via `die` (or JSON error path if invoked under JSON after flags). **MUST NOT** return empty path.

### 2.3 Isolation

1. Paths **MUST** include **`${APP_NAME}`** and **`${USERNAME}`** (with safe defaults when unset).  
2. **MUST NOT** rewrite the resolver to a single shared world-writable directory for all users.  
3. File creation under the resolved root **SHOULD** use `mktemp` / unique names when the file is scratch (install download already uses `mktemp` for the binary payload — that path is install staging, not required to go through `/dev/shm`).  
4. **MUST NOT** assume temp mounts are executable (`noexec` environments).

### 2.4 What this resolver is not

| Concern | Owner |
|---------|--------|
| Managed CLI binary location | Install detect / `USER_BIN` / `GLOBAL_BIN` |
| Spring Boot demo project directory | Domain: `PROJECT_DIR`, `--project-dir`, `setup_springboot_project` |
| Companion `.sha256` integrity | Automatic checksum / `verify_download_integrity` |
| Atomic install move to `INSTALL_PATH` | `perform_self_install` (same-FS stage as needed) |

### 2.5 Implementation Notes (this project)

| Item | Live value |
|------|------------|
| **Resolver** | `util_resolve_storage` in `./springboot2` |
| **Defaults** | `USERNAME` from `id -un` or `unknown`; `APP_NAME` default `app` inside helper; Config `STORAGE_DIR` |
| **Output on tier-3 fail** | `die "Cannot create storage directory ${STORAGE_DIR}"` |
| **Call sites (honest)** | **Gap / Partial** — helper is defined and protected; **no current call sites** in dispatch/domain/install paths as of 2026-07-15. Future prompt/cache/scratch features **MUST** use it rather than new ad-hoc roots. |
| **Naming family** | Util (`util_*`) per modular function design (P6) |
| **Tests** | No dedicated suite case yet — optional when first consumer lands |

#### Definition of done (storage)

1. §2.2 priority and isolation hold in `util_resolve_storage`.  
2. No parallel ad-hoc product scratch roots without requirement revision.  
3. Fail closed when no storage available.  
4. When a consumer is added: call resolver; add regression test; update this Notes row (clear Gap).  
5. Registered in `docs/requirements/index.md`.

### 2.6 Why This Requirement Exists (CIAO)

- **Caution:** Multi-user / sudo / containers — never mix users’ scratch.  
- **Intentional:** One resolver; explicit tiers.  
- **Anti-fragile:** Missing `/dev/shm` still works via `/tmp` or cache.  
- **Over-protect:** Forbid “simplify” to shared `/tmp` dumps; keep Protection Zone on the helper.

## 3. Design Principles (CIAO / CIAO-Lite)

- Volatile first, user cache last for **scratch**.  
- Isolation before convenience.  
- Domain project trees stay domain law.  
- Honest Gaps when helper is unused.

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Remove `${APP_NAME}` / `${USERNAME}` isolation from `util_resolve_storage`.  
2. Replace the fallback chain with a single shared world-writable path.  
3. Scatter new hard-coded `/tmp/${APP_NAME}` roots outside the resolver.  
4. Use this resolver as the SSOT for **install binary** or **Spring Boot project** directories without an explicit design change.  
5. Silent-success when no storage can be obtained.  
6. Delete the helper solely because it currently has no callers — wire or document Gap.  
7. Bypass Output SSOT for storage failure messages.  
8. Assume `/dev/shm` always exists or is exec-capable.

**Violating this rule is a critical storage isolation regression.**

---

## 5. Related artifacts

| Artifact | Role |
|----------|------|
| `docs/requirements/requirement-shell-modular-function-design.md` | `util_*` family ownership |
| `docs/requirements/requirement-shell-output-requirements.md` | Data-return stdout vs product UI |
| `docs/requirements/requirement-shell-self-management.md` | Install staging (`mktemp`) |
| `docs/requirements/requirement-springboot2-domain.md` | Domain `PROJECT_DIR` (not this resolver) |
| `docs/requirements/index.md` | Registry |
| `./springboot2` | Implementation (`util_resolve_storage`) |

---

**Last Updated**: 2026-07-15  
**Owner**: springboot2 project maintainers  
**Alignment**: CIAO (https://github.com/cloudgen/ciao); CIAO-Lite; specialized from shell CLI storage portable pattern.

## 6. Revision history

| Date | Change | Author / agent |
|------|--------|----------------|
| 2026-07-15 | Initial Active v1.0.0: live resolve chain, isolation, honest no-call-site Gap | Grok |
