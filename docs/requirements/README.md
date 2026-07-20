# Requirements

Authoritative product and engineering requirements for this project live here.

**Current state (2026-07-15 — springboot2 specialization):** **Nine** live `requirement-shell-*.md` files (automatic-checksum, CLI interface, **CLI storage**, CLI zero-arguments, idempotency, interactive vs noninteractive, modular design, output, self-management) plus **`requirement-springboot2-domain`**. Status **Active**. Registry: `index.md` (must stay in sync).

**Live Implementation honesty:** Notes must name live A helpers (`app_main`, `out_text`, `inst_perform_install`, `util_resolve_storage`, …). Prefix families `out_*`/`inst_*`/`app_*`/`util_*`/`ver_*`/`path_*` are product law (§3.1 option 1). Storage: `util_resolve_storage` in **`requirement-shell-cli-storage`**. Installed empty argv = domain run.

**Identity SSOT (do not diverge):** Product name and install channel come from ship unit `./springboot2` — `APP_NAME="springboot2"`, `VERSION="2.2.0"`, `REPO_USER="Wilgat"`, `REPO_NAME="springboot2"`, `SCRIPT_URL=https://raw.githubusercontent.com/Wilgat/springboot2/main/springboot2`. Online-install behavior is covered by composition (zero-arguments + CLI + checksum + self-management + interactive + idempotency + **storage**). Domain (SDKMAN / Java / Maven / project run) is owned by **`requirement-springboot2-domain.md`**. Do **not** invent additional requirement paths without a real ownership gap — verify on disk and register new files in `index.md` in the same change.

**Sufficiency (glossary):** Coverage review language lives in the harness glossary terms *requirement-sufficient-check* and *domain-requirements* (local `docs/terminologies/` when present). This versioned folder does not re-export harness path inventories.

## Purpose

- **Plan mode** designs work by reading and **updating** these docs — not only the session `plan.md`.
- **Implement** delivers code and docs that **trace** to requirement IDs.
- **Review** verifies delivery against requirements **and** defensive (CIAO) checklists.

## Layout

| Path | Role |
|------|------|
| `docs/requirements/index.md` | Registry of all requirements (IDs, status, owners) — keep in sync with files |
| `docs/requirements/requirement-*.md` | CIAO-style project requirements (flat; primary live convention) |
| `docs/requirements/<area>/<REQ-ID>.md` | Optional council-style `REQ-<AREA>-<NNN>` files |

Suggested areas (if using subdirs): `product/`, `platform/`, `security/`, `ops/` — create as needed.

## ID scheme

- Format: `REQ-<AREA>-<NNN>` (example: `REQ-PLAT-001`).
- IDs are stable. Prefer status/`supersedes` over renumbering.
- Record every ID in `index.md` when created or status changes.

## Status values

| Status | Meaning |
|--------|---------|
| `draft` | Proposed; not yet approved for implementation |
| `approved` | Ready to implement |
| `in-progress` | Implementation underway |
| `done` | Delivered and reviewed against checklists |
| `deprecated` | No longer active; keep file for history |
| `superseded` | Replaced by another REQ-ID (link it) |

## Plan-mode rules (mandatory)

When planning non-trivial work:

1. Search `docs/requirements/` (and `index.md`) for related requirements.
2. Decide: **new requirement**, **update existing**, or **no requirements impact** (state why).
3. Apply requirement file changes **before** or as part of finishing the plan.
4. Session plan (`plan.md`) must list affected REQ-IDs and whether each is create / update / no-change.
5. Do not implement against unstated intent — if behavior is required, it belongs in a requirement file.

## Implementation rules

- Every non-trivial PR/change set cites one or more REQ-IDs in commit/PR/summary when requirements exist.
- Do not invent requirements only in code comments; promote durable intent here.
- **No placeholders** in requirement files: no `TBD`/`TODO` acceptance criteria, hollow sections, or stub “later” text. Claimed-complete law must be complete; escalate unknowns to the user rather than dummy product names.
- Product source comments cite only **live** `requirement-*.md` files (never invent basenames).

## Review rules

- Requirements changes and code/docs delivery use the project’s plan/implement/code-review/security checklist process.
- Empty registry is valid for genesis; do not invent requirements to “fill” the index.
