# =============================================================================
# tests/test_domain.sh — Spring Boot domain surface (TP-DOM-*)
# =============================================================================
# Design-time: declare TP-DOM when specializing:
#   requirement-domain-springboot2
#   requirement-shell-payload-online-install (payload layer)
#   requirement-shell-cli-zero-arguments (empty argv domain ensure)
# Status map: docs/reviews/test-plan.md · matrix: docs/reviews/requirement-test-matrix.md
# =============================================================================

. "${TESTS_ROOT}/helpers.sh"

run_test_domain() {
    t_header "Domain surface"

    require_cmd sh
    require_cmd grep

    # --- help documents domain (already partially in CLI; reinforce pin + flags) ---
    _out=$(bash "${SCRIPT}" help 2>/dev/null)
    assert_contains "TP-DOM-02 help Spring Boot pin" "$_out" "${SPRINGBOOT_VER}"
    assert_contains "TP-DOM-01 help --no-run" "$_out" "--no-run"
    assert_contains "TP-DOM-01 help --project-dir" "$_out" "--project-dir"
    assert_contains "TP-DOM-01 help --reset" "$_out" "--reset"
    assert_contains "TP-DOM-01 help status" "$_out" "status"
    assert_contains "TP-DOM-01 help reinstall" "$_out" "reinstall"
    assert_contains "TP-DOM-01 help install" "$_out" "install"
    assert_contains "TP-DOM-01 help uninstall" "$_out" "uninstall"

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
        bash "${SCRIPT}" </dev/null >/dev/null 2>"${_errf}"
    _ec=$?
    assert_eq "TP-DOM-03 empty-argv ensure exit 0" 0 "$_ec"
    assert_file_exists "TP-DOM-03 binary installed" "${_sm_bin}"

    # help↔dispatcher: status (about alias) under isolation
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" SCRIPT_URL="${CI_SCRIPT_URL}" \
        PATH="${CI_STUB_BIN}:${PATH}" \
        bash "${SCRIPT}" status 2>"${_errf}"
    )
    _ec=$?
    _err=$(cat "${_errf}" 2>/dev/null || true)
    if [ "$_ec" -eq 0 ]; then
        t_pass "TP-DOM-08 status routed"
    else
        t_fail "status advertised in help but dispatcher rejects it (help↔dispatcher Gap): '$(_trunc "$_err$_out")'"
    fi

    # explicit payload install command
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" SCRIPT_URL="${CI_SCRIPT_URL}" \
        PATH="${CI_STUB_BIN}:${PATH}" \
        bash "${SCRIPT}" install --project-dir "${_proj}" 2>"${_errf}"
    )
    _ec=$?
    _err=$(cat "${_errf}" 2>/dev/null || true)
    assert_eq "TP-DOM-04 payload install exit 0" 0 "$_ec"
    assert_file_exists "TP-DOM-04 payload install pom" "${_proj}/pom.xml"

    # reinstall: force CLI reinstall + domain; use --no-run to stay offline with stubs
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" SCRIPT_URL="${CI_SCRIPT_URL}" \
        PATH="${CI_STUB_BIN}:${PATH}" \
        bash "${SCRIPT}" reinstall --no-run --project-dir "${_proj}" 2>"${_errf}"
    )
    _ec=$?
    _err=$(cat "${_errf}" 2>/dev/null || true)
    if [ "$_ec" -eq 0 ]; then
        t_pass "TP-DOM-08 reinstall routed"
    else
        t_fail "reinstall advertised in help but failed (help↔dispatcher Gap): '$(_trunc "$_err$_out")'"
    fi

    # domain --no-run with custom project dir
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" SCRIPT_URL="${CI_SCRIPT_URL}" \
        PATH="${CI_STUB_BIN}:${PATH}" \
        bash "${SCRIPT}" --project-dir "${_proj}" --no-run 2>"${_errf}"
    )
    _ec=$?
    _err=$(cat "${_errf}" 2>/dev/null || true)
    assert_eq "TP-DOM-04 --no-run --project-dir exit 0" 0 "$_ec"
    assert_file_exists "TP-DOM-04 project dir created" "${_proj}"
    assert_file_exists "TP-DOM-04 pom generated" "${_proj}/pom.xml"
    assert_contains "TP-DOM-04 pom Spring Boot pin" "$(cat "${_proj}/pom.xml")" "${SPRINGBOOT_VER}"
    assert_file_exists "TP-DOM-04 main class" "${_proj}/src/main/java/com/example/HelloApplication.java"
    assert_file_exists "TP-DOM-04 application.properties" "${_proj}/src/main/resources/application.properties"
    if printf '%s' "${_out}${_err}" | grep -qE "setup completed|no-run|${_proj}"; then
        t_pass "TP-DOM-04 setup completion"
    else
        t_fail "domain --no-run missing success signals: '$(_trunc "${_out}${_err}")'"
    fi

    # --- preserve: second --no-run must not wipe custom marker ---
    printf 'KEEP-ME\n' > "${_proj}/USER_MARK.txt"
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" SCRIPT_URL="${CI_SCRIPT_URL}" \
        PATH="${CI_STUB_BIN}:${PATH}" \
        bash "${SCRIPT}" --project-dir "${_proj}" --no-run 2>"${_errf}"
    )
    _ec=$?
    assert_eq "TP-DOM-05 preserve exit 0" 0 "$_ec"
    assert_file_exists "TP-DOM-05 marker preserved" "${_proj}/USER_MARK.txt"
    _mark=$(cat "${_proj}/USER_MARK.txt" 2>/dev/null || true)
    assert_eq "TP-DOM-05 marker content" "KEEP-ME" "$_mark"

    # --- JSON --no-run ---
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" SCRIPT_URL="${CI_SCRIPT_URL}" \
        PATH="${CI_STUB_BIN}:${PATH}" \
        bash "${SCRIPT}" --json --project-dir "${_proj}" --no-run 2>"${_errf}"
    )
    _ec=$?
    assert_eq "TP-DOM-07 json --no-run exit 0" 0 "$_ec"
    assert_contains "TP-DOM-07 json type success" "$_out" '"type":"out_success"'
    assert_contains "TP-DOM-07 json no_run" "$_out" '"no_run":"true"'
    assert_contains "TP-DOM-07 json project_dir" "$_out" "project_dir"

    # --- --reset flag: advertised; if unwired, project may still preserve (Gap) ---
    # Do not require wipe; document whether --reset regenerates.
    printf 'KEEP-RESET\n' > "${_proj}/USER_MARK.txt"
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" SCRIPT_URL="${CI_SCRIPT_URL}" \
        PATH="${CI_STUB_BIN}:${PATH}" \
        bash "${SCRIPT}" --reset --project-dir "${_proj}" --no-run 2>"${_errf}"
    )
    _ec=$?
    _err=$(cat "${_errf}" 2>/dev/null || true)
    if [ ! -e "${_proj}/USER_MARK.txt" ]; then
        t_pass "TP-DOM-06 --reset wiped marker"
    else
        t_fail "--reset advertised but did not reset project (help↔dispatcher / FORCE_REINSTALL Gap); mark still present"
    fi

    # --- TP-DOM-09: payload uninstall isolation (project only; CLI remains) ---
    _proj2="${CI_HOME}/dom-un-proj"
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" SCRIPT_URL="${CI_SCRIPT_URL}" \
        PATH="${CI_STUB_BIN}:${PATH}" \
        bash "${SCRIPT}" install --project-dir "${_proj2}" 2>"${_errf}"
    )
    _ec=$?
    assert_eq "TP-DOM-09 payload install for uninstall exit 0" 0 "$_ec"
    assert_file_exists "TP-DOM-09 project before uninstall" "${_proj2}/pom.xml"
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" SCRIPT_URL="${CI_SCRIPT_URL}" \
        PATH="${CI_STUB_BIN}:${PATH}" \
        bash "${SCRIPT}" --json uninstall --project-dir "${_proj2}" 2>"${_errf}"
    )
    _ec=$?
    _err=$(cat "${_errf}" 2>/dev/null || true)
    assert_nonzero "TP-DOM-09 uninstall without force non-zero" "$_ec"
    assert_file_exists "TP-DOM-09 project remains without force" "${_proj2}/pom.xml"
    assert_file_exists "TP-DOM-09 CLI remains on uninstall refuse" "${_sm_bin}"
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" SCRIPT_URL="${CI_SCRIPT_URL}" \
        PATH="${CI_STUB_BIN}:${PATH}" \
        bash "${SCRIPT}" --force uninstall --project-dir "${_proj2}" 2>"${_errf}"
    )
    _ec=$?
    assert_eq "TP-DOM-09 uninstall --force exit 0" 0 "$_ec"
    assert_file_missing "TP-DOM-09 project removed by uninstall --force" "${_proj2}"
    assert_file_exists "TP-DOM-09 CLI remains after payload uninstall" "${_sm_bin}"

    # cleanup install
    rm -f "${_sm_bin}"
    ci_stop_channel
    ci_cleanup_env
}
