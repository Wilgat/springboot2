# =============================================================================
# tests/test_install_lifecycle.sh — install / hybrid empty-argv / version-check /
# self-update / self-uninstall with local HTTP channel (no public network)
# =============================================================================
# springboot2 has no `install` subcommand: first install is empty argv (Type O).
# Installed empty argv is **domain run** (hybrid) — not pure install no-op;
# pure install re-run is tested via already-installed perform path when we re-hit
# install helpers, and hybrid is covered in test_domain.sh.
# =============================================================================

# shellcheck source=helpers.sh
. "${TESTS_ROOT}/helpers.sh"

run_test_install_lifecycle() {
    t_header "Install lifecycle (local channel)"

    require_cmd curl
    require_cmd python3
    require_cmd sha256sum

    ci_isolated_env
    if ! ci_start_channel; then
        ci_cleanup_env
        return 1
    fi

    _sm_bin="${CI_USER_BIN}/${APP_NAME}"
    _errf="${CI_HOME}/lc-err.txt"

    # --- first install via empty argv (Type O Case A, non-TTY auto-install) ---
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" SCRIPT_URL="${CI_SCRIPT_URL}" \
        sh "${SCRIPT}" </dev/null 2>"${_errf}"
    )
    _ec=$?
    _err=$(cat "${_errf}" 2>/dev/null || true)
    assert_eq "empty-argv first install exit 0" 0 "$_ec"
    assert_file_exists "installed binary exists" "${_sm_bin}"
    assert_contains "first install success message" "$_out$_err" "successfully installed"

    # --- re-run empty argv when installed: hybrid domain (NOT help, NOT install no-op only) ---
    # Use --no-run + stub toolchain so CI stays offline and does not exec Java forever.
    ci_stub_domain_toolchain
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" SCRIPT_URL="${CI_SCRIPT_URL}" \
        PATH="${CI_STUB_BIN}:${PATH}" \
        sh "${SCRIPT}" --no-run </dev/null 2>"${_errf}"
    )
    _ec=$?
    _err=$(cat "${_errf}" 2>/dev/null || true)
    assert_eq "empty-argv installed hybrid --no-run exit 0" 0 "$_ec"
    assert_not_contains "installed empty argv must not dump help Usage" "$_out$_err" "Quick Setup & Runner"
    # Domain path messages (setup completed / project) — avoid nested quotes in case patterns (dash)
    _combo="${_out}${_err}"
    if printf '%s' "$_combo" | grep -qE 'no-run|Project location|setup completed|SDKMAN|Spring Boot'; then
        t_pass "installed path exercises domain setup (not install no-op only)"
    elif printf '%s' "$_combo" | grep -q 'already installed'; then
        t_fail "installed empty argv must not be install-only no-op (hybrid supersession); got already-installed only"
    else
        t_fail "installed hybrid expected domain setup signals, got '$(_trunc "$_combo")'"
    fi

    # --- pure install re-ensure via re-download force path: empty argv does not re-install ---
    # Binary still present and executable after domain path
    assert_file_exists "binary still present after domain --no-run" "${_sm_bin}"

    # --- zero-arg Case C detect: global path present (inst_inst_is_installed true) still not help ---
    _global_bin="${CI_HOME}/global-bin"
    mkdir -p "${_global_bin}"
    cp "${SCRIPT}" "${_global_bin}/${APP_NAME}"
    chmod +x "${_global_bin}/${APP_NAME}"
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${_global_bin}" \
        SCRIPT_URL="${CI_SCRIPT_URL}" PATH="${CI_STUB_BIN}:${PATH}" \
        sh "${SCRIPT}" --no-run </dev/null 2>"${_errf}"
    )
    _ec=$?
    _err=$(cat "${_errf}" 2>/dev/null || true)
    assert_eq "installed (global detect) --no-run exit 0" 0 "$_ec"
    assert_not_contains "global-installed empty argv must not dump help" "$_out$_err" "Quick Setup & Runner"
    rm -f "${_global_bin}/${APP_NAME}"

    # --- about shows installed ---
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" SCRIPT_URL="${CI_SCRIPT_URL}" \
        sh "${SCRIPT}" --json about 2>/dev/null
    )
    _ec=$?
    assert_eq "about after install exit 0" 0 "$_ec"
    assert_contains "about installed true" "$_out" '"installed":"true"'

    # --- version-check against local channel ---
    # Bootstrap A schema: type ver_check, keys local_version / remote_version / is_latest
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" SCRIPT_URL="${CI_SCRIPT_URL}" \
        PATH="${CI_USER_BIN}:${PATH}" \
        sh "${_sm_bin}" --json version-check 2>"${_errf}"
    )
    _ec=$?
    _err=$(cat "${_errf}" 2>/dev/null || true)
    assert_eq "version-check --json exit 0" 0 "$_ec"
    assert_contains "version-check --json type" "$_out" '"type":"ver_check"'
    assert_contains "version-check --json remote_version" "$_out" "\"remote_version\":\"${PRODUCT_VERSION}\""
    assert_contains "version-check --json local_version" "$_out" "\"local_version\":\"${PRODUCT_VERSION}\""

    # human version-check
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" SCRIPT_URL="${CI_SCRIPT_URL}" \
        PATH="${CI_USER_BIN}:${PATH}" \
        sh "${_sm_bin}" version-check 2>/dev/null
    )
    _ec=$?
    assert_eq "version-check human exit 0" 0 "$_ec"
    assert_contains "version-check human mentions Latest" "$_out" "Latest version"

    # --- self-update already-latest ---
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" SCRIPT_URL="${CI_SCRIPT_URL}" \
        PATH="${CI_USER_BIN}:${PATH}" \
        sh "${_sm_bin}" --json self-update 2>"${_errf}"
    )
    _ec=$?
    _err=$(cat "${_errf}" 2>/dev/null || true)
    assert_eq "self-update already-latest exit 0" 0 "$_ec"
    assert_contains "self-update already-latest success type" "$_out" '"type":"out_success"'
    assert_contains "self-update already-latest message" "$_out" "Already running the latest version"

    # --- human force reinstall: Shape A companion transparency ---
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" SCRIPT_URL="${CI_SCRIPT_URL}" \
        sh "${SCRIPT}" --force </dev/null 2>"${_errf}"
    )
    # --force alone may run domain after install; reinstall via empty argv force needs install path.
    # Use FORCE_REINSTALL via --force with not-only-empty: call perform path by reinstall --no-run after uninstall
    # Prefer explicit download path: remove binary then empty-argv install (channel has companion)
    HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" FORCE_REINSTALL=1 \
        PATH="${CI_USER_BIN}:${PATH}" \
        sh "${_sm_bin}" --json --force self-uninstall >/dev/null 2>&1 || rm -f "${_sm_bin}"
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" SCRIPT_URL="${CI_SCRIPT_URL}" \
        sh "${SCRIPT}" </dev/null 2>"${_errf}"
    )
    _ec=$?
    _err=$(cat "${_errf}" 2>/dev/null || true)
    assert_eq "human install with companion exit 0" 0 "$_ec"
    assert_file_exists "binary after companion install" "${_sm_bin}"
    assert_contains "human install companion link" "$_out$_err" "Companion link:"
    assert_contains "human install expected digest" "$_out$_err" "Expected SHA-256:"
    assert_contains "human install actual digest" "$_out$_err" "Actual SHA-256:"
    assert_contains "human install PASS result" "$_out$_err" "Automatic checksum result: PASS"
    assert_contains "human install verified flag message" "$_out$_err" "cryptographically verified"

    # --- self-uninstall without --force: refuse ---
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" SCRIPT_URL="${CI_SCRIPT_URL}" \
        PATH="${CI_USER_BIN}:${PATH}" \
        sh "${_sm_bin}" --json self-uninstall 2>"${_errf}"
    )
    _ec=$?
    _err=$(cat "${_errf}" 2>/dev/null || true)
    assert_file_exists "binary remains after uninstall without force" "${_sm_bin}"
    if [ "$_ec" -ne 0 ]; then
        t_pass "lifecycle self-uninstall --json no force non-zero"
    else
        t_fail "lifecycle self-uninstall --json no force expected non-zero, got 0"
    fi

    # --- self-uninstall --force removes ---
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" SCRIPT_URL="${CI_SCRIPT_URL}" \
        PATH="${CI_USER_BIN}:${PATH}" \
        sh "${_sm_bin}" --json --force self-uninstall 2>"${_errf}"
    )
    _ec=$?
    _err=$(cat "${_errf}" 2>/dev/null || true)
    if [ ! -e "${_sm_bin}" ]; then
        t_pass "binary removed after --force self-uninstall"
        assert_eq "self-uninstall --json --force exit 0" 0 "$_ec"
    else
        t_fail "binary still present after --force self-uninstall; out='$(_trunc "$_out$_err")'"
    fi

    # --- reinstall for Shape B / downgrade tests ---
    if [ ! -e "${_sm_bin}" ]; then
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" SCRIPT_URL="${CI_SCRIPT_URL}" \
            sh "${SCRIPT}" </dev/null >/dev/null 2>&1 || true
    fi

    # --- CHECKSUM pin Shape B mismatch / match ---
    # Empty argv + JSON=1 env hits inst_perform_install (flag parse not used; $# -eq 0).
    rm -f "${_sm_bin}"
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" SCRIPT_URL="${CI_SCRIPT_URL}" \
        JSON=1 QUIET=1 \
        CHECKSUM="0000000000000000000000000000000000000000000000000000000000000000" \
        sh "${SCRIPT}" </dev/null 2>"${_errf}"
    )
    _ec=$?
    _err=$(cat "${_errf}" 2>/dev/null || true)
    assert_nonzero "CHECKSUM mismatch aborts (non-zero)" "$_ec"
    assert_contains "CHECKSUM mismatch code" "$_out$_err" "checksum_mismatch"
    assert_file_missing "no install after bad CHECKSUM" "${_sm_bin}"

    _good=$(sha256sum "${SCRIPT}" | awk '{print $1}')
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" SCRIPT_URL="${CI_SCRIPT_URL}" \
        JSON=1 QUIET=1 CHECKSUM="${_good}" \
        sh "${SCRIPT}" </dev/null 2>"${_errf}"
    )
    _ec=$?
    assert_eq "CHECKSUM match install exit 0" 0 "$_ec"
    assert_file_exists "install with good CHECKSUM" "${_sm_bin}"

    # --- downgrade gate (live: returns success with newer-local message, not downgrade_blocked) ---
    if [ -e "${_sm_bin}" ] && [ -n "${CI_CHANNEL_DIR:-}" ]; then
        _older="${CI_CHANNEL_DIR}/${APP_NAME}"
        # shellcheck disable=SC2016
        sed "s/^VERSION=\"${PRODUCT_VERSION}\"/VERSION=\"0.9.0\"/" "${SCRIPT}" > "${_older}"
        printf '%s\n' "$(sha256sum "${_older}" | awk '{print $1}')" > "${CI_CHANNEL_DIR}/${APP_NAME}.sha256"

        _out=$(
            HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" SCRIPT_URL="${CI_SCRIPT_URL}" \
            PATH="${CI_USER_BIN}:${PATH}" \
            sh "${_sm_bin}" --json self-update 2>"${_errf}"
        )
        _ec=$?
        _err=$(cat "${_errf}" 2>/dev/null || true)
        # Bootstrap A: refuse silent downgrade with non-zero exit
        if [ "$_ec" -ne 0 ]; then
            t_pass "self-update refuse-downgrade path non-zero (A)"
        else
            t_fail "self-update refuse-downgrade expected non-zero, got 0"
        fi
        if printf '%s' "${_out}${_err}" | grep -qiE 'newer|already|latest|downgrade|refuse'; then
            t_pass "self-update reports non-downgrade without force"
        else
            t_fail "self-update unexpected refuse-downgrade output: '$(_trunc "${_out}${_err}")'"
        fi
        _loc=$(grep '^VERSION="' "${_sm_bin}" | cut -d'"' -f2)
        assert_eq "local version unchanged after refused downgrade" "${PRODUCT_VERSION}" "$_loc"
    else
        t_skip "downgrade gate (binary missing after force-uninstall Gap)"
    fi

    # cleanup: best-effort remove with FORCE_REINSTALL env if --force flag broken
    if [ -e "${_sm_bin}" ]; then
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" FORCE_REINSTALL=1 \
            PATH="${CI_USER_BIN}:${PATH}" \
            sh "${_sm_bin}" --json --force self-uninstall >/dev/null 2>&1 || \
            rm -f "${_sm_bin}"
    fi

    ci_stop_channel
    ci_cleanup_env
}
