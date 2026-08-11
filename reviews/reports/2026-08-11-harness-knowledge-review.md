# Report: harness knowledge review — springboot2 2.3.2

**Date:** 2026-08-11  
**Mode:** audit-only (`SK-REVIEW-HARNESS-KNOWLEDGE`)  
**Target folder:** `/var/www/grok.dr-sense.com/prjs/springboot2`  
**PROJECT_SSOT:** hard-disk (no `/dev/shm/springboot2`)  
**Observed class:** **software-development** (ship unit + class REQ + domain + reviews)  
**Status:** open items (revise-level)  

## Summary

Post-H2 portable harness is present and inventoriable. Product specialization is honest (not genesis). Skills Skill-IDs and skills README match disk. Product DNA is not frozen into portable layers. Residual issues: one **eleven-class wording bug** in `harness-knowledge.md`, **local harness lag vs RAM genesis**, and a small **terms index orphan set**.

## Inventory honesty

| Surface | Disk count | Map claim | Match? |
|---------|------------|-----------|--------|
| `requirement-*.md` | 12 | index 12 rows | **yes** (class + 10 shell + domain) |
| `skill-*.md` | 56 | skills README lists 56 | **yes** (no phantom/orphan paths) |
| `template-*.md` (requirements/) | 94 | present under templates | yes (no local phantom scan fail) |
| Blank checklists | 31 | templates/checklists | yes |
| Terminology topics (excl README) | 228 | docs/README **228** | count yes; **6 orphans** vs README links |
| `policy-*.md` | 14 | policies surface | yes |
| Incidents bodies | 0 | none claimed | yes |

## Class shape

| Check | Result |
|-------|--------|
| Not genesis (REQs present) | Pass |
| Active `requirement-class-software-dev` | Pass |
| Domain SSOT `requirement-domain-springboot2` | Pass |
| Product `reviews/` public surface | Pass |
| Ship unit VERSION | 2.3.2 |

## Eleven-class coherence

| Check | Result |
|-------|--------|
| `project-class.md` exactly eleven | Pass |
| Core OS free of stale “six peer classes” | **Fail** — `docs/terminologies/harness-knowledge.md` must-not-confuse row still says **six** |

## Portability scrub

| Check | Result |
|-------|--------|
| springboot2 / Wilgat frozen in skills/terms/templates/policies | none found |
| Secrets in harness trees | none (only mold title `template-secret-management`) |
| SSH vault basenames as universal law | not observed |

## Track maturity (core)

H1/H2 transfer skills + checklists, review-harness-knowledge skill + checklist, class-requirement skill, dual-policies / no-hardcode / ram-drive-first / id-notation policies, harness-knowledge / harness-knowledge-sync / project-class / genesis-template terms — **all present**.

## Drift vs RAM genesis (`/dev/shm/genesis-template`)

Local H2 snapshot is **behind** current RAM seed (new files only on RAM):

| Surface | Only on RAM (not local) |
|---------|-------------------------|
| skills | `skill-dest-ssot-map-rebind.md`, `skill-python-oop-revision.md` |
| terms | agent-contract, boot-contract, dest-ssot-map-rebind, full-agent-contract, harness-surface, python-oop-style-levels |
| templates | checklist-dest-ssot-map-rebind, checklist-python-oop-revision, template-domain-url-cli, template-download-ytdlp-pipeline, template-python-runtime-prerequisites |
| policies | `policy-stay-honest.md` |
| human-intro | 5 matching intro stubs |

## Issues

### H-HK-01 — Severity: suggestion (Revise)

- File: `docs/terminologies/harness-knowledge.md` (must-not-confuse table)
- Description: Still says project class is exactly **six** peers; contradicts `project-class.md` eleven-class SSOT and same file’s eleven wording elsewhere.
- Suggestion: Change “six” → “eleven” (or cite project-class only without a count).
- Status: open

### H-HK-02 — Severity: suggestion (Revise)

- Surface: local harness trees vs GENESIS_SSOT RAM
- Description: After prior H2 apply, RAM genesis gained ~19 harness files; local software-dev tree not re-pulled.
- Suggestion: Re-run H2 “sync from ram genesis” when you want latest portable OS.
- Status: open

### H-HK-03 — Severity: nit

- File: `docs/terminologies/README.md`
- Description: Six on-disk terms not linked: `git-bare-repo`, `git-repo`, `github-repo`, `gitlab-repo`, `pypi-version`, `version-align` (docs/README already names the git-repo / version-align / pypi-version family).
- Suggestion: Add index rows in same change as any next terms pass.
- Status: open

### H-HK-04 — Severity: nit

- File: `AGENTS.md`
- Description: Still cites CIAO **v2.9.1** while live skills/philosophy lines use **v2.10.2**.
- Suggestion: Bump AGENTS CIAO version pins when next map scrub runs (optional; not product law).
- Status: open

## Checklist verdict (CL-REVIEW-HARNESS-KNOWLEDGE)

- Classify first: **Pass**
- Inventory honesty: **Pass with nits** (terms orphans)
- Eleven-class: **Revise** (H-HK-01)
- Genesis shape: **N/A** (software-dev)
- Portability: **Pass**
- Track maturity: **Pass**

### Overall: **Revise**

Not **Block** (no secrets, no wrong-class genesis claim, no hollow skills, product DNA clean).

## Recommended next actions

1. Surgical fix H-HK-01 wording in `harness-knowledge.md`.  
2. Optional H2 re-sync from RAM for H-HK-02.  
3. Optional terms README rows for H-HK-03; AGENTS CIAO pin for H-HK-04.  

No harness edits applied this turn (audit-only).
