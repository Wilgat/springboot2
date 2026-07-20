# Requirements index

**Product:** springboot2 — bash (`#!/bin/bash`) Type 0 self-install / self-maintenance CLI plus Spring Boot 2.7.18 domain  
**Identity SSOT:** ship unit `./springboot2` Project Constants — `APP_NAME="springboot2"`, `VERSION="2.2.0"`, `REPO_USER="Wilgat"`, `REPO_NAME="springboot2"`, `SCRIPT_URL` composed from those. Requirements **must not** invent a different product name, channel, or version.  
**Workspace state:** Specialized product law — identity SSOT retargeted; Implementation Notes use **live** `./springboot2` helpers; false “Implemented” seed claims demoted to **Gap/Partial** where code lacks them; domain law registered (`requirement-springboot2-domain`).  
**Live Implementation honesty:** Product naming SSOT = A prefixes (`out_*`, `inst_*`, `app_main`) on live ship unit (§3.1 option 1). Empty argv when installed = domain **run**. Automatic checksum Shape A when companion present. JSON success/error types = `out_success` / `out_error`.
**Sufficiency note:** Domain + storage + integrity law registered; help↔dispatcher / force / hybrid empty-argv / Shape A+B checksum / tests green; Implementation Notes re-synced 2026-07-15. Storage: resolve+mkdir fail-closed, `EFFECTIVE_STORAGE_DIR` + `TMPDIR` in main, about fields. Residual: optional downgrade JSON code wording; JSON error on stdout vs stderr.  
**Updated:** 2026-07-20 (housekeeping: registry re-confirmed; no law invent)

| ID / key | Title | Area | Status | Path | Updated |
|----------|-------|------|--------|------|---------|
| requirement-shell-automatic-checksum | Automatic companion-digest integrity (transparent link/value/result; CHECKSUM not help/about) | shell | Active | `requirement-shell-automatic-checksum.md` | 2026-07-15 |
| requirement-shell-cli-interface | Shell CLI interface (commands, flags, dispatch, modes) | shell | Active | `requirement-shell-cli-interface.md` | 2026-07-15 |
| requirement-shell-cli-storage | Shell CLI storage resolve (volatile/cache roots, per-user isolation) | shell | Active | `requirement-shell-cli-storage.md` | 2026-07-15 |
| requirement-shell-cli-zero-arguments | Empty argv Type O hybrid (install when absent; domain run when installed) | shell | Active | `requirement-shell-cli-zero-arguments.md` | 2026-07-15 |
| requirement-shell-idempotency | Shell idempotency / re-run safety for ensure-style ops | shell | Active | `requirement-shell-idempotency.md` | 2026-07-15 |
| requirement-shell-interactive-vs-noninteractive | Interactive vs non-interactive / `curl\|bash` behavior | shell | Active | `requirement-shell-interactive-vs-noninteractive.md` | 2026-07-15 |
| requirement-shell-modular-function-design | Single-file modular function design (prefixes, zones) | shell | Active | `requirement-shell-modular-function-design.md` | 2026-07-15 |
| requirement-shell-output-requirements | Central `out_*` output SSOT (stdout/stderr, modes) | shell | Active | `requirement-shell-output-requirements.md` | 2026-07-15 |
| requirement-shell-self-management | Self-management lifecycle (version-check, update, uninstall, about) | shell | Active | `requirement-shell-self-management.md` | 2026-07-15 |
| requirement-springboot2-domain | Spring Boot domain (SDKMAN/Java/Maven/Boot 2.7.18, project preserve, build/run) | domain | Active | `requirement-springboot2-domain.md` | 2026-07-15 |

**Rules for agents:**

1. Treat rows above as the **live product-law inventory** for springboot2. Product identity (`APP_NAME` and friends) is owned by `./springboot2` — re-read disk; do not reintroduce names from seed/other projects.  
2. **Do not invent** additional `requirement-*.md` paths — verify on disk and add a registry row in the same change when creating one.  
3. Product source comments cite **only** these live requirement files (or future registered ones) — never `template-*` / `skill-*` as behavioral authority.  
4. This versioned surface lists **requirement rows only** — do not dump templates / skills / terminologies / incidents path inventories here (git-surface; INC-20260712-005).  
5. Keep Status and Path in sync with each file’s header when status changes.  
6. **Registry discipline (summary only):** invent no paths; same-change file+row; empty registry valid at genesis; this file stays **requirement rows only** (no harness tree dumps).

When adding a requirement: append a row, create the file under `docs/requirements/`, keep Status in sync with the file header.
