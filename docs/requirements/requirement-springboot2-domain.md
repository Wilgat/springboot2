**file**: docs/requirements/requirement-springboot2-domain.md  
**Status**: Active (Version 1.0.0)  
**Philosophy**: CIAO / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered)

## 1. Purpose

This requirement is the **project Single Source of Truth** for the **Spring Boot domain surface** of springboot2: SDKMAN / Java / Maven toolchain ensure, demo project create-preserve-reset, build and run, Alpine/bash constraints, and domain flags/commands — **beyond** Type 0 CLI self-management.

It owns product ops so agents do not treat shell lifecycle files alone as full-product law (see glossary: domain-requirements, requirement-sufficient-check).

**Scope:** Domain pins, helpers, default run path, project preserve/force, domain flags, help↔dispatcher alignment for domain surface.  
**Out of scope (cited, not re-owned):** Binary install / self-update / uninstall (`requirement-shell-self-management.md`); empty-argv install-ensure when not installed (`requirement-shell-cli-zero-arguments.md`); full Type 0 command catalog (`requirement-shell-cli-interface.md`); automatic companion checksum (`requirement-shell-automatic-checksum.md`); output channel SSOT (`requirement-shell-output-requirements.md`).

---

### Identity SSOT (this product — do not diverge)

| Field | Live value (ship unit `./springboot2`) |
|-------|----------------------------------------|
| **APP_NAME** | `springboot2` |
| **VERSION** | `2.1.0` |
| **REPO_USER** / **REPO_NAME** | `Wilgat` / `springboot2` |
| **SCRIPT_URL** | `https://raw.githubusercontent.com/Wilgat/springboot2/main/springboot2` |
| **Shebang / runtime** | `#!/bin/bash` (SDKMAN requires bash) |
| **Dispatcher** | `main_spring_boot_app` (not seed `app_main`) |
| **Output SSOT** | `output_text` / `output_json` / `output_json_error` (+ wrappers `info`/`success`/`warn`/`error`/`die`) |
| **Install SSOT** | `perform_self_install` / `maybe_install` / `is_installed` / `get_installed_version` |
| **Domain helpers** | `check_alpine_requirements`, `setup_sdkman`, `setup_java`, `setup_maven`, `setup_springboot_project`, `run_springboot_project` |

Live scalars and pins are owned by the ship unit Config block. On conflict with Config, use product identity protocol (ask; do not invent dual owners). **Do not** retarget this product to another Spring Boot line (3.x / 4.x) without an explicit product decision — this ship unit is intentionally pinned to **2.7.18**.

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Domain pins (normative for this product)

| Pin | Live default (Config) | Contract |
|-----|----------------------|----------|
| **Spring Boot** | `SPRINGBOOT_VER=2.7.18` | Demo parent POM and messaging **MUST** use this pin unless product decision revises |
| **Java (SDKMAN id)** | `JAVA_ID=8.0.472-amzn` | Java ensure **MUST** install/use this SDKMAN candidate (or documented successor pin) |
| **Java language level** | `JAVA_VERSION=1.8` | Project `pom.xml` / properties **MUST** match |
| **Maven** | `MAVEN_VER=3.9.14` | Maven ensure **MUST** install/use this pin via SDKMAN |
| **Default project dir** | `PROJECT_DIR=${HOME}/springboot-${APP_NAME}` (name via `PROJECT_NAME`) | Overridable by `--project-dir` |
| **HTTP port / bind** | `PORT=8080`, `BIND_IP=0.0.0.0` | Written into `application.properties` when generating |
| **Main class / artifact** | `MAIN_CLASS=HelloApplication`, `ARTIFACT_ID=hello-${APP_NAME}` | Demo sources and JAR naming |

Agents **MUST NOT** “modernize” Boot/Java pins as a casual cleanup. Header comments on the ship unit restate this intent.

### 2.2 Domain ensure pipeline (order)

When domain default run applies (installed empty argv, explicit `run`, or equivalent fallthrough after Type 0 commands exit), `main_spring_boot_app` **MUST** execute in order:

