# Reviews — springboot2

Public product review surface (peer of `tests/`). Git-tracked.

| File | Role |
|------|------|
| `what-to-review.md` | Living review plan / checklist |
| `test-plan.md` | TP-* status map (have / todo / optional / n/a) |
| `requirement-test-matrix.md` | Requirement → TP families |
| `lessons.md` | Durable failure modes to re-check |
| `index.md` | Report index |
| `reports/` | Dated review run reports |

**Product:** springboot2 (bash Type O-P payload online installer + Spring Boot 2.7.18 domain)  
**Ship unit:** `./springboot2` · companion `./springboot2.sha256`  
**Version SSOT:** `VERSION="2.3.2"` in ship unit Config  
**Channel:** `SCRIPT_URL` → `https://raw.githubusercontent.com/Wilgat/springboot2/main/springboot2`  
**Install mode:** **Type O-P online** (`curl | bash` combined ensure) — not local-only  
**Type 1 elevation / sudoers product surface:** intentionally **absent** (global bin may use host `sudo` for path place; no Type 1 elev law tables)

**Always load first:** `reviews/lessons.md`  
**Suite entry:** `./tests/run.sh`  
**Last plan update:** 2026-08-10
