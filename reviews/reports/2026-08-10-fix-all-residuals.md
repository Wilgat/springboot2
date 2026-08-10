# Report: fix-all-residuals — springboot2 2.3.1

**Date:** 2026-08-10  
**Mode:** Implement authorized residual fixes from requirements review + review-plans bootstrap  
**Status:** clean for tracked residuals · open-watch lessons remain

## Summary

Closed all open **suggestion** residuals:

1. Created Active `requirement-class-software-dev.md` + registry row (Area `class`).  
2. Renamed domain SSOT `requirement-springboot2-domain` → `requirement-domain-springboot2` (file + all product cites).  
3. Refreshed `docs/requirements/README.md` inventory (class + 10 shell + domain).  
4. Modular DTV + **TP-MOD-01/02** automated in `tests/test_cli.sh`.  
5. Stripped harness `../terminologies/` links and path-only mold cites from tracked REQs (payload + zero-args).  
6. Regenerated `springboot2.sha256` after ship-unit comment retarget (L-CSUM-01).  

**Suite:** `./tests/run.sh` → **PASS=174 FAIL=0 SKIP=1**.

## Lessons re-check

| ID | Result |
|----|--------|
| L-CLASS-01 | **closed** — class file Active |
| L-DOMAIN-NAME-01 | **closed** — `requirement-domain-springboot2.md` |
| L-MOD-01 | **closed** — TP-MOD have |
| L-DOCS-01 | **closed** — README inventory |
| L-CSUM-01 | re-checked — companion regenerated this run |
| L-SILENT / L-OP / L-PAYLOAD / L-DOWNGRADE / L-HOME / L-PRESERVE / L-HELP | still **open watch** (suite still covers) |

## Issues

### Issue 1 -- Severity: suggestion — **closed**

- Class requirement missing → created `requirement-class-software-dev.md`
- Lesson: L-CLASS-01
- Status: closed

### Issue 2 -- Severity: suggestion — **closed**

- Domain basename nonstandard → renamed to `requirement-domain-springboot2.md`
- Lesson: L-DOMAIN-NAME-01
- Status: closed

### Issue 3 -- Severity: suggestion — **closed**

- TP-MOD todo → implemented and green
- Lesson: L-MOD-01 · Test: TP-MOD-01 · TP-MOD-02
- Status: closed

### Issue 4 -- Severity: suggestion — **closed**

- Requirements README inventory drift
- Lesson: L-DOCS-01
- Status: closed

## Test-plan deltas

| TP | Change |
|----|--------|
| TP-MOD-01 | **todo → have** |
| TP-MOD-02 | **todo → have** |

## Verdict

**Pass** for residual fix scope. Product remains under normal open-watch lessons (silent pipe, layer split, etc.) — not defects.

## Artifacts

- `docs/requirements/requirement-class-software-dev.md` (new)
- `docs/requirements/requirement-domain-springboot2.md` (renamed)
- `docs/requirements/index.md` · `README.md`
- shell REQs cites + modular DTV
- `tests/test_cli.sh` TP-MOD
- `springboot2` comment cite + `springboot2.sha256`
- `reviews/*` plans/lessons/matrix/index