1. `check_alpine_requirements` — Alpine + bash availability for SDKMAN  
2. `setup_sdkman` — install or reuse SDKMAN  
3. `setup_java` — install/default/use pinned Java  
4. `setup_maven` — install/use pinned Maven  
5. `setup_springboot_project` — create or preserve demo project under `PROJECT_DIR`  
6. Unless `--no-run` / `NO_RUN=1`: `run_springboot_project` (`mvn clean package -DskipTests` then `java -jar` of expected artifact)

Failures **MUST** exit non-zero via output SSOT (`die` / `error`); **MUST NOT** fake success.

### 2.3 Project preserve vs reset

| Condition | Required behavior |
|-----------|-------------------|
| `PROJECT_DIR` missing | Create directory; generate demo files (pom, main class, `application.properties`, dirs) |
| `PROJECT_DIR` exists, force **off** | **Preserve** existing project files; regenerate only missing pieces; **MUST NOT** delete user edits |
| Force / reinstall policy **on** (`FORCE_REINSTALL=1` or equivalent documented flag) | May remove/regenerate project tree and overwrite demo files as designed |
| Help documents `--reset` | Dispatcher **MUST** parse and honor reset/force project policy **or** help **MUST NOT** advertise it (help↔dispatcher alignment) |

Live code keys full project wipe/regenerate on `FORCE_REINSTALL` from `--force` and/or **`--reset`** (dispatcher sets `FORCE_REINSTALL=1` / `RESET_PROJECT=1`).

### 2.4 Domain flags and commands

| Surface | Contract |
|---------|----------|
| **Default cmd** | `cmd=run` when no Type 0 command token is given |
| **Empty argv when installed** | Domain run pipeline (§2.2) — **not** Type 0 install no-op; see `requirement-shell-cli-zero-arguments.md` hybrid supersession |
| **Empty argv when not installed** | Install-ensure first (`maybe_install` / `perform_self_install`); domain run is not the first-install contract |
| `--project-dir <path>` | Set `PROJECT_DIR`; required path argument or fail loud |
| `--no-run` | Complete env + project setup; skip `run_springboot_project`; success message / JSON with `no_run` |
| `--force` / force-user / force-root | Privilege and reinstall policy; project regenerate when wired to `FORCE_REINSTALL` |
| `--quiet` / `-q`, `--json` | Same mode contract as shell output requirements; domain messages go through output SSOT |
| `run` | Explicit domain pipeline (same as default) |
| `status` | **Implemented** — routes to `show_about_spring_boot_app` |
| `reinstall` | **Implemented** — force CLI reinstall then domain pipeline |
| `--reset` | **Implemented** — force project regenerate via `FORCE_REINSTALL` |
| Type 0 cmds | `version`, `version-check`, `self-update`, `self-uninstall`, `about`, `help` exit before domain pipeline |

### 2.5 Alpine / bash

1. Shebang **MUST** remain `#!/bin/bash` while SDKMAN requires bash.  
2. On Alpine (`/etc/alpine-release`), if bash is missing, **MUST** instruct install (`apk add bash`) and fail non-zero — **MUST NOT** continue silently with ash-only assumptions.  
3. Domain helpers **MUST** keep using output SSOT (no raw `echo` for user messages).

### 2.6 Help ↔ dispatcher (domain)

1. Every domain command/flag advertised in `show_spring_boot_help` **MUST** be parsed/routed in `main_spring_boot_app` (or help must drop the row).  
2. Help **MUST** state Spring Boot pin and purpose (quick setup & runner for this line).  
3. JSON help **MUST NOT** dump long human text (shell output / CLI interface rules apply).

### 2.7 Implementation Notes (live inventory)

| Item | Live value |
|------|------------|
| Domain entry | Default `cmd="run"` in `main_spring_boot_app` after Type 0 cases |
| Auto-install gate | `if ! is_installed && [ $# -eq 0 ]` then install helpers — **not** when already installed |
| Domain chain | `check_alpine_requirements` → `setup_sdkman` → `setup_java` → `setup_maven` → `setup_springboot_project` → optional `run_springboot_project` |
| Project write | `write_file_atomic` for demo files |
| Run | `exec java -jar "target/${JAR_NAME}"` after successful package |
| About extras | Domain-rich diagnostics (SDKMAN, project dir, port) via `show_about_spring_boot_app` |

