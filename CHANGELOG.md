# Changelog

All notable changes to **springboot2** will be documented in this file.

This project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html) and the [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) format.

---

## [Unreleased]

### Changed
- **Requirements:** design-time verification tables (TP families) on all shell + domain product-law files; suite pointers use public `tests/` only.
- **Tests:** TP-labeled cases across CLI, install lifecycle, and domain suites; silent-failure guard; new optional online/local curl pipe suite (`test_online_curl_install.sh`, `TP-CURL-*`).

### Notes
- Product **VERSION** remains **2.3.1** (ship unit unchanged).

---

## [2.3.1] - 2026-07-20

### Fixed
- **Silent `curl | bash` / empty argv (INC-20260720-001):** under `set -u`, sourcing user `.bashrc` (or `sdkman-init.sh`) could abort the process while stderr was discarded — **zero messages**, non-zero exit. Fixed via `util_source_external_safe` (nounset off around third-party sources) and safer SDKMAN/Java/Maven setup with loud `out_die` on payload failures.

### Notes
- Product **VERSION** `2.3.1`.

---

## [2.3.0] - 2026-07-20

### Added
- **Type O-P payload online installer** law and behavior: one-liner / empty argv **combined ensure** (CLI ship unit + Spring Boot environment), not binary-only place-and-exit.
- Payload commands: **`install`** (SDKMAN/Java/Maven/project) and **`uninstall`** (managed project dir only; confirm / `--force`).
- Ship-unit alias: **`self-upgrade`** → same as **`self-update`**.
- Product requirement: `docs/requirements/requirement-shell-payload-online-install.md` (registered in `index.md`).
- Tests expanded for payload layer isolation, combined empty argv, silent bad-channel detection (125 cases).

### Changed
- Empty argv no longer exits after first-time CLI self-install; continues into payload setup / run.
- Non-interactive re-run applies ship-unit update policy then payload ensure.
- Help documents **payload vs ship-unit** command layers.
- CLI interface / zero-arguments / domain / self-management requirements aligned to O-P command split.

### Notes
- Product **VERSION** `2.3.0`. Spring Boot **2.7.18** remains intentionally pinned.
- Companion: after edits to `./springboot2`, run  
  `sha256sum springboot2 | awk '{print $1}' > springboot2.sha256`

---

## [2.2.0] - 2026-07-15

### Changed (breaking for JSON consumers)
- **A naming (§3.1 option 1):** ship unit helpers renamed to bootstrap selfmanaged prefixes:
  - Output: `out_text` / `out_json` / `out_json_error` + `out_info` / `out_success` / `out_warn` / `out_error` / `out_die` / `out_plain` / …
  - Install lifecycle: `inst_perform_install`, `inst_maybe_install`, `inst_is_installed`, `inst_get_version`, `inst_self_update`, `inst_self_uninstall`
  - Dispatch: `app_main`, `app_help`, `app_about`
  - Version: `ver_gt`, `ver_check`
  - PATH: `path_add_shell`, `path_in_path`
  - Util / integrity: `util_sha256_file`, `util_verify_download_integrity`, `util_write_file_atomic`, `util_get_install_bin_path`, …
- JSON machine types for generic success/error: `"type":"out_success"` / `"type":"out_error"` (was `"success"` / `"error"`). Domain types (`about`, `version`, `version_check`, `status`) unchanged.
- Quiet mode keeps `out_warn` on stderr (aligned with A).
- Requirements Implementation Notes / identity tables retargeted to live A names.

### Notes
- Product **VERSION** `2.2.0`. Spring Boot **2.7.18** remains intentionally pinned (domain).
- Companion hygiene: after any edit to `./springboot2`, run  
  `sha256sum springboot2 | awk '{print $1}' > springboot2.sha256`

---

## [2.1.0] - 2026-07-15

