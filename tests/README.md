# Tests (springboot2)

POSIX `/bin/sh` CI suite for the Type 0 + domain ship unit `./springboot2`.

Specialized from the **selfmanaged** bootstrap suite: same layout (runner, helpers, CLI, install lifecycle) plus a **domain** suite for hybrid empty-argv and Spring Boot setup.

## Run locally

```sh
./tests/run.sh
```

Requires: `sh`, `curl`, `python3` (local HTTP channel), `sha256sum`, `grep`.

No public network for core lifecycle: install tests serve the checkout over `127.0.0.1`. Domain `--no-run` uses stub `sdk`/`java`/`mvn` under isolated `HOME` (does not install real SDKMAN/Java).

## What is covered

| Suite | File | Focus |
|-------|------|--------|
| CLI surface | `test_cli.sh` | `sh -n`, optional companion digest, `version` / `help` / `about` (human + JSON), domain flags on help, unknown command, quiet, no `CHECKSUM` on help/about, `env -u HOME`, zero-arg install failure, uninstall fail-closed **law** |
| Install lifecycle | `test_install_lifecycle.sh` | Isolated `HOME`/`USER_BIN`, local channel empty-argv first install, **hybrid** installed path with `--no-run` (not help), about installed, version-check JSON, self-update already-latest, uninstall force/refuse (may **fail** on live Gaps), skip automatic-checksum Shape A/B |
| Domain | `test_domain.sh` | Spring Boot pin in help, help↔dispatcher for `status`/`reinstall`/`--reset` (expected Gaps today), `--project-dir` + `--no-run` generate/preserve project, JSON `--no-run` |

**Version note:** suites source `PRODUCT_VERSION` / `APP_NAME` / `SPRINGBOOT_VER` from `./springboot2` via `helpers.sh`. Do not hardcode semver in new tests.

## Notes

| Item | Suite behavior |
|------|----------------|
| Companion `${APP_NAME}.sha256` | Asserted against ship unit (first field) |
| Shape A companion + Shape B `CHECKSUM` pin | Install path verifies; transparency messages asserted |
| No `install` subcommand | First install is empty argv only (by design) |

Product law naming: live `output_*` / lifecycle helpers (**§3.1 option 2**), not seed `out_*`/`inst_*`/`app_*`.

## Bootstrap specialize (A→B)

| Bootstrap A | Product B |
|-------------|-----------|
| `selfmanaged` Type 0 suite | This directory — `APP_NAME=springboot2`, hybrid empty argv, domain suite |

A’s tests alone do **not** prove B; always run `./tests/run.sh` in this repo.

## CI

Optional GitHub Actions: [`.github/workflows/ci.yml`](../.github/workflows/ci.yml) runs `./tests/run.sh` on push/PR.

No secrets and no root.
