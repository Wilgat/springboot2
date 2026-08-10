# Report: review-plans-bootstrap — springboot2 2.3.1

**Date:** 2026-08-10  
**Mode:** Create public `reviews/` surface (what-to-review + test-plan + lessons + RTM); map live suite TP-*  
**Status:** open items (law residuals) · suite clean

## Summary

- Created git-tracked `reviews/` peer of `tests/` (was missing; `tests/README.md` previously pointed at non-existent `docs/reviews/`).  
- Loaded product requirements index + domain/shell law; prior session requirements review residuals folded into lessons.  
- Ran `./tests/run.sh`: **PASS=162 FAIL=0 SKIP=1**.  
- Type 1 elev review-plan gate: **N/A** (not claimed).  
- Type O-P + silent-failure + checksum + domain preserve paths covered as **have** in `test-plan.md`.

## Prior lessons

`lessons.md` created this run (no prior `reviews/lessons.md`). Seeded from CHANGELOG / ship-unit INC notes:

- L-SILENT-01 (INC-20260720-001 nounset silent curl|bash)  
- L-OP-01 (Type O-P vs binary-only)  
- L-PAYLOAD-01, L-CSUM-01, L-DOWNGRADE-01, L-HOME-01, L-PRESERVE-01, L-HELP-01  
- L-CLASS-01, L-DOMAIN-NAME-01, L-MOD-01, L-DOCS-01 (from requirements review)

## Issues

### Issue 1 -- Severity: suggestion

- File: `docs/requirements/` (missing `requirement-class-software-dev.md`)
- Description: Software-development class gate fails without Active class requirement.
- Suggestion: Authorize `skill-create-class-requirement` with bash + Boot 2.7.18 residual stack.
- Lesson: L-CLASS-01
- Test: n/a (law surface)
- Status: open

### Issue 2 -- Severity: suggestion

- File: `docs/requirements/requirement-domain-springboot2.md`
- Description: Domain SSOT basename uses product-suffix form rather than `requirement-domain-*`.
- Suggestion: Rename to `requirement-domain-springboot2.md` + same-change index when authorized.
- Lesson: L-DOMAIN-NAME-01
- Test: n/a
- Status: open

### Issue 3 -- Severity: suggestion

- File: `docs/requirements/requirement-shell-modular-function-design.md` · `reviews/test-plan.md`
- Description: Modular DTV lacks primary **TP-*** rows.
- Suggestion: Implement **TP-MOD-01/02** static checks or map existing suite honestly.
- Lesson: L-MOD-01
- Test: TP-MOD-01 · TP-MOD-02 (todo)
- Status: open

### Issue 4 -- Severity: suggestion

- File: `docs/requirements/README.md`
- Description: Inventory text still says nine shell files; registry has ten shell + domain.
- Suggestion: Refresh README count/list to match `index.md`.
- Lesson: L-DOCS-01
- Test: n/a
- Status: open

### Issue 5 -- Severity: nit

- File: `reviews/test-plan.md`
- Description: TP-CLI-08/10 and TP-CSUM-01 unused numbers in suite numbering.
- Suggestion: Keep documented as unused; do not invent hollow have rows.
- Status: closed (documented)

## Test-plan deltas

| TP family | Change |
|-----------|--------|
| TP-CLI / TP-U / TP-CSUM / TP-LC / TP-CURL / TP-DOM | Registered as **have** from live suites |
| TP-CURL-09 | **optional** |
| TP-MOD-01/02 | **todo** (new residual) |
| TP-ELEV | **n/a** |

## Suite evidence

```text
PASS=162 FAIL=0 SKIP=1
RESULT: OK
```

## Verdict

**Revise** — automated Core suite is green; product law has open class/domain-naming residuals tracked in lessons. Review **plans** are now durable under `reviews/`.

## Artifacts written

- `reviews/README.md`
- `reviews/what-to-review.md`
- `reviews/test-plan.md`
- `reviews/lessons.md`
- `reviews/requirement-test-matrix.md`
- `reviews/index.md`
- `reviews/reports/README.md`
- this report
