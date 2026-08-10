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
| CLI surface | `test_cli.sh` | **TP-CLI-*** + **TP-U-*** / **TP-CSUM-05** / **TP-MOD-***: syntax, companion, version/help/about, quiet/json, storage, unknown, zero-arg fail, set -u, uninstall refuse, modular prefixes |
| Install lifecycle | `test_install_lifecycle.sh` | **TP-LC-*** + **TP-CSUM-***: combined ensure, payload install/uninstall, self-*, downgrade, checksum pin, bad channel |
| Online curl install | `test_online_curl_install.sh` | **TP-CURL-*** (+ **TP-U-04** pipe): local channel pipes; optional `RUN_ONLINE_CURL_TESTS=1` |
| Domain | `test_domain.sh` | **TP-DOM-***: pins, scaffold, preserve/reset, JSON, status/reinstall, payload uninstall isolation |

**Silent-failure class:** 0-byte stdout+stderr after one-liner = fail (`assert_not_silent`).  

**Product requirement ↔ test matrix:** `reviews/requirement-test-matrix.md`  
**Per-TP status map:** `reviews/test-plan.md` (includes primary requirement column)  
**Living review plan:** `reviews/what-to-review.md` · lessons: `reviews/lessons.md`

**Version note:** suites source `PRODUCT_VERSION` / `APP_NAME` / `SPRINGBOOT_VER` from `./springboot2` via `helpers.sh`. Do not hardcode semver in new tests.

### Optional online gate

```sh
RUN_ONLINE_CURL_TESTS=1 ./tests/run.sh
# or override channel:
RUN_ONLINE_CURL_TESTS=1 ONLINE_SCRIPT_URL='https://raw.githubusercontent.com/Wilgat/springboot2/main/springboot2' ./tests/run.sh
```

## Notes

| Item | Suite behavior |
|------|----------------|
| Companion `${APP_NAME}.sha256` | Asserted against ship unit (first field) |
| Shape A companion + Shape B `CHECKSUM` pin | Install path verifies; transparency messages asserted |
| No `install` subcommand | First install is empty argv only (by design) |

Product law naming: A prefixes `out_*`/`inst_*`/`app_*` (**§3.1 option 1**).

## Bootstrap specialize (A→B)

| Bootstrap A | Product B |
|-------------|-----------|
| `selfmanaged` Type 0 suite | This directory — `APP_NAME=springboot2`, hybrid empty argv, domain suite |

A’s tests alone do **not** prove B; always run `./tests/run.sh` in this repo.

## CI

Optional GitHub Actions: [`.github/workflows/ci.yml`](../.github/workflows/ci.yml) runs `./tests/run.sh` on push/PR.

No secrets and no root.
