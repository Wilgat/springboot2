# Report: software-dev housekeeping — springboot2 2.3.2

**Date:** 2026-08-11  
**Mode:** Full cycle (`SK-SOFTWARE-DEV-HOUSEKEEPING`)  
**Class:** software-development  
**Product VERSION:** 2.3.2 (no bump this cycle)  
**Status:** clean for product surfaces · harness local-only updated  

## Phase 0 — Classify

| Item | Value |
|------|--------|
| Project | springboot2 |
| Ship unit | `./springboot2` |
| Scope | Full phases 0–6 |

## Phase 1 — H2 harness pull

| Item | Value |
|------|--------|
| Source | `/dev/shm/genesis-template` (GENESIS_SSOT) |
| Target | `/var/www/grok.dr-sense.com/prjs/springboot2` |
| Map | NEW=19 UPDATE=30 SAME=427 DEST_ONLY=0 |
| Pre-flight | PASS |
| Apply | Yes (housekeeping same-message after map) |
| Protected | ship unit, 12 REQs, tests, reviews, product README/* |
| Post counts | skills 59 · terms 235 · templates 145 · policies 16 · human-intro 20 |
| AGENTS.md | UPDATE from genesis (gitignored map) |
| H-HK-01 | six→eleven on `harness-knowledge.md` if residual |

## Phase 2 — Requirements

| Key | Disk | Registry | Decision |
|-----|------|----------|----------|
| requirement-class-software-dev | yes | yes | confirm-as-is |
| requirement-shell-* (10) | yes | yes | confirm-as-is |
| requirement-domain-springboot2 | yes | yes | confirm-as-is |
| orphans / ghosts | none | none | — |

Class gate: **Pass**. No law edits this cycle.

## Phase 3 — Reviews

- Loaded lessons + test-plan + what-to-review  
- Closed L-HK-01 / L-HK-02 after H2 + wording fix  
- Watch lessons (silent pipe, O-P, payload, csum, …) remain open-watch  
- Suite: **PASS=174 FAIL=0 SKIP=1**

## Phase 4 — Product docs

| Doc | Check |
|-----|--------|
| README badge / footer | 2.3.2 |
| CHANGELOG | [2.3.2] present; Unreleased empty |
| SECURITY | 2.3.2 current |
| LICENSE author-email | wilgat.wong@gmail.com |
| Companion | matches ship unit |

No product-doc content rewrite required.

## Phase 5 — Identity

| Surface | Value | Align |
|---------|--------|-------|
| repository-user | Wilgat (`REPO_USER`) | — |
| author-email | wilgat.wong@gmail.com | LICENSE |
| `ssh -T git@github.com` | Hi **Wilgat**! | **match** |
| local `user.name` / `user.email` | unset in this agent env | use one-shot env on commit |

## Phase 6 — Precommit

| Gate | Result |
|------|--------|
| Version align | 2.3.2 consistent |
| Companion digest | OK |
| Suite | OK |
| File-leaks / Pattern A | harness not staged |
| READY | **yes** for reviews report commit |

## Verdict

**Pass** — housekeeping complete. Product VERSION unchanged (2.3.2 already released). Versioned commit: reviews residual + this report only (harness remains gitignored).
