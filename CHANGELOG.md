# Changelog

All notable changes to **springboot2** will be documented in this file.

This project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html) and the [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) format.

---

## [Unreleased]

*(Nothing yet — next work goes here.)*

---

## [2.1.0] - 2026-07-15

### Added
- Product law suite under `docs/requirements/` (shell Type 0 + **domain** + **storage**), registered in `index.md`.
- Hybrid empty-argv: not installed → install-ensure; installed → domain default run (`requirement-shell-cli-zero-arguments`).
- Storage resolve Option A: `STORAGE_DIR` env-overridable; `EFFECTIVE_STORAGE_DIR=$(util_resolve_storage)` in main; about surfaces `effective_storage` / `storage_dir`.
- Install integrity Shape A (companion `${SCRIPT_URL}.sha256`) + optional Shape B pin (`CHECKSUM`); helpers `file_sha256`, `verify_download_integrity`.
- In-repo companion **`springboot2.sha256`** (publisher SSOT); CI asserts match.
- Full POSIX test suite (`tests/run.sh`) and GitHub Actions CI (`.github/workflows/ci.yml`).
- Domain command/flag wiring: `status`, `reinstall`, `--reset`, `--project-dir`, `--no-run`.

### Changed
- Product **target** and runtime **`VERSION` → 2.1.0** (README badge + ship unit Config).
- CLI `--force` sets `FORCE=1` and `FORCE_REINSTALL=1`.
- Naming law: live families (`output_*`, lifecycle helpers, `main_spring_boot_app`, `setup_*`, `run_springboot_project`) — not bootstrap seed `out_*`/`inst_*`/`app_*` (§3.1 option 2).
- Domain run helper renamed to `run_springboot_project`; util helpers `util_resolve_storage`, `util_source_user_shell_config`.
- `SCRIPT_URL` uses `:=` so CI/local channel can override.

### Fixed
- Uninstall JSON without `--force` fail-closed (`confirm_required`; non-zero; binary remains).
- Install download failure exit propagation (no false success).
- `output_json` success message slot misuse on install/uninstall paths.
- Help↔dispatcher drift for advertised domain surface.

### Notes
- Spring Boot **2.7.18** remains intentionally pinned (domain).
- Regression baseline at release: `./tests/run.sh` → PASS with FAIL=0 (109 cases including storage about fields).
- Companion hygiene: after any edit to `./springboot2`, run  
  `sha256sum springboot2 | awk '{print $1}' > springboot2.sha256`

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
- Completely overhauled the output system:
  - Introduced `output_text()` as the **single source of truth** for all human-readable text.
  - Introduced `output_json()` as the **single source of truth** for all machine-readable JSON output.
  - Full compliance with `--quiet` / `-q` and `--json` flags across the entire script.
- Strengthened root vs non-root installation isolation with new `get_install_bin_path()` helper.
- Added robust self-update safety:
  - Pure POSIX `version_gt()` function for semantic version comparison.
  - Prevents accidental downgrades when a newer development version is already installed.
  - Proper JSON support for `self-update` (including already-latest and newer-local cases).
- Improved interactive prompts with centralized `prompt_yes_no()` that fully respects `--quiet` and `--json`.
- Enhanced multi-user and harsh-environment support:
  - Better per-user storage isolation via storage resolver helpers.
  - Early sourcing of user shell configuration for reliable SDKMAN/Java/Maven availability in non-login shells.
- Added atomic file writing with `write_file_atomic()` to prevent partial/corrupted config files.
- Updated help and about commands with cleaner, more consistent output and full JSON support.
- Added explicit single-source-of-truth enforcement reminders in key functions to protect against future simplification by AI assistants or maintainers.
- Improved defensive coding throughout:
  - Repeated safe variable defaults in more functions.
  - More consistent respect for `--quiet`, `--json`, `--force`, `--reset`, `--project-dir`, and `--no-run` flags.

### Bug Fixes
- Fixed missing or malformed JSON output for `self-update` and `version-check`.
- Eliminated all raw `printf`/`echo`/`cat` outside the official output functions (full single-source-of-truth compliance).
- Corrected Alpine Linux instructions and SDKMAN setup messages to route through the output system (colors and quiet/JSON modes now work correctly).
- Fixed command parsing edge cases and improved error handling in JSON mode.

### Other Improvements
- Updated function headers with clearer GENERAL PURPOSE descriptions and explicit mentions of supported flags (`--quiet`, `--json`, `--force`, `--reset`, etc.).
- Better documentation and warnings to guide future maintainers and AI assistants.
- Maintained full backward compatibility for the one-command install:  
  `curl -fsSL https://raw.githubusercontent.com/Wilgat/springboot2/main/springboot2 | bash`

### Notes
- Spring Boot 2.7.18 remains **intentionally pinned** (no upgrade to newer lines).
- This release focuses on reliability, maintainability, and robustness in harsh environments (containers, Alpine, Git Bash, multi-user systems, non-interactive shells) without sacrificing the project's defensive "verbose-on-purpose" philosophy.

---

## [1.14.0] - 2025 (Previous Stable)

- Initial mature version with solid CIAO defensive structure.
- Basic quiet/JSON support and installation logic.

---

**GitHub**: https://github.com/Wilgat/springboot2

[Unreleased]: https://github.com/Wilgat/springboot2/compare/2.1.0...HEAD
[2.1.0]: https://github.com/Wilgat/springboot2/compare/2.0.1...2.1.0
[2.0.1]: https://github.com/Wilgat/springboot2/compare/2.0.0...2.0.1
[2.0.0]: https://github.com/Wilgat/springboot2/releases/tag/2.0.0