#### Compliance notes (implementation status) — re-read disk 2026-07-15

| Item | Status |
|------|--------|
| `--reset` → project regenerate | **Implemented** |
| `status` / `reinstall` routed | **Implemented** |
| `--force` → `FORCE_REINSTALL=1` | **Implemented** |
| Empty argv installed = domain pipeline | **Implemented** (hybrid) |
| Preserve without force | **Implemented** |
| `install` subcommand | **Intentional absent** — empty-argv first install only |
| Residual | Real SDKMAN/Java network path not fully mocked beyond suite stubs; production run needs network/toolchain |

### 2.8 Why This Requirement Exists (Direct CIAO Alignment)

- **Caution:** Preserve existing projects by default; fail loud on Alpine/bash and toolchain failure.  
- **Intentional:** Pins and pipeline order are deliberate; Boot 2.7.18 is not an accident.  
- **Anti-fragile:** Re-run preserves project; force regenerates; works after self-install.  
- **Over-protect:** Do not drop domain law, collapse pins, or let help advertise unrouted domain commands.  
- **SSOT:** Config owns pins; this file owns domain behavioral law; Type 0 files own binary lifecycle.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- Domain is **additive** to Type 0 — never a reason to delete self-management.  
- Empty argv is a **hybrid**: not installed → install-ensure; installed → domain run.  
- Help, dispatcher, and this requirement stay synchronized.  
- Prefer surgical code changes over “cleanup” that rewrites defensive domain helpers.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Retarget Spring Boot / Java / Maven pins without an explicit product decision and requirement revision.  
2. Delete or simplify domain helpers (`setup_*`, `run_springboot_project`, Alpine check) as drive-by cleanup.  
3. Change installed empty argv from domain run back to install-only no-op without updating this file **and** `requirement-shell-cli-zero-arguments.md`.  
4. Advertise domain commands/flags in help without dispatcher wiring (or leave known Gaps untracked).  
5. Default to destroying an existing `PROJECT_DIR` without force/reset policy.  
6. Treat shell lifecycle requirements alone as full-product sufficient law while this domain surface exists.  
7. Reverse-copy this product’s domain pins into unrelated bootstrap seeds as if they were universal.

**Violating this rule is a critical domain regression.**

---

## 5. Definition of done (domain)

This requirement is satisfied when:

1. Pins in §2.1 match Config (or documented deliberate overrides).  
2. Domain pipeline §2.2 runs for installed default/`run`.  
3. Project preserve/force rules §2.3 hold.  
4. Domain flags/commands §2.4 are either Implemented or listed as Gap with honest status.  
5. Alpine/bash §2.5 holds.  
6. Help↔dispatcher §2.6 has no silent drift.  
7. Registered in `docs/requirements/index.md`.  
8. Traceability: implementation changes cite this file path / key `requirement-springboot2-domain`.

---

## 6. Related artifacts

| Artifact | Role |
|----------|------|
| `docs/requirements/requirement-shell-cli-zero-arguments.md` | Hybrid empty argv; install when absent |
| `docs/requirements/requirement-shell-cli-interface.md` | Type 0 command surface; domain addendum |
| `docs/requirements/requirement-shell-self-management.md` | Binary lifecycle only |
| `docs/requirements/requirement-shell-output-requirements.md` | Output SSOT for domain messages |
| `docs/requirements/requirement-shell-idempotency.md` | Ensure re-run (lifecycle); domain preserve is complementary |
| `docs/requirements/index.md` | Registry SSOT |
| `docs/terminologies/domain-requirements.md` | Glossary |
| `./springboot2` | Implementation under test |

---

**Last Updated**: 2026-07-15  
**Owner**: springboot2 project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; CIAO (https://github.com/cloudgen/ciao); CIAO-Lite; intentional Boot 2.7.18 family pin.

## 7. Revision history

| Date | Change | Author / agent |
|------|--------|----------------|
| 2026-07-15 | Initial Active v1.0.0: domain pins, pipeline, preserve/force, flags, Alpine, help↔dispatcher, Gaps | Grok (authorized 1–3) |
