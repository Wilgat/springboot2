**file**: docs/requirements/requirement-class-software-dev.md  
**Status**: Active (Version 1.0.0 – springboot2 class law + residual stack)  
**Area**: class  
**Key**: `requirement-class-software-dev`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

Declare this workspace as a **software-development** project class and hold the **residual collection** of software-engineering stack facts **not already owned** by more specific Active peer requirements: primary language, toolchain policy, package/test tooling, and runtime OS family.

This file is **class law + residual SSOT**, not a second copy of Type O-P lifecycle, Spring Boot domain pins, output, checksum, or storage tables (those stay on peer requirements).

---

## 2. Core Rules (Mandatory)

### 2.0 Project class membership

1. **MUST** treat this workspace as **software-development** (shippable software), not genesis-template and not server-maintenance.  
2. **MUST** use basename **`requirement-class-software-dev.md`** as the sole Active class-law file for this class.  
3. **MUST NOT** register an Active `requirement-class-server-maintenance.md` while class is software-development.  
4. **MUST** retain portable harness knowledge; specialized product knowledge lives in this and peer `requirement-*.md` files.  
5. **MUST** apply software-development SSOT/gate posture when claimed (identity, ship unit, channel, precommit when git is used — as applicable).  
6. **MUST NOT** invent hollow product docs solely to look specialized; collect real values or defer explicitly.

### 2.1 Residual collection principle (SSOT hygiene)

7. **MUST** treat this file as the **default home** for software-stack facts **not owned** by another Active requirement.  
8. **MUST NOT** duplicate full normative tables that already live in a more specific Active requirement. Prefer a **one-line pointer** to the peer requirement key.  
9. When a new specialized requirement **takes ownership** of a topic previously only listed here, **MUST** update this file in the **same change**: remove or shrink the residual entry and point to the new owner.  
10. **MUST NOT** leave contradictory stack facts across this file and peer requirements.

### 2.2 Programming language(s)

11. **MUST** declare at least one **primary programming language** for the ship unit.  
12. **SHOULD** list secondary languages only when they are real product law.  
13. **MUST** state whether the product is primarily: interpreted, compiled, polyglot, or package-multi-language.  
14. **MUST NOT** freeze a marketing product name as if it were the language name.

### 2.3 Compilers, interpreters, and toolchains

15. **MUST** declare the **target toolchain class** used to build or run the product.  
16. **MUST** state version policy as one of: unconstrained · minimum version · range · pinned.  
17. **SHOULD** record whether cross-compilation is in scope.  
18. **MUST** fail closed in CI/docs claims: do not claim “supports all compilers” without tests or explicit unconstrained policy.

### 2.4 Project / package / build tools

19. **MUST** declare the **primary project or package tool** used for dependencies and builds.  
20. **MUST** declare how dependencies are resolved when the ecosystem supports lockfiles.  
21. **SHOULD** name the test runner and linter/formatter **classes** when they are project law.  
22. **MUST NOT** require a secret token or private registry password in this file.

### 2.5 Runtime and platform (residual)

23. **MUST** declare the intended **primary runtime/OS family** when not fully owned by another architecture requirement.  
24. **SHOULD** declare minimum CPU/arch support only when it is real product law.  
25. **MUST** separate **developer machine** toolchain requirements from **end-user runtime** requirements when they differ.

### 2.6 No-hardcode / dual policy (class file)

26. **MUST NOT** hard-code a single product/app brand, one org’s production hostname, or personal owner identity as universal core law.  
27. **MUST** put live product name, repo slug, and concrete stack choices in **Implementation Notes** after collection — complete when Status is Active.  
28. **MUST NOT** store secrets, PATs, or toy credentials in this file.

### 2.7 Implementation Notes (this project)

| Field | Value (springboot2) |
|-------|---------------------|
| **Project display name** | `springboot2` |
| **Project class** | software-development |
| **Class requirement basename** | `requirement-class-software-dev.md` |
| **Primary language(s)** | `bash` (`#!/bin/bash` ship unit) |
| **Language role** | primary — single-file CLI ship unit `./springboot2` |
| **Secondary / payload languages** | Java 8 (Amazon Corretto via SDKMAN) for the demo Spring Boot app; Maven builds the payload project — **domain-owned**, not a second ship-unit language |
| **Execution model** | **interpreted** for CLI; **compiled** for demo app (`mvn package` → JAR) |
| **Toolchain / interpreter** | bash (required for SDKMAN); payload pins via domain REQ |
| **Toolchain version policy** | CLI: **unconstrained** among bash that pass product tests; domain payload: **pinned** Boot/Java/Maven in domain Implementation Notes |
| **Cross-compile in scope?** | no (CLI); demo app targets JVM bytecode via Maven |
| **Primary project/package tool** | **none** for CLI (ship unit is the source); payload uses **Maven** via SDKMAN (domain) |
| **Lockfile policy** | not used for CLI; Maven resolves payload deps at build time (domain) |
| **Test runner** | POSIX shell suite `tests/run.sh` (TP-labeled) |
| **Linter/formatter** | none as project law (`bash -n` in suite; shellcheck optional for maintainers) |
| **Primary runtime / OS family** | POSIX Linux (and Alpine with bash); SDKMAN path assumes bash |
| **Architectures supported** | any arch with bash + curl/wget + tools the script invokes |
| **Git surface** | used (`origin` GitHub channel) |
| **Ship unit / install** | yes — `./springboot2` → user/global bin via **Type O-P online** install (`SCRIPT_URL`) |
| **Product version SSOT** | `VERSION="2.3.2"` hard-assign in `./springboot2` |
| **Channel / identity SSOT** | `APP_NAME`, `REPO_USER`, `REPO_NAME`, `SCRIPT_URL` in ship unit Config |
| **Bootstrap origin** | Type 0 shell online-install family (selfmanaged lineage) specialized to **Type O-P** payload installer + Spring Boot domain |

