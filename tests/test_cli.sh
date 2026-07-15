# =============================================================================
# tests/test_cli.sh — Type 0 CLI surface (no network install required)
# =============================================================================
# Covers: syntax, version, help, about, unknown command, quiet/json modes,
# help domain + Type 0 surface, env -u HOME, zero-arg install failure exit,
# self-uninstall fail-closed contract (law) vs live gaps.
# Live JSON type string is "error" / "success" (not seed out_error/out_success).
# =============================================================================

# shellcheck source=helpers.sh
. "${TESTS_ROOT}/helpers.sh"

run_test_cli() {
    t_header "CLI surface"

    require_cmd sh
    require_cmd sha256sum
    require_cmd grep

    # --- syntax ---
    sh -n "${SCRIPT}"
    _syn=$?
    assert_eq "sh -n ${APP_NAME} (syntax)" 0 "$_syn"

    # --- companion digest (Shape A) ---
    if [ -f "${REPO_ROOT}/${APP_NAME}.sha256" ]; then
        _expected=$(awk '{print $1}' "${REPO_ROOT}/${APP_NAME}.sha256" | tr -d ' \n\r\t')
        _actual=$(sha256sum "${SCRIPT}" | awk '{print $1}')
        assert_eq "${APP_NAME}.sha256 matches ship unit (first field)" "$_expected" "$_actual"
    else
        t_fail "${APP_NAME}.sha256 missing at repo root (Shape A companion required)"
    fi

    # --- version (human) ---
    _out=$(sh "${SCRIPT}" version 2>/dev/null)
    _ec=$?
    assert_eq "version exit 0" 0 "$_ec"
    assert_contains "version human mentions version" "$_out" "${PRODUCT_VERSION}"
    assert_contains "version human mentions app" "$_out" "${APP_NAME}"

    # --- version (json) ---
    _out=$(sh "${SCRIPT}" --json version 2>/dev/null)
    _ec=$?
    assert_eq "version --json exit 0" 0 "$_ec"
    assert_contains "version --json type" "$_out" '"type":"version"'
    assert_contains "version --json app" "$_out" "\"app\":\"${APP_NAME}\""
    assert_contains "version --json version field" "$_out" "\"version\":\"${PRODUCT_VERSION}\""

    # --- help (human): Type 0 + domain surface ---
    _out=$(sh "${SCRIPT}" help 2>/dev/null)
    _ec=$?
    assert_eq "help exit 0" 0 "$_ec"
    assert_contains "help lists version-check" "$_out" "version-check"
    assert_contains "help lists self-update" "$_out" "self-update"
    assert_contains "help lists self-uninstall" "$_out" "self-uninstall"
    assert_contains "help lists about" "$_out" "about"
    assert_contains "help lists --json" "$_out" "--json"
    assert_contains "help lists --no-run" "$_out" "--no-run"
    assert_contains "help lists --project-dir" "$_out" "--project-dir"
    assert_contains "help mentions Spring Boot pin" "$_out" "${SPRINGBOOT_VER}"
    assert_not_contains "help must not list CHECKSUM" "$_out" "CHECKSUM"

    # --- help (json): short object, not full prose ---
    _out=$(sh "${SCRIPT}" --json help 2>/dev/null)
    _ec=$?
    assert_eq "help --json exit 0" 0 "$_ec"
    assert_contains "help --json type success" "$_out" '"type":"success"'
    assert_contains "help --json mentions human mode" "$_out" "Help text"

    # --- about (json): no CHECKSUM field ---
    _out=$(sh "${SCRIPT}" --json about 2>/dev/null)
    _ec=$?
    assert_eq "about --json exit 0" 0 "$_ec"
    assert_contains "about --json type" "$_out" '"type":"about"'
    assert_contains "about --json app" "$_out" "\"app\":\"${APP_NAME}\""
    assert_not_contains "about --json must not include CHECKSUM" "$_out" "CHECKSUM"

    # --- unknown command (die → exit 1; live JSON type "error") ---
    _err=$(sh "${SCRIPT}" no-such-command 2>&1 >/dev/null)
    _ec=$?
    assert_eq "unknown command exit 1" 1 "$_ec"
    assert_contains "unknown command error text" "$_err" "Invalid command"

    # JSON errors go to stdout via output_json; capture both streams
    _err=$(sh "${SCRIPT}" --json no-such-command 2>&1)
    _ec=$?
    assert_eq "unknown command --json exit 1" 1 "$_ec"
    assert_contains "unknown command --json type error" "$_err" '"type":"error"'

    # --- quiet: version should not print info banners ---
    _out=$(sh "${SCRIPT}" --quiet version 2>/dev/null)
    _ec=$?
    assert_eq "version --quiet exit 0" 0 "$_ec"
    if [ -z "$_out" ]; then
        t_pass "version --quiet suppresses human info"
    else
        _trim=$(printf '%s' "$_out" | tr -d ' \t\n\r')
        if [ -z "$_trim" ]; then
            t_pass "version --quiet suppresses human info"
        else
            t_fail "version --quiet expected empty stdout, got '$(_trunc "$_out")'"
        fi
    fi

    # --- HOME unset under set -u (INC-20260713-001 pattern) ---
    _out=$(env -u HOME sh "${SCRIPT}" version 2>/dev/null)
    _ec=$?
    assert_eq "env -u HOME version exit 0" 0 "$_ec"
    assert_contains "env -u HOME version still reports version" "$_out" "${PRODUCT_VERSION}"

    # --- zero-arg auto-install propagates failure (not exit 0 on download fail) ---
    # Empty argv only (no --json flag — auto-install gate is $# -eq 0).
    ci_isolated_env
    _errf="${CI_HOME}/zero-arg-err.txt"
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" \
        SCRIPT_URL="http://127.0.0.1:1/${APP_NAME}-unreachable" \
        sh "${SCRIPT}" </dev/null 2>"${_errf}"
    )
    _ec=$?
    _err=$(cat "${_errf}" 2>/dev/null || true)
    if [ "$_ec" -ne 0 ]; then
        t_pass "zero-arg failed install exits non-zero"
    else
        t_fail "zero-arg failed install expected non-zero exit, got 0 (stdout='$(_trunc "$_out")' err='$(_trunc "$_err")')"
    fi
    assert_file_missing "zero-arg failed install left no binary" "${CI_USER_BIN}/${APP_NAME}"
    ci_cleanup_env

    # --- self-uninstall fail-closed (product law / INC-20260713-002) ---
    # Live Gap: --force does not set FORCE_REINSTALL; JSON cancel uses broken
    # output_json arg order. Assert law: refuse without force; binary remains.
    ci_isolated_env
    mkdir -p "${CI_USER_BIN}"
    cp "${SCRIPT}" "${CI_USER_BIN}/${APP_NAME}"
    chmod +x "${CI_USER_BIN}/${APP_NAME}"
    _errf="${CI_HOME}/un-err.txt"
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" \
        sh "${SCRIPT}" --json self-uninstall 2>"${_errf}"
    )
    _ec=$?
    _err=$(cat "${_errf}" 2>/dev/null || true)
    # Law: non-zero + confirm_required. Live may wrong-exit 0 with success cancel.
    if [ "$_ec" -ne 0 ]; then
        t_pass "self-uninstall --json without --force exit non-zero"
    else
        t_fail "self-uninstall --json without --force expected non-zero (INC-002), got 0 out='$(_trunc "$_out$_err")'"
    fi
    assert_file_exists "binary remains without --force" "${CI_USER_BIN}/${APP_NAME}"
    # Must not claim success cancel as machine success with wrong schema only
    if printf '%s' "${_out}${_err}" | grep -q 'confirm_required'; then
        t_pass "self-uninstall exposes confirm_required when refusing"
    else
        t_fail "self-uninstall law expects confirm_required code (live Gap if missing): '$(_trunc "${_out}${_err}")'"
    fi
    ci_cleanup_env
}