### Added
- Product law suite under `docs/requirements/` (shell Type 0 + **domain** + **storage**), registered in `index.md`.
- Hybrid empty-argv: not installed → install-ensure; installed → domain default run (`requirement-shell-cli-zero-arguments`).
- Storage resolve Option A: `STORAGE_DIR` env-overridable; `EFFECTIVE_STORAGE_DIR=$(util_resolve_storage)` in main; about surfaces `effective_storage` / `storage_dir`.
- Install integrity Shape A (companion `${SCRIPT_URL}.sha256`) + optional Shape B pin (`CHECKSUM`); helpers (then-named) `file_sha256`, `verify_download_integrity` — **renamed in 2.2.0** to `util_sha256_file` / `util_verify_download_integrity`.
- In-repo companion **`springboot2.sha256`** (publisher SSOT); CI asserts match.
- Full POSIX test suite (`tests/run.sh`) and GitHub Actions CI (`.github/workflows/ci.yml`).
- Domain command/flag wiring: `status`, `reinstall`, `--reset`, `--project-dir`, `--no-run`.

### Changed
- Product **target** and runtime **`VERSION` → 2.1.0** (README badge + ship unit Config).
- CLI `--force` sets `FORCE=1` and `FORCE_REINSTALL=1`.
- Naming law at release: live B families (`output_*`, lifecycle helpers, `main_spring_boot_app`, …) — **superseded by 2.2.0 A rename**.
- Domain run helper renamed to `run_springboot_project`; util helpers `util_resolve_storage`, `util_source_user_shell_config`.
- `SCRIPT_URL` uses `:=` so CI/local channel can override.

### Fixed
- Uninstall JSON without `--force` fail-closed (`confirm_required`; non-zero; binary remains).
- Install download failure exit propagation (no false success).
- JSON success message slot misuse on install/uninstall paths.
- Help↔dispatcher drift for advertised domain surface.

### Notes
- Spring Boot **2.7.18** remains intentionally pinned (domain).
- Regression baseline at 2.1.0 release: `./tests/run.sh` → PASS with FAIL=0 (109 cases including storage about fields).

---

## [2.0.1] - 2026-04 (maintenance)

### Changed
- Header and defensive-style maintenance on the 2.0 line.
- Refined JSON/quiet handling and continued CIAO enforcement.

### Notes
- Security review narrative for this line is retained in `README.md` / `RECOMMENDATION.md` as historical review of **v2.0.1**.

---

## [2.0.0] - 2026-04-14

### Major Changes
- **Bumped to version 2.0.0** — Major internal refactoring while preserving the original ultra-defensive CIAO coding style.
- Completely overhauled the output system (then-named `output_text` / `output_json`; **A-renamed in 2.2.0** to `out_text` / `out_json`).
- Full compliance with `--quiet` / `-q` and `--json` flags across the entire script.
- Strengthened root vs non-root installation isolation with install bin path helper.
- Added robust self-update safety (semver compare; prevents accidental downgrades).
- Improved interactive prompts with centralized `prompt_yes_no()` that fully respects `--quiet` and `--json`.
- Enhanced multi-user and harsh-environment support (storage isolation; early user shell config source).
- Added atomic file writing to prevent partial/corrupted config files.
- Updated help and about commands with cleaner, more consistent output and full JSON support.

### Bug Fixes
- Fixed missing or malformed JSON output for `self-update` and `version-check`.
- Eliminated raw user-facing `printf`/`echo` outside the official output functions.
- Corrected Alpine Linux instructions and SDKMAN setup messages to route through the output system.
- Fixed command parsing edge cases and improved error handling in JSON mode.

### Notes
- Spring Boot 2.7.18 remains **intentionally pinned** (no upgrade to newer lines).
- One-command install:  
  `curl -fsSL https://raw.githubusercontent.com/Wilgat/springboot2/main/springboot2 | bash`

---

## [1.14.0] - 2025 (Previous Stable)

- Initial mature version with solid CIAO defensive structure.
- Basic quiet/JSON support and installation logic.

---

**GitHub**: https://github.com/Wilgat/springboot2

[Unreleased]: https://github.com/Wilgat/springboot2/compare/2.3.1...HEAD
[2.3.1]: https://github.com/Wilgat/springboot2/compare/2.3.0...2.3.1
[2.3.0]: https://github.com/Wilgat/springboot2/compare/2.2.0...2.3.0
[2.2.0]: https://github.com/Wilgat/springboot2/compare/2.1.0...2.2.0
[2.1.0]: https://github.com/Wilgat/springboot2/compare/2.0.1...2.1.0
[2.0.1]: https://github.com/Wilgat/springboot2/compare/2.0.0...2.0.1
[2.0.0]: https://github.com/Wilgat/springboot2/releases/tag/2.0.0
