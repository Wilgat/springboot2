# =============================================================================
# tests/test_install_lifecycle.sh — Type O-P payload online installer
# ship-unit (self-*) + payload (install/uninstall) + combined empty argv
# =============================================================================
# requirement-shell-payload-online-install.md
# - empty argv: ship unit + payload (not binary-only exit)
# - install/uninstall = payload; self-update/self-uninstall = CLI
# =============================================================================

# shellcheck source=helpers.sh
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
    assert_eq "empty-argv first combined ensure exit 0" 0 "$_ec"
    assert_file_exists "installed binary exists after empty argv" "${_sm_bin}"
    assert_contains "first install ship success or payload signals" "$_out$_err" "install"
    # Payload must have been entered (project or setup messages) — not binary-only silence
    _combo="${_out}${_err}"
    if printf '%s' "$_combo" | grep -qE 'successfully installed|Payload|setup completed|Project location|SDKMAN|Preparing Spring'; then
        t_pass "empty-argv combined ensure produced ship and/or payload messages"
    else
        t_fail "empty-argv silent or binary-only without messages: '$(_trunc "$_combo")'"
    fi
    # Project created under default dir when payload ran
    _def_proj="${CI_HOME}/springboot-${APP_NAME}"
    if [ -d "${_def_proj}" ] || [ -f "${_def_proj}/pom.xml" ]; then
        t_pass "empty-argv first run created payload project"
    else
        # If only ship installed without payload → fail Type O-P
        if [ -e "${_sm_bin}" ] && ! printf '%s' "$_combo" | grep -qE 'Payload|setup completed|Preparing Spring|Project'; then
            t_fail "Type O-P regression: ship binary present but payload not entered"
        else
            t_fail "payload project missing after empty-argv combined ensure"
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
    assert_eq "payload install exit 0" 0 "$_ec"
    assert_file_exists "payload install created pom" "${_proj}/pom.xml"
    assert_contains "payload install success" "$_out$_err" "Payload"
    assert_file_exists "CLI still present after payload install" "${_sm_bin}"

    # --- payload uninstall without force: refuse ---
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" \
        PATH="${CI_STUB_BIN}:${PATH}" \
        bash "${SCRIPT}" --json uninstall --project-dir "${_proj}" 2>"${_errf}"
    )
    _ec=$?
    _err=$(cat "${_errf}" 2>/dev/null || true)
    assert_nonzero "payload uninstall without force non-zero" "$_ec"
    assert_contains "payload uninstall confirm_required" "$_out$_err" "confirm_required"
    assert_file_exists "project remains without force" "${_proj}/pom.xml"
    assert_file_exists "CLI remains after payload uninstall refuse" "${_sm_bin}"

    # --- payload uninstall --force: removes project only ---
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" \
        PATH="${CI_STUB_BIN}:${PATH}" \
        bash "${SCRIPT}" --json --force uninstall --project-dir "${_proj}" 2>"${_errf}"
    )
    _ec=$?
    assert_eq "payload uninstall --force exit 0" 0 "$_ec"
    assert_file_missing "project removed by payload uninstall" "${_proj}"
    assert_file_exists "CLI remains after payload uninstall" "${_sm_bin}"

    # --- self-uninstall without --force: refuse; binary remains ---
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" SCRIPT_URL="${CI_SCRIPT_URL}" \
        PATH="${CI_USER_BIN}:${PATH}" \
        bash "${_sm_bin}" --json self-uninstall 2>"${_errf}"
    )
    _ec=$?
    assert_file_exists "binary remains after self-uninstall without force" "${_sm_bin}"
    assert_nonzero "self-uninstall --json no force non-zero" "$_ec"

    # --- about shows installed ---
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" SCRIPT_URL="${CI_SCRIPT_URL}" \
        bash "${SCRIPT}" --json about 2>/dev/null
    )
    _ec=$?
    assert_eq "about after install exit 0" 0 "$_ec"
    assert_contains "about installed true" "$_out" '"installed":"true"'

    # --- version-check ---
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" SCRIPT_URL="${CI_SCRIPT_URL}" \
        PATH="${CI_USER_BIN}:${PATH}" \
        bash "${_sm_bin}" --json version-check 2>"${_errf}"
    )
    _ec=$?
    assert_eq "version-check --json exit 0" 0 "$_ec"
    assert_contains "version-check type" "$_out" '"type":"ver_check"'
    assert_contains "version-check remote" "$_out" "\"remote_version\":\"${PRODUCT_VERSION}\""

    # --- self-update already-latest ---
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" SCRIPT_URL="${CI_SCRIPT_URL}" \
        PATH="${CI_USER_BIN}:${PATH}" \
        bash "${_sm_bin}" --json self-update 2>"${_errf}"
    )
    _ec=$?
    assert_eq "self-update already-latest exit 0" 0 "$_ec"
    assert_contains "self-update success type" "$_out" '"type":"out_success"'

    # --- self-upgrade alias ---
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" SCRIPT_URL="${CI_SCRIPT_URL}" \
        PATH="${CI_USER_BIN}:${PATH}" \
        bash "${_sm_bin}" --json self-upgrade 2>"${_errf}"
    )
    _ec=$?
    assert_eq "self-upgrade alias exit 0" 0 "$_ec"

    # --- companion transparency on ship reinstall (self-update --force path) ---
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" SCRIPT_URL="${CI_SCRIPT_URL}" \
        PATH="${CI_USER_BIN}:${CI_STUB_BIN}:${PATH}" \
        bash "${_sm_bin}" --force self-update 2>"${_errf}"
    )
    _ec=$?
    _err=$(cat "${_errf}" 2>/dev/null || true)
    assert_eq "self-update --force exit 0" 0 "$_ec"
    assert_contains "force update companion link" "$_out$_err" "Companion link:"
    assert_contains "force update PASS" "$_out$_err" "Automatic checksum result: PASS"

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
    assert_nonzero "CHECKSUM mismatch aborts" "$_ec"
    assert_contains "CHECKSUM mismatch code" "$_out$_err" "checksum_mismatch"
    assert_file_missing "no binary after bad CHECKSUM" "${_sm_bin}"

    _good=$(sha256sum "${SCRIPT}" | awk '{print $1}')
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" SCRIPT_URL="${CI_SCRIPT_URL}" \
        JSON=1 QUIET=1 CHECKSUM="${_good}" PATH="${CI_STUB_BIN}:${PATH}" NO_RUN=1 \
        bash "${SCRIPT}" </dev/null 2>"${_errf}"
    )
    _ec=$?
    assert_eq "CHECKSUM match install exit 0" 0 "$_ec"
    assert_file_exists "install with good CHECKSUM" "${_sm_bin}"

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
        assert_nonzero "self-update refuse-downgrade non-zero" "$_ec"
        if printf '%s' "${_out}${_err}" | grep -qiE 'newer|already|latest|downgrade|refuse'; then
            t_pass "self-update reports non-downgrade without force"
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
    assert_eq "self-uninstall --force exit 0" 0 "$_ec"
    assert_file_missing "CLI removed by self-uninstall" "${_sm_bin}"
    assert_file_exists "payload project NOT removed by self-uninstall" "${_keep_proj}/KEEP.txt"

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
    assert_nonzero "bad channel empty-argv non-zero" "$_ec"
    if [ -n "${_out}${_err}" ]; then
        t_pass "bad channel produces visible error output"
    else
        t_fail "bad channel silent failure (no stdout/stderr) — INC-20260720-001 class"
    fi
    assert_file_missing "bad channel left no binary" "${_sm_bin}"

    ci_stop_channel
    ci_cleanup_env
}
