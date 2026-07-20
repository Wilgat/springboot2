# =============================================================================
# tests/test_domain.sh — Spring Boot domain surface (offline-friendly)
# =============================================================================
# Covers: help domain flags, status/reinstall/--reset, install payload,
# --project-dir + --no-run project preserve, Type O-P empty argv + payload
# with stub SDKMAN (no public network, no real Java install).
# Law: requirement-springboot2-domain.md + requirement-shell-payload-online-install.md
# =============================================================================

# shellcheck source=helpers.sh
. "${TESTS_ROOT}/helpers.sh"

run_test_domain() {
    t_header "Domain surface"

    require_cmd sh
    require_cmd grep

    # --- help documents domain (already partially in CLI; reinforce pin + flags) ---
    _out=$(sh "${SCRIPT}" help 2>/dev/null)
    assert_contains "domain help: Spring Boot pin" "$_out" "${SPRINGBOOT_VER}"
    assert_contains "domain help: --no-run" "$_out" "--no-run"
    assert_contains "domain help: --project-dir" "$_out" "--project-dir"
    assert_contains "domain help: --reset advertised" "$_out" "--reset"
    assert_contains "domain help: status advertised" "$_out" "status"
    assert_contains "domain help: reinstall advertised" "$_out" "reinstall"
    assert_contains "domain help: install advertised" "$_out" "install"
    assert_contains "domain help: uninstall advertised" "$_out" "uninstall"

    # --- ship install + payload under isolated HOME ---
    require_cmd curl
    require_cmd python3
    require_cmd sha256sum

    ci_isolated_env
    if ! ci_start_channel; then
        ci_cleanup_env
        return 1
    fi

    _sm_bin="${CI_USER_BIN}/${APP_NAME}"
    _errf="${CI_HOME}/dom-err.txt"
    _proj="${CI_HOME}/my-demo-project"

    ci_stub_domain_toolchain
    # Type O-P: empty argv with NO_RUN continues to payload after ship place
    HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" SCRIPT_URL="${CI_SCRIPT_URL}" \
        PATH="${CI_STUB_BIN}:${PATH}" NO_RUN=1 \
        sh "${SCRIPT}" </dev/null >/dev/null 2>"${_errf}"
    _ec=$?
    assert_eq "domain suite: empty-argv combined ensure exit 0" 0 "$_ec"
    assert_file_exists "domain suite: binary installed" "${_sm_bin}"

    # help↔dispatcher: status (about alias) under isolation
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" SCRIPT_URL="${CI_SCRIPT_URL}" \
        PATH="${CI_STUB_BIN}:${PATH}" \
        sh "${SCRIPT}" status 2>"${_errf}"
    )
    _ec=$?
    _err=$(cat "${_errf}" 2>/dev/null || true)
    if [ "$_ec" -eq 0 ]; then
        t_pass "status command routed (exit 0)"
    else
        t_fail "status advertised in help but dispatcher rejects it (help↔dispatcher Gap): '$(_trunc "$_err$_out")'"
    fi

    # explicit payload install command
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" SCRIPT_URL="${CI_SCRIPT_URL}" \
        PATH="${CI_STUB_BIN}:${PATH}" \
        sh "${SCRIPT}" install --project-dir "${_proj}" 2>"${_errf}"
    )
    _ec=$?
    _err=$(cat "${_errf}" 2>/dev/null || true)
    assert_eq "payload install command exit 0" 0 "$_ec"
    assert_file_exists "payload install pom" "${_proj}/pom.xml"

    # reinstall: force CLI reinstall + domain; use --no-run to stay offline with stubs
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" SCRIPT_URL="${CI_SCRIPT_URL}" \
        PATH="${CI_STUB_BIN}:${PATH}" \
        sh "${SCRIPT}" reinstall --no-run --project-dir "${_proj}" 2>"${_errf}"
    )
    _ec=$?
    _err=$(cat "${_errf}" 2>/dev/null || true)
    if [ "$_ec" -eq 0 ]; then
        t_pass "reinstall command routed (exit 0)"
    else
        t_fail "reinstall advertised in help but failed (help↔dispatcher Gap): '$(_trunc "$_err$_out")'"
    fi

    # domain --no-run with custom project dir
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" SCRIPT_URL="${CI_SCRIPT_URL}" \
        PATH="${CI_STUB_BIN}:${PATH}" \
        sh "${SCRIPT}" --project-dir "${_proj}" --no-run 2>"${_errf}"
    )
    _ec=$?
    _err=$(cat "${_errf}" 2>/dev/null || true)
    assert_eq "domain --no-run --project-dir exit 0" 0 "$_ec"
    assert_file_exists "project dir created" "${_proj}"
    assert_file_exists "pom.xml generated" "${_proj}/pom.xml"
    assert_contains "pom pins Spring Boot" "$(cat "${_proj}/pom.xml")" "${SPRINGBOOT_VER}"
    assert_file_exists "main class generated" "${_proj}/src/main/java/com/example/HelloApplication.java"
    assert_file_exists "application.properties" "${_proj}/src/main/resources/application.properties"
    if printf '%s' "${_out}${_err}" | grep -qE "setup completed|no-run|${_proj}"; then
        t_pass "domain --no-run reports setup completion / project path"
    else
        t_fail "domain --no-run missing success signals: '$(_trunc "${_out}${_err}")'"
    fi

    # --- preserve: second --no-run must not wipe custom marker ---
    printf 'KEEP-ME\n' > "${_proj}/USER_MARK.txt"
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" SCRIPT_URL="${CI_SCRIPT_URL}" \
        PATH="${CI_STUB_BIN}:${PATH}" \
        sh "${SCRIPT}" --project-dir "${_proj}" --no-run 2>"${_errf}"
    )
    _ec=$?
    assert_eq "domain re-run preserve exit 0" 0 "$_ec"
    assert_file_exists "user marker preserved (no wipe without force)" "${_proj}/USER_MARK.txt"
    _mark=$(cat "${_proj}/USER_MARK.txt" 2>/dev/null || true)
    assert_eq "user marker content preserved" "KEEP-ME" "$_mark"

    # --- JSON --no-run ---
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" SCRIPT_URL="${CI_SCRIPT_URL}" \
        PATH="${CI_STUB_BIN}:${PATH}" \
        sh "${SCRIPT}" --json --project-dir "${_proj}" --no-run 2>"${_errf}"
    )
    _ec=$?
    assert_eq "domain --json --no-run exit 0" 0 "$_ec"
    assert_contains "domain --json --no-run type success" "$_out" '"type":"out_success"'
    assert_contains "domain --json --no-run no_run true" "$_out" '"no_run":"true"'
    assert_contains "domain --json --no-run project_dir" "$_out" "project_dir"

    # --- --reset flag: advertised; if unwired, project may still preserve (Gap) ---
    # Do not require wipe; document whether --reset regenerates.
    printf 'KEEP-RESET\n' > "${_proj}/USER_MARK.txt"
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" SCRIPT_URL="${CI_SCRIPT_URL}" \
        PATH="${CI_STUB_BIN}:${PATH}" \
        sh "${SCRIPT}" --reset --project-dir "${_proj}" --no-run 2>"${_errf}"
    )
    _ec=$?
    _err=$(cat "${_errf}" 2>/dev/null || true)
    if [ ! -e "${_proj}/USER_MARK.txt" ]; then
        t_pass "--reset wiped project marker (wired)"
    else
        t_fail "--reset advertised but did not reset project (help↔dispatcher / FORCE_REINSTALL Gap); mark still present"
    fi

    # cleanup install
    rm -f "${_sm_bin}"
    ci_stop_channel
    ci_cleanup_env
}