**Residual ownership table:**

| Topic | Owner | Notes |
|-------|-------|--------|
| Project class membership | **this file** | Fixed |
| Primary language + CLI toolchain policy | **this file** | bash; unconstrained among test-passing bash |
| Package/build tool + lockfile (CLI) | **this file** | none / not used |
| Type 0 / Type O-P CLI surface / flags / dispatch | `requirement-shell-cli-interface` | Do not duplicate |
| Empty argv Type O-P combined ensure | `requirement-shell-cli-zero-arguments` | Online payload installer |
| Payload online install class + layer split | `requirement-shell-payload-online-install` | install/uninstall vs self-* |
| Ship-unit self-management | `requirement-shell-self-management` | self-update / self-uninstall / version-check |
| Automatic companion checksum | `requirement-shell-automatic-checksum` | Shape A primary |
| Output SSOT (`out_*`) | `requirement-shell-output-requirements` | Do not duplicate |
| Scratch/cache storage resolve | `requirement-shell-cli-storage` | Do not duplicate |
| Idempotency / re-run safety | `requirement-shell-idempotency` | Do not duplicate |
| Interactive vs non-interactive | `requirement-shell-interactive-vs-noninteractive` | Do not duplicate |
| Modular prefixes / single-file layout | `requirement-shell-modular-function-design` | Do not duplicate |
| Spring Boot domain pins + pipeline | `requirement-domain-springboot2` | Payload content SSOT |
| Type 1 sudoers elev tables | **intentionally absent** | Not product law |

---

## 3. Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 2 – Intentional**: Class and stack choices are explicit, not assumed from folder names.  
- **CIAO Principle 5 – SSOT**: Residual stack facts have one home until specialized requirements take ownership.  
- **CIAO Principle 1 – Caution**: Toolchain policies are declared; agents do not invent compilers or silent dual language SSOTs.  
- **CIAO Principle 21 – Dual Policies**: Portable core; filled Implementation Notes.  
- **CIAO Principle 4 (O) + Principle 20**: Protection Rule against dual stack SSOTs and wrong-class pollution.

---

## 4. Design Principles (CIAO / CIAO-Lite)

- **Caution**: Assume bash/SDKMAN tools are missing until declared and verified.  
- **Intentional**: Residual collection is deliberate — domain pins stay on the domain requirement.  
- **Anti-fragile**: Unconstrained bash policy for CLI survives multi-env runs when tests pass; domain pins stay deliberate.  
- **Over-protect**: Protection rule prevents dual stack SSOTs and genesis/class confusion.

---

## 5. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Delete this file while the workspace remains **software-development** with other Active product requirements.  
2. Rename the specialized basename away from `requirement-class-software-dev.md` without an explicit class-model change.  
3. Hard-code secrets, personal owner identity, or production host FQDNs into core rules as universal law.  
4. Duplicate full peer requirement bodies into this residual section.  
5. Leave Implementation Notes as hollow stubs when Status claims Active.  
6. Collapse Type O-P online install into local-only without explicit user order and peer law updates.  
7. Treat this file as server-maintenance allowlist law, or register an Active server-maintenance class file in parallel.  
8. Invent a second primary ship-unit language SSOT that contradicts modular/CLI requirements.  
9. Casual-modernize domain Boot/Java/Maven pins without updating `requirement-domain-springboot2`.

**Violating any of these is considered a critical regression.**

---

## 6. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Active registered `requirement-class-software-dev.md` matches software-development class |
| AC-2 | Primary language + toolchain policy + package tool declared in Implementation Notes (complete) |
| AC-3 | Residual ownership table honest: no silent dual SSOT with peer REQs |
| AC-4 | Core rules remain free of frozen secret/host hardcodes |
| AC-5 | No class file conflict with `requirement-class-server-maintenance` |
| AC-6 | Ship unit identity (bash single-file, Type O-P online) consistent with peer shell REQs |
| AC-7 | Domain pins owned by domain requirement, not re-specified as full tables here |

---

## 7. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-shell-cli-interface` | Command surface, flags, dispatch |
| `requirement-shell-cli-zero-arguments` | Type O-P empty argv |
| `requirement-shell-payload-online-install` | Payload online installer class |
| `requirement-shell-self-management` | Ship-unit lifecycle |
| `requirement-shell-automatic-checksum` | Companion integrity |
| `requirement-shell-output-requirements` | `out_*` SSOT |
| `requirement-shell-cli-storage` | Scratch/cache resolve |
| `requirement-shell-idempotency` | Re-run safety |
| `requirement-shell-interactive-vs-noninteractive` | Mode policy |
| `requirement-shell-modular-function-design` | Prefixes / single-file modularity |
| `requirement-domain-springboot2` | Spring Boot payload domain SSOT |

## Design-time verification

| Gate | Suite / gate | Status |
|------|--------------|--------|
| Class residual honesty | review / registry | have |
| CLI language/toolchain smoke | TP-CLI-01 · suite | have (indirect) |

---

**Last Updated**: 2026-08-10  
**Owner**: springboot2 project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; CIAO (https://github.com/cloudgen/ciao); CIAO-Lite.
