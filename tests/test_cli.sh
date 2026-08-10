# =============================================================================
# tests/test_cli.sh — Type 0 CLI surface (no network install required)
# =============================================================================
# Design-time: declare TP-CLI / TP-U / TP-CSUM-05 when specializing:
#   requirement-shell-cli-interface
#   requirement-shell-output-requirements
#   requirement-shell-cli-storage
#   requirement-shell-cli-zero-arguments (TP-CLI-09, TP-U)
#   requirement-shell-self-management (TP-CLI-11)
#   requirement-shell-automatic-checksum (TP-CSUM-05)
#   requirement-shell-interactive-vs-noninteractive
# Status map: reviews/test-plan.md · matrix: reviews/requirement-test-matrix.md
# Modular: TP-MOD-01/02 · requirement-shell-modular-function-design
# =============================================================================

. "${TESTS_ROOT}/helpers.sh"

run_test_cli() {
    t_header "CLI surface"

    require_cmd sh
    require_cmd sha256sum
    require_cmd grep

    # --- syntax ---
    bash -n "${SCRIPT}"
    _syn=$?
    assert_eq "TP-CLI-01 bash -n syntax" 0 "$_syn"

    # --- companion digest (Shape A) ---
    if [ -f "${REPO_ROOT}/${APP_NAME}.sha256" ]; then
        _expected=$(awk '{print $1}' "${REPO_ROOT}/${APP_NAME}.sha256" | tr -d ' \n\r\t')
        _actual=$(sha256sum "${SCRIPT}" | awk '{print $1}')
        assert_eq "TP-CLI-01 sha256 matches ship unit" "$_expected" "$_actual"
    else
        t_fail "TP-CLI-01 sha256 missing"
    fi

    # --- version (human) ---
    _out=$(bash "${SCRIPT}" version 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-02 version exit 0" 0 "$_ec"
    assert_contains "TP-CLI-02 version human version" "$_out" "${PRODUCT_VERSION}"
    assert_contains "TP-CLI-02 version human app" "$_out" "${APP_NAME}"

    # --- version (json) ---
    _out=$(bash "${SCRIPT}" --json version 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-02 version --json exit 0" 0 "$_ec"
    assert_contains "TP-CLI-02 version --json type" "$_out" '"type":"version"'
    assert_contains "TP-CLI-02 version --json app" "$_out" "\"app\":\"${APP_NAME}\""
    assert_contains "TP-CLI-02 version --json version field" "$_out" "\"version\":\"${PRODUCT_VERSION}\""

    # --- help (human): Type 0 + domain surface ---
    _out=$(bash "${SCRIPT}" help 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-03 help exit 0" 0 "$_ec"
    assert_contains "TP-CLI-03 help lists version-check" "$_out" "version-check"
    assert_contains "TP-CLI-03 help lists self-update" "$_out" "self-update"
    assert_contains "TP-CLI-03 help lists self-uninstall" "$_out" "self-uninstall"
    assert_contains "TP-CLI-03 help lists self-upgrade" "$_out" "self-upgrade"
    assert_contains "TP-CLI-03 help lists payload install" "$_out" "install"
    assert_contains "TP-CLI-03 help lists payload uninstall" "$_out" "uninstall"
    assert_contains "TP-CLI-03 help lists about" "$_out" "about"
    assert_contains "TP-CLI-03 help lists --json" "$_out" "--json"
    assert_contains "TP-CLI-03 help lists --no-run" "$_out" "--no-run"
    assert_contains "TP-CLI-03 help lists --project-dir" "$_out" "--project-dir"
    assert_contains "TP-CLI-03 help Spring Boot pin" "$_out" "${SPRINGBOOT_VER}"
    assert_contains "TP-CLI-03 help payload vs ship" "$_out" "Payload"
    assert_not_contains "TP-CSUM-05 help must not list CHECKSUM" "$_out" "CHECKSUM"

    # --- help (json): short object, not full prose ---
    _out=$(bash "${SCRIPT}" --json help 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-04 help --json exit 0" 0 "$_ec"
    assert_contains "TP-CLI-04 help --json type" "$_out" '"type":"out_success"'
    assert_contains "TP-CLI-04 help --json human mode" "$_out" "Help text"

    # --- about (json): no CHECKSUM field; storage resolve fields ---
    _out=$(bash "${SCRIPT}" --json about 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-04 about --json exit 0" 0 "$_ec"
    assert_contains "TP-CLI-04 about --json type" "$_out" '"type":"about"'
    assert_contains "TP-CLI-04 about --json app" "$_out" "\"app\":\"${APP_NAME}\""
    assert_not_contains "TP-CSUM-05 about no CHECKSUM" "$_out" "CHECKSUM"
    assert_contains "TP-CLI-05 about effective_storage" "$_out" '"effective_storage"'
    assert_contains "TP-CLI-05 about storage_dir" "$_out" '"storage_dir"'
    assert_contains "TP-CLI-05 about storage app name" "$_out" "${APP_NAME}"

    # --- storage resolve isolation (Option A: EFFECTIVE_STORAGE_DIR via util_resolve_storage) ---
    ci_isolated_env
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" \
        bash "${SCRIPT}" --json about 2>/dev/null
    )
    _ec=$?
    assert_eq "TP-CLI-05 about isolated HOME" 0 "$_ec"
    # Must isolate by app name; user may be real username even under isolated HOME
    assert_contains "TP-CLI-05 isolated effective_storage" "$_out" "${APP_NAME}"
    # effective_storage is often /dev/shm or /tmp when writable — still must contain APP_NAME
    case "$_out" in
        *'"effective_storage":"'*"${APP_NAME}"*) t_pass "TP-CLI-05 effective_storage path app" ;;
        *) t_fail "effective_storage missing app isolation in: $(_trunc "$_out")" ;;
    esac
    # STORAGE_DIR fallback field should reference cache path with app+user shape
    assert_contains "TP-CLI-05 storage_dir under isolation" "$_out" '"storage_dir"'
    # STORAGE_DIR env override appears on storage_dir (tier-3 config field), not necessarily effective
    _custom="${CI_HOME}/custom-storage-root"
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" STORAGE_DIR="${_custom}" \
        bash "${SCRIPT}" --json about 2>/dev/null
    )
    _ec=$?
    assert_eq "TP-CLI-05 STORAGE_DIR override exit" 0 "$_ec"
    assert_contains "TP-CLI-05 storage_dir honors STORAGE_DIR" "$_out" "custom-storage-root"
    # Effective root must exist after resolve (create-before-return)
    _eff=$(printf '%s' "$_out" | sed -n 's/.*"effective_storage":"\([^"]*\)".*/\1/p' | head -n1)
    if [ -n "$_eff" ] && [ -d "$_eff" ]; then
        t_pass "TP-CLI-05 effective_storage dir exists"
    else
        t_fail "effective_storage missing or not a directory: '$(_trunc "${_eff:-empty}")'"
    fi
    # Username isolation segment present in effective path (id -un under isolation)
    _who=$(id -un 2>/dev/null || echo unknown)
    case "$_out" in
        *'"effective_storage":"'*"${_who}"*|*'"effective_storage":"'*"unknown"*) \
            t_pass "TP-CLI-05 effective_storage user segment" ;;
        *) t_fail "effective_storage missing user segment for '${_who}': $(_trunc "$_out")" ;;
    esac
    ci_cleanup_env

    # --- unknown command (out_die → exit 1; JSON type "out_error") ---
    _err=$(bash "${SCRIPT}" no-such-command 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-CLI-06 unknown command exit 1" 1 "$_ec"
    assert_contains "TP-CLI-06 unknown command error text" "$_err" "Invalid command"

    # JSON errors go to stdout via out_json; capture both streams
    _err=$(bash "${SCRIPT}" --json no-such-command 2>&1)
    _ec=$?
    assert_eq "TP-CLI-06 unknown --json exit 1" 1 "$_ec"
    assert_contains "TP-CLI-06 unknown --json type error" "$_err" '"type":"out_error"'

    # --- quiet: version should not print info banners ---
    _out=$(bash "${SCRIPT}" --quiet version 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-07 version --quiet exit 0" 0 "$_ec"
    if [ -z "$_out" ]; then
        t_pass "TP-CLI-07 quiet suppresses info"
    else
        _trim=$(printf '%s' "$_out" | tr -d ' \t\n\r')
        if [ -z "$_trim" ]; then
            t_pass "TP-CLI-07 quiet suppresses info"
        else
            t_fail "version --quiet expected empty stdout, got '$(_trunc "$_out")'"
        fi
    fi

    # --- HOME unset under set -u (INC-20260713-001 pattern) ---
    _out=$(env -u HOME bash "${SCRIPT}" version 2>/dev/null)
    _ec=$?
    assert_eq "TP-U-01 env -u HOME version exit 0" 0 "$_ec"
    assert_contains "TP-U-01 env -u HOME reports version" "$_out" "${PRODUCT_VERSION}"

    # --- zero-arg auto-install propagates failure (not exit 0 on download fail) ---
    # Empty argv only (no --json flag — auto-install gate is $# -eq 0).
    ci_isolated_env
    _errf="${CI_HOME}/zero-arg-err.txt"
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" \
        SCRIPT_URL="http://127.0.0.1:1/${APP_NAME}-unreachable" \
        bash "${SCRIPT}" </dev/null 2>"${_errf}"
    )
    _ec=$?
    _err=$(cat "${_errf}" 2>/dev/null || true)
    if [ "$_ec" -ne 0 ]; then
        t_pass "TP-CLI-09 zero-arg fail non-zero"
    else
        t_fail "zero-arg failed install expected non-zero exit, got 0 (stdout='$(_trunc "$_out")' err='$(_trunc "$_err")')"
    fi
    assert_file_missing "TP-CLI-09 zero-arg fail no binary" "${CI_USER_BIN}/${APP_NAME}"
    if [ -n "${_out}${_err}" ]; then
        t_pass "TP-CLI-09 zero-arg fail not silent"
    else
        t_fail "zero-arg failed install silent (no stdout/stderr) — INC-20260720-001"
    fi
    ci_cleanup_env

    # --- INC-20260720-001: bashrc that sources sdkman-init under set -u must not silent-abort ---
    ci_isolated_env
    mkdir -p "${CI_USER_BIN}" "${CI_HOME}/.sdkman/bin"
    cp "${SCRIPT}" "${CI_USER_BIN}/${APP_NAME}"
    chmod +x "${CI_USER_BIN}/${APP_NAME}"
    # Minimal sdkman-init that expands unbound vars when set -u is on (real SDKMAN does this)
    cat > "${CI_HOME}/.sdkman/bin/sdkman-init.sh" <<'EOF'
#!/usr/bin/env bash
if [ -z "$SDKMAN_CANDIDATES_API" ]; then
export SDKMAN_CANDIDATES_API="https://api.sdkman.io/2"
fi
sdk() { return 0; }
EOF
    cat > "${CI_HOME}/.bashrc" <<EOF
export SDKMAN_DIR="\${HOME}/.sdkman"
[ -s "\${HOME}/.sdkman/bin/sdkman-init.sh" ] && . "\${HOME}/.sdkman/bin/sdkman-init.sh"
EOF
    ci_stub_domain_toolchain
    _errf="${CI_HOME}/sdkman-bashrc-err.txt"
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" PATH="${CI_STUB_BIN}:${CI_USER_BIN}:${PATH}" \
        NO_RUN=1 \
        bash "${SCRIPT}" --no-run </dev/null 2>"${_errf}"
    )
    _ec=$?
    _err=$(cat "${_errf}" 2>/dev/null || true)
    if [ -n "${_out}${_err}" ]; then
        t_pass "TP-U-03 bashrc+sdkman not silent"
    else
        t_fail "bashrc+sdkman silent abort (0 bytes out) — set -u source bug"
    fi
    # Must not die before any product messaging solely from sourcing bashrc
    if printf '%s' "${_out}${_err}" | grep -qE 'SDKMAN|Payload|setup|Spring|INFO|OK|ERROR|already'; then
        t_pass "TP-U-03 bashrc+sdkman product messages"
    else
        t_fail "bashrc+sdkman no product messages: '$(_trunc "${_out}${_err}")'"
    fi
    ci_cleanup_env

    # --- self-uninstall fail-closed (product law / INC-20260713-002) ---
    # Live Gap: --force does not set FORCE_REINSTALL; JSON cancel uses broken
    # out_json arg order. Assert law: refuse without force; binary remains.
    ci_isolated_env
    mkdir -p "${CI_USER_BIN}"
    cp "${SCRIPT}" "${CI_USER_BIN}/${APP_NAME}"
    chmod +x "${CI_USER_BIN}/${APP_NAME}"
    _errf="${CI_HOME}/un-err.txt"
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" \
        bash "${SCRIPT}" --json self-uninstall 2>"${_errf}"
    )
    _ec=$?
    _err=$(cat "${_errf}" 2>/dev/null || true)
    # Law: non-zero + confirm_required. Live may wrong-exit 0 with success cancel.
    if [ "$_ec" -ne 0 ]; then
        t_pass "TP-CLI-11 self-uninstall refuse non-zero"
    else
        t_fail "self-uninstall --json without --force expected non-zero (INC-002), got 0 out='$(_trunc "$_out$_err")'"
    fi
    assert_file_exists "TP-CLI-11 binary remains without force" "${CI_USER_BIN}/${APP_NAME}"
    # Must not claim success cancel as machine success with wrong schema only
    if printf '%s' "${_out}${_err}" | grep -q 'confirm_required'; then
        t_pass "TP-CLI-11 confirm_required"
    else
        t_fail "self-uninstall law expects confirm_required code (live Gap if missing): '$(_trunc "${_out}${_err}")'"
    fi
    ci_cleanup_env

    # --- TP-U-05: safe external source helper present (set -u Case C) ---
    if grep -q 'util_source_external_safe' "${SCRIPT}"; then
        t_pass "TP-U-05 util_source_external_safe present"
    else
        t_fail "TP-U-05 missing util_source_external_safe (set -u Case C)"
    fi

    # --- TP-CLI-02 about human (non-json) ---
    _out=$(bash "${SCRIPT}" about 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-02 about human exit 0" 0 "$_ec"
    assert_contains "TP-CLI-02 about human mentions app" "$_out" "${APP_NAME}"

    # --- TP-MOD-01: A-prefix modular families present (product law §3.1 option 1) ---
    for _fn in out_text out_success out_error out_die inst_perform_install inst_maybe_install \
        inst_is_installed app_main app_help app_about util_resolve_storage; do
        if grep -qE "^${_fn}\\(\\)|^${_fn} \\(\\)" "${SCRIPT}" 2>/dev/null \
            || grep -qE "^${_fn}\\(\\)" "${SCRIPT}"; then
            t_pass "TP-MOD-01 ${_fn} present"
        elif grep -q "${_fn}()" "${SCRIPT}"; then
            t_pass "TP-MOD-01 ${_fn} present"
        else
            t_fail "TP-MOD-01 missing modular helper: ${_fn}"
        fi
    done

    # --- TP-MOD-02: product source must not cite template-*/skill-* as behavioral authority ---
    # Allow educational "never cite template" lines in comments; forbid "see template-X as authority" style.
    if grep -nE 'requirement-(class|shell|domain)-' "${SCRIPT}" >/dev/null \
        && ! grep -nE 'as (behavioral )?authority.*template-|cite `?template-|authority: `?template-' "${SCRIPT}" >/dev/null; then
        # Fail if product code treats template/skill as the law path (not merely forbidding it)
        if grep -nE '^\s*#.*(see|per|from|follow)\s+`?(template|skill)-' "${SCRIPT}" >/dev/null; then
            t_fail "TP-MOD-02 product cites template/skill as law: $(grep -nE '^\s*#.*(see|per|from|follow)\s+`?(template|skill)-' "${SCRIPT}" | head -3)"
        else
            t_pass "TP-MOD-02 no template/skill authority cites in ship unit"
        fi
    else
        # Still pass if no bad authority pattern even without requirement cites
        if grep -nE '^\s*#.*(see|per|from|follow)\s+`?(template|skill)-' "${SCRIPT}" >/dev/null; then
            t_fail "TP-MOD-02 product cites template/skill as law"
        else
            t_pass "TP-MOD-02 no template/skill authority cites in ship unit"
        fi
    fi
}
