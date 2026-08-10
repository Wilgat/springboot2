# Report: H2 harness sync from RAM genesis — springboot2

**Date:** 2026-08-10  
**Mode:** H2 apply (genesis knowledge → software-dev target)  
**Status:** applied · product protected

## Source / target

| Role | Path |
|------|------|
| **Source (GENESIS_SSOT)** | `/dev/shm/genesis-template` (ram-drive first) |
| **Target (PROJECT_SSOT)** | `/var/www/grok.dr-sense.com/prjs/springboot2` |

## Pre-flight

PASS (roots exist, hop H2, ship unit + 12 product REQs SKIP_PRODUCT, no secrets plan).

## Confirmation map totals (applied)

| Code | Count | Action |
|------|------:|--------|
| NEW | 457 | copied |
| UPDATE | 0 | — |
| SAME | 1 | `AGENTS.md` no-op |
| DEST_ONLY | 0 | — |
| SKIP_PRODUCT | ship unit, REQs, tests, reviews, product README/… | not transferred |

## Surfaces transferred

| Surface | Files on dest |
|---------|--------------:|
| `docs/skills` | 57 |
| `docs/terminologies` | 229 |
| `docs/templates` | 140 |
| `docs/policies` | 15 |
| `docs/human-intro` | 15 |
| `docs/README.md` | yes |

## Excluded (not transferred)

- `docs/requirements/**` (product law preserved — class + domain + shell REQs intact)
- `docs/checklists/` (filled evidence)
- `docs/incidents/`, `docs/whitelists/`
- Ship unit, tests, reviews, product user markdown

## Integrity

- Ship unit `./springboot2` + companion present  
- 12 product `requirement-*.md` including class + domain  
- `reviews/` and `tests/` untouched  
- Harness under `docs/**` remains gitignored except `docs/requirements/**` (Pattern A)  
- Name match `template-secret-management.md` only (mold title, not credentials)

## Verdict

**Pass** — portable harness knowledge pulled from RAM genesis; product specialization preserved.
