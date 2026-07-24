# =============================================================================
# tests/test_install_lifecycle.sh — Type O-P install lifecycle (local channel)
# =============================================================================
# Design-time: declare TP-LC / TP-CSUM when specializing:
#   requirement-shell-payload-online-install
#   requirement-shell-cli-zero-arguments (TP-LC-01)
#   requirement-shell-self-management
#   requirement-shell-automatic-checksum
#   requirement-shell-idempotency
# Status map: docs/reviews/test-plan.md · matrix: docs/reviews/requirement-test-matrix.md
# =============================================================================

. "${TESTS_ROOT}/helpers.sh"

run_test_install_lifecycle() {
    t_header "Install lifecycle (payload online installer)"

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
    # Stubs required: Type O-P empty argv continues into payload after ship install
    ci_stub_domain_toolchain

    # --- first empty argv: ship unit + payload (must not exit binary-only) ---
    # Pure empty argv ($#=0). NO_RUN=1 via env skips build/run after payload setup.
    rm -f "${_sm_bin}"
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" SCRIPT_URL="${CI_SCRIPT_URL}" \
        PATH="${CI_STUB_BIN}:${PATH}" NO_RUN=1 \
        bash "${SCRIPT}" </dev/null 2>"${_errf}"
    )
    _ec=$?
    _err=$(cat "${_errf}" 2>/dev/null || true)
    assert_eq "TP-LC-01 empty-argv first ensure exit 0" 0 "$_ec"
    assert_file_exists "TP-LC-01 binary after empty argv" "${_sm_bin}"
    assert_contains "TP-LC-01 ship/payload signals" "$_out$_err" "install"
    # Payload must have been entered (project or setup messages) — not binary-only silence
    _combo="${_out}${_err}"
    if printf '%s' "$_combo" | grep -qE 'successfully installed|Payload|setup completed|Project location|SDKMAN|Preparing Spring'; then
        t_pass "TP-LC-01 combined messages"
    else
        t_fail "empty-argv silent or binary-only without messages: '$(_trunc "$_combo")'"
    fi
    # Project created under default dir when payload ran
    _def_proj="${CI_HOME}/springboot-${APP_NAME}"
    if [ -d "${_def_proj}" ] || [ -f "${_def_proj}/pom.xml" ]; then
        t_pass "TP-LC-01 payload project created"
    else
        # If only ship installed without payload → fail Type O-P
        if [ -e "${_sm_bin}" ] && ! printf '%s' "$_combo" | grep -qE 'Payload|setup completed|Preparing Spring|Project'; then
            t_fail "TP-LC-01 Type O-P binary-only"
        else
            t_fail "TP-LC-01 payload project missing"
        fi
    fi

    # --- explicit payload install command ---
    _proj="${CI_HOME}/payload-proj"
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" SCRIPT_URL="${CI_SCRIPT_URL}" \
        PATH="${CI_STUB_BIN}:${PATH}" \
        bash "${SCRIPT}" install --project-dir "${_proj}" 2>"${_errf}"
    )
    _ec=$?
    _err=$(cat "${_errf}" 2>/dev/null || true)
    assert_eq "TP-LC-02 payload install exit 0" 0 "$_ec"
    assert_file_exists "TP-LC-02 payload install pom" "${_proj}/pom.xml"
    assert_contains "TP-LC-02 payload install success" "$_out$_err" "Payload"
    assert_file_exists "TP-LC-02 CLI after payload install" "${_sm_bin}"

    # --- payload uninstall without force: refuse ---
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" \
        PATH="${CI_STUB_BIN}:${PATH}" \
        bash "${SCRIPT}" --json uninstall --project-dir "${_proj}" 2>"${_errf}"
    )
    _ec=$?
    _err=$(cat "${_errf}" 2>/dev/null || true)
    assert_nonzero "TP-LC-03 payload uninstall refuse non-zero" "$_ec"
    assert_contains "TP-LC-03 payload uninstall confirm_required" "$_out$_err" "confirm_required"
    assert_file_exists "TP-LC-03 project remains without force" "${_proj}/pom.xml"
    assert_file_exists "TP-LC-03 CLI after uninstall refuse" "${_sm_bin}"

    # --- payload uninstall --force: removes project only ---
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" \
        PATH="${CI_STUB_BIN}:${PATH}" \
        bash "${SCRIPT}" --json --force uninstall --project-dir "${_proj}" 2>"${_errf}"
    )
    _ec=$?
    assert_eq "TP-LC-03 payload uninstall --force exit 0" 0 "$_ec"
    assert_file_missing "TP-LC-03 project removed" "${_proj}"
    assert_file_exists "TP-LC-03 CLI after payload uninstall" "${_sm_bin}"

    # --- self-uninstall without --force: refuse; binary remains ---
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" SCRIPT_URL="${CI_SCRIPT_URL}" \
        PATH="${CI_USER_BIN}:${PATH}" \
        bash "${_sm_bin}" --json self-uninstall 2>"${_errf}"
    )
    _ec=$?
    assert_file_exists "TP-LC-07 binary after self-uninstall refuse" "${_sm_bin}"
    assert_nonzero "TP-LC-07 self-uninstall refuse non-zero" "$_ec"

    # --- about shows installed ---
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" SCRIPT_URL="${CI_SCRIPT_URL}" \
        bash "${SCRIPT}" --json about 2>/dev/null
    )
    _ec=$?
    assert_eq "TP-LC-04 about after install exit 0" 0 "$_ec"
    assert_contains "TP-LC-04 about installed true" "$_out" '"installed":"true"'

    # --- version-check ---
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" SCRIPT_URL="${CI_SCRIPT_URL}" \
        PATH="${CI_USER_BIN}:${PATH}" \
        bash "${_sm_bin}" --json version-check 2>"${_errf}"
    )
    _ec=$?
    assert_eq "TP-LC-04 version-check exit 0" 0 "$_ec"
    assert_contains "TP-LC-04 version-check type" "$_out" '"type":"ver_check"'
    assert_contains "TP-LC-04 version-check remote" "$_out" "\"remote_version\":\"${PRODUCT_VERSION}\""

    # --- self-update already-latest ---
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" SCRIPT_URL="${CI_SCRIPT_URL}" \
        PATH="${CI_USER_BIN}:${PATH}" \
        bash "${_sm_bin}" --json self-update 2>"${_errf}"
    )
    _ec=$?
    assert_eq "TP-LC-05 self-update already-latest" 0 "$_ec"
    assert_contains "TP-LC-05 self-update success type" "$_out" '"type":"out_success"'

    # --- self-upgrade alias ---
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" SCRIPT_URL="${CI_SCRIPT_URL}" \
        PATH="${CI_USER_BIN}:${PATH}" \
        bash "${_sm_bin}" --json self-upgrade 2>"${_errf}"
    )
    _ec=$?
    assert_eq "TP-LC-05 self-upgrade alias" 0 "$_ec"

    # --- companion transparency on ship reinstall (self-update --force path) ---
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" SCRIPT_URL="${CI_SCRIPT_URL}" \
        PATH="${CI_USER_BIN}:${CI_STUB_BIN}:${PATH}" \
        bash "${_sm_bin}" --force self-update 2>"${_errf}"
    )
    _ec=$?
    _err=$(cat "${_errf}" 2>/dev/null || true)
    assert_eq "TP-LC-06 self-update --force exit 0" 0 "$_ec"
    assert_contains "TP-CSUM-02 force update companion link" "$_out$_err" "Companion link:"
    assert_contains "TP-CSUM-02 force update PASS" "$_out$_err" "Automatic checksum result: PASS"

    # --- CHECKSUM mismatch (ship install only via empty argv JSON env) ---
    rm -f "${_sm_bin}"
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" SCRIPT_URL="${CI_SCRIPT_URL}" \
        JSON=1 QUIET=1 PATH="${CI_STUB_BIN}:${PATH}" NO_RUN=1 \
        CHECKSUM="0000000000000000000000000000000000000000000000000000000000000000" \
        bash "${SCRIPT}" </dev/null 2>"${_errf}"
    )
    _ec=$?
    _err=$(cat "${_errf}" 2>/dev/null || true)
    assert_nonzero "TP-CSUM-03 CHECKSUM mismatch aborts" "$_ec"
    assert_contains "TP-CSUM-03 CHECKSUM mismatch code" "$_out$_err" "checksum_mismatch"
    assert_file_missing "TP-CSUM-03 no binary after bad CHECKSUM" "${_sm_bin}"

    _good=$(sha256sum "${SCRIPT}" | awk '{print $1}')
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" SCRIPT_URL="${CI_SCRIPT_URL}" \
        JSON=1 QUIET=1 CHECKSUM="${_good}" PATH="${CI_STUB_BIN}:${PATH}" NO_RUN=1 \
        bash "${SCRIPT}" </dev/null 2>"${_errf}"
    )
    _ec=$?
    assert_eq "TP-CSUM-04 CHECKSUM match exit 0" 0 "$_ec"
    assert_file_exists "TP-CSUM-04 install with good CHECKSUM" "${_sm_bin}"

    # --- downgrade gate ---
    if [ -e "${_sm_bin}" ] && [ -n "${CI_CHANNEL_DIR:-}" ]; then
        _older="${CI_CHANNEL_DIR}/${APP_NAME}"
        sed "s/^VERSION=\"${PRODUCT_VERSION}\"/VERSION=\"0.9.0\"/" "${SCRIPT}" > "${_older}"
        printf '%s\n' "$(sha256sum "${_older}" | awk '{print $1}')" > "${CI_CHANNEL_DIR}/${APP_NAME}.sha256"
        _out=$(
            HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" SCRIPT_URL="${CI_SCRIPT_URL}" \
            PATH="${CI_USER_BIN}:${PATH}" \
            bash "${_sm_bin}" --json self-update 2>"${_errf}"
        )
        _ec=$?
        _err=$(cat "${_errf}" 2>/dev/null || true)
        assert_nonzero "TP-LC-08 refuse-downgrade non-zero" "$_ec"
        if printf '%s' "${_out}${_err}" | grep -qiE 'newer|already|latest|downgrade|refuse'; then
            t_pass "TP-LC-08 refuse-downgrade message"
        else
            t_fail "self-update refuse-downgrade unexpected: '$(_trunc "${_out}${_err}")'"
        fi
    fi

    # --- self-uninstall --force removes CLI only ---
    _keep_proj="${CI_HOME}/springboot-${APP_NAME}"
    mkdir -p "${_keep_proj}"
    printf 'x\n' > "${_keep_proj}/KEEP.txt"
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" SCRIPT_URL="${CI_SCRIPT_URL}" \
        PATH="${CI_USER_BIN}:${PATH}" \
        bash "${_sm_bin}" --json --force self-uninstall 2>"${_errf}"
    )
    _ec=$?
    assert_eq "TP-LC-07 self-uninstall --force exit 0" 0 "$_ec"
    assert_file_missing "TP-LC-07 CLI removed" "${_sm_bin}"
    assert_file_exists "TP-LC-07 payload kept" "${_keep_proj}/KEEP.txt"

    # --- silent empty-pipe detection (curl fail class) ---
    _out=$(printf '' | HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" sh 2>"${_errf}" || true)
    # empty bash is not our product; product must not claim success without running.
    # Product path: bad SCRIPT_URL empty argv must be non-zero and non-empty error.
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" \
        SCRIPT_URL="http://127.0.0.1:1/nope" PATH="${CI_STUB_BIN}:${PATH}" NO_RUN=1 \
        bash "${SCRIPT}" </dev/null 2>"${_errf}"
    )
    _ec=$?
    _err=$(cat "${_errf}" 2>/dev/null || true)
    assert_nonzero "TP-LC-09 bad channel non-zero" "$_ec"
    if [ -n "${_out}${_err}" ]; then
        t_pass "TP-LC-09 bad channel visible"
    else
        t_fail "bad channel silent failure (no stdout/stderr) — INC-20260720-001 class"
    fi
    assert_file_missing "TP-LC-09 bad channel no binary" "${_sm_bin}"

    ci_stop_channel
    ci_cleanup_env
}
