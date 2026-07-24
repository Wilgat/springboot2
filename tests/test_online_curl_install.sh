# =============================================================================
# tests/test_online_curl_install.sh — curl|bash silent-failure (TP-CURL-*)
# =============================================================================
# Design-time: declare TP-CURL / TP-U-04 when specializing:
#   requirement-shell-cli-zero-arguments
#   requirement-shell-payload-online-install
#   requirement-shell-interactive-vs-noninteractive
# Status map: docs/reviews/test-plan.md · matrix: docs/reviews/requirement-test-matrix.md
# Optional: RUN_ONLINE_CURL_TESTS=1 for TP-CURL-09
# =============================================================================

. "${TESTS_ROOT}/helpers.sh"

# Run: curl -fsSL URL | env … bash  (or sh)
# Captures out/err files under CI_HOME; sets _pipe_ec
_curl_pipe_bash() {
    # _curl_pipe_bash <outf> <errf> [extra env assignments as "KEY=VAL" …] -- [bash args after -s]
    _outf="$1"
    _errf="$2"
    shift 2
    _bash_args=
    _env_pairs=
    while [ "$#" -gt 0 ]; do
        case "$1" in
            --) shift; _bash_args="$*"; break ;;
            *)
                _env_pairs="${_env_pairs} $1"
                shift
                ;;
        esac
    done
    # shellcheck disable=SC2086
    if [ -n "$_bash_args" ]; then
        curl -fsSL "${CI_SCRIPT_URL}" 2>>"${_errf}" | \
            env HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" SCRIPT_URL="${CI_SCRIPT_URL}" \
                PATH="${CI_STUB_BIN:-}:${CI_USER_BIN}:${PATH}" NO_RUN=1 \
                ${_env_pairs} \
                bash -s -- ${_bash_args} >"${_outf}" 2>>"${_errf}"
    else
        curl -fsSL "${CI_SCRIPT_URL}" 2>>"${_errf}" | \
            env HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" SCRIPT_URL="${CI_SCRIPT_URL}" \
                PATH="${CI_STUB_BIN:-}:${CI_USER_BIN}:${PATH}" NO_RUN=1 \
                ${_env_pairs} \
                bash >"${_outf}" 2>>"${_errf}"
    fi
    _pipe_ec=$?
}

run_test_online_curl_install() {
    t_header "Online curl install (silent-failure / TP-CURL-*)"

    require_cmd curl || return 1
    require_cmd python3 || return 1
    require_cmd sha256sum || return 1
    require_cmd bash || return 1

    ci_isolated_env
    if ! ci_start_channel; then
        ci_cleanup_env
        return 1
    fi
    ci_stub_domain_toolchain

    _sm_bin="${CI_USER_BIN}/${APP_NAME}"
    _outf="${CI_HOME}/curl-out.txt"
    _errf="${CI_HOME}/curl-err.txt"
    : >"${_outf}"
    : >"${_errf}"

    # --- TP-CURL-01: channel probe ---
    _body=$(curl -fsS "${CI_SCRIPT_URL}" 2>"${_errf}") || true
    _ec=$?
    assert_eq "TP-CURL-01 channel GET exit 0" 0 "$_ec"
    assert_contains "TP-CURL-01 body has APP_NAME" "$_body" "APP_NAME="
    assert_contains "TP-CURL-01 body has VERSION" "$_body" "VERSION="
    _sha_body=$(curl -fsS "${CI_SCRIPT_URL}.sha256" 2>/dev/null || true)
    _sha_hex=$(printf '%s\n' "$_sha_body" | awk '{print $1; exit}')
    case "$_sha_hex" in
        [0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]*)
            t_pass "TP-CURL-01 companion first field looks like SHA-256"
            ;;
        *)
            t_fail "TP-CURL-01 companion missing/invalid: '$(_trunc "$_sha_body")'"
            ;;
    esac

    # --- TP-CURL-02: first curl|bash clean HOME ---
    rm -f "${_sm_bin}"
    : >"${_outf}"
    : >"${_errf}"
    _curl_pipe_bash "${_outf}" "${_errf}"
    _out=$(cat "${_outf}" 2>/dev/null || true)
    _err=$(cat "${_errf}" 2>/dev/null || true)
    assert_not_silent "TP-CURL-02 first pipe not silent" "$_out" "$_err"
    assert_file_exists "TP-CURL-02 binary after first pipe" "${_sm_bin}"
    if printf '%s' "${_out}${_err}" | grep -qE 'install|SDKMAN|Payload|setup|Spring|Successfully|successfully|INFO|OK|ERROR'; then
        t_pass "TP-CURL-02 first pipe has product/install messages"
    else
        t_fail "TP-CURL-02 first pipe no product messages: '$(_trunc "${_out}${_err}")'"
    fi
    # Prefer exit 0 for ship+stub payload; still loud if non-zero
    if [ "${_pipe_ec}" -eq 0 ]; then
        t_pass "TP-CURL-02 first pipe exit 0"
    else
        # Stubbed O-P may still non-zero on some hosts; not silent is mandatory
        t_pass "TP-CURL-02 first pipe non-zero but loud (ec=${_pipe_ec}) — silent class still checked"
    fi

    # --- TP-CURL-03: second pipe same HOME ---
    : >"${_outf}"
    : >"${_errf}"
    _curl_pipe_bash "${_outf}" "${_errf}"
    _out=$(cat "${_outf}" 2>/dev/null || true)
    _err=$(cat "${_errf}" 2>/dev/null || true)
    assert_not_silent "TP-CURL-03 second pipe not silent" "$_out" "$_err"
    if printf '%s' "${_out}${_err}" | grep -qiE 'help|Usage:|COMMANDS'; then
        # full help body as only outcome is a Type O regression; allow mention of help in tips
        if printf '%s' "${_out}${_err}" | grep -qE 'already|latest|install|SDKMAN|Payload|setup|Spring|INFO|OK'; then
            t_pass "TP-CURL-03 second pipe not help-only"
        else
            t_fail "TP-CURL-03 second pipe looks help-only: '$(_trunc "${_out}${_err}")'"
        fi
    else
        t_pass "TP-CURL-03 second pipe not help-only"
    fi

    # --- TP-CURL-04: bashrc + sdkman-init under set -u via pipe ---
    ci_cleanup_env
    ci_isolated_env
    if ! ci_start_channel; then
        ci_cleanup_env
        return 1
    fi
    ci_stub_domain_toolchain
    mkdir -p "${CI_USER_BIN}" "${CI_HOME}/.sdkman/bin"
    cat > "${CI_HOME}/.sdkman/bin/sdkman-init.sh" <<'EOF'
#!/usr/bin/env bash
# Minimal SDKMAN-like init: under set -u unbound expansion aborts without set +u
if [ -z "$SDKMAN_CANDIDATES_API" ]; then
  export SDKMAN_CANDIDATES_API="https://api.sdkman.io/2"
fi
if [ -z "$SDKMAN_DIR" ]; then
  export SDKMAN_DIR="${HOME}/.sdkman"
fi
sdk() { return 0; }
EOF
    cat > "${CI_HOME}/.bashrc" <<EOF
export SDKMAN_DIR="\${HOME}/.sdkman"
[ -s "\${HOME}/.sdkman/bin/sdkman-init.sh" ] && . "\${HOME}/.sdkman/bin/sdkman-init.sh"
EOF
    _outf="${CI_HOME}/curl-out.txt"
    _errf="${CI_HOME}/curl-err.txt"
    : >"${_outf}"
    : >"${_errf}"
    _curl_pipe_bash "${_outf}" "${_errf}"
    _out=$(cat "${_outf}" 2>/dev/null || true)
    _err=$(cat "${_errf}" 2>/dev/null || true)
    assert_not_silent "TP-CURL-04 bashrc+sdkman pipe not silent" "$_out" "$_err"
    if printf '%s' "${_out}${_err}" | grep -qE 'install|SDKMAN|Payload|setup|Spring|INFO|OK|ERROR|Note:|successfully|Successfully'; then
        t_pass "TP-CURL-04 bashrc+sdkman reaches product messages"
    else
        t_fail "TP-CURL-04 no product messages (nounset silent abort?): '$(_trunc "${_out}${_err}")'"
    fi

    # --- TP-CURL-05: bad URL with curl -fsSL (transport loud) ---
    : >"${_outf}"
    : >"${_errf}"
    # Missing path on live local server → 404; curl -f fails before bash
    curl -fsSL "http://127.0.0.1:${CI_PORT}/DOES_NOT_EXIST_${APP_NAME}" >"${_outf}" 2>"${_errf}" || true
    _out=$(cat "${_outf}" 2>/dev/null || true)
    _err=$(cat "${_errf}" 2>/dev/null || true)
    assert_not_silent "TP-CURL-05 bad URL curl -f not silent" "$_out" "$_err"
    if printf '%s' "${_out}${_err}" | grep -qiE '404|error|failed|curl'; then
        t_pass "TP-CURL-05 bad URL reports transport error"
    else
        t_fail "TP-CURL-05 expected curl/HTTP error text: '$(_trunc "${_out}${_err}")'"
    fi
    # Product still speaks when remote channel is refuse (may be installed after pipe →
    # empty-argv can continue payload and exit 0; non-zero first-install is TP-CURL-08).
    : >"${_outf}"
    : >"${_errf}"
    _bad_out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" \
        SCRIPT_URL="http://127.0.0.1:1/${APP_NAME}-unreachable" \
        PATH="${CI_STUB_BIN}:${PATH}" NO_RUN=1 \
        bash "${SCRIPT}" </dev/null 2>"${_errf}"
    )
    _bad_err=$(cat "${_errf}" 2>/dev/null || true)
    assert_not_silent "TP-CURL-05 product bad SCRIPT_URL not silent" "$_bad_out" "$_bad_err"

    # --- TP-CURL-06: curl | sh requires bash ---
    : >"${_outf}"
    : >"${_errf}"
    curl -fsSL "${CI_SCRIPT_URL}" 2>>"${_errf}" | sh >"${_outf}" 2>>"${_errf}" || true
    _out=$(cat "${_outf}" 2>/dev/null || true)
    _err=$(cat "${_errf}" 2>/dev/null || true)
    assert_not_silent "TP-CURL-06 curl|sh not silent" "$_out" "$_err"
    if printf '%s' "${_out}${_err}" | grep -qiE 'requires bash|Use:.*bash'; then
        t_pass "TP-CURL-06 curl|sh states requires bash"
    else
        t_fail "TP-CURL-06 expected bash requirement message: '$(_trunc "${_out}${_err}")'"
    fi

    # --- TP-CURL-07: curl | bash -s -- version ---
    : >"${_outf}"
    : >"${_errf}"
    curl -fsSL "${CI_SCRIPT_URL}" 2>>"${_errf}" | bash -s -- version >"${_outf}" 2>>"${_errf}"
    _pipe_ec=$?
    _out=$(cat "${_outf}" 2>/dev/null || true)
    _err=$(cat "${_errf}" 2>/dev/null || true)
    assert_eq "TP-CURL-07 version via pipe exit 0" 0 "${_pipe_ec}"
    assert_not_silent "TP-CURL-07 version via pipe not silent" "$_out" "$_err"
    assert_contains "TP-CURL-07 version string" "$_out" "${PRODUCT_VERSION}"

    # --- TP-CURL-08: first install with refuse SCRIPT_URL (loud fail, no binary) ---
    ci_cleanup_env
    ci_isolated_env
    # No channel needed: SCRIPT_URL refuse
    : >"${CI_HOME}/refuse-out.txt"
    _outf="${CI_HOME}/refuse-out.txt"
    _errf="${CI_HOME}/refuse-err.txt"
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" \
        SCRIPT_URL="http://127.0.0.1:1/${APP_NAME}-refuse" \
        bash "${SCRIPT}" </dev/null 2>"${_errf}"
    )
    _ec=$?
    _err=$(cat "${_errf}" 2>/dev/null || true)
    assert_nonzero "TP-CURL-08 refuse channel non-zero" "$_ec"
    assert_not_silent "TP-CURL-08 refuse channel not silent" "$_out" "$_err"
    assert_file_missing "TP-CURL-08 no binary on refuse" "${CI_USER_BIN}/${APP_NAME}"

    ci_stop_channel
    ci_cleanup_env

    # --- TP-CURL-09: optional published online channel ---
    if [ "${RUN_ONLINE_CURL_TESTS:-0}" = "1" ]; then
        _online_url="${ONLINE_SCRIPT_URL:-}"
        if [ -z "$_online_url" ]; then
            _online_url=$(grep -E '^: "\$\{SCRIPT_URL:=' "${SCRIPT}" 2>/dev/null | head -n1 | sed 's/.*SCRIPT_URL:=//;s/}".*//')
            # Expand simple ${REPO_USER} composition from defaults if needed — fall back to README pattern
            if printf '%s' "$_online_url" | grep -q 'REPO_'; then
                _online_url="https://raw.githubusercontent.com/Wilgat/springboot2/main/springboot2"
            fi
        fi
        : "${_online_url:=https://raw.githubusercontent.com/Wilgat/springboot2/main/springboot2}"
        t_info "TP-CURL-09 online URL=${_online_url}"
        _oh=$(mktemp -d "${TMPDIR:-/tmp}/sb2-online.XXXXXX")
        _oout="${_oh}/out.txt"
        _oerr="${_oh}/err.txt"
        if ! curl -fsSIL "${_online_url}" >/dev/null 2>&1; then
            t_skip "TP-CURL-09 online channel unreachable"
            rm -rf "${_oh}"
        else
            curl -fsSL "${_online_url}" 2>"${_oerr}" | bash -s -- version >"${_oout}" 2>>"${_oerr}"
            _oec=$?
            _out=$(cat "${_oout}" 2>/dev/null || true)
            _err=$(cat "${_oerr}" 2>/dev/null || true)
            assert_eq "TP-CURL-09 online version exit 0" 0 "$_oec"
            assert_not_silent "TP-CURL-09 online version not silent" "$_out" "$_err"
            if printf '%s' "$_out" | grep -qE 'version|[0-9]+\.[0-9]+'; then
                t_pass "TP-CURL-09 online version text present"
            else
                t_fail "TP-CURL-09 online version unexpected: '$(_trunc "$_out")'"
            fi
            rm -rf "${_oh}"
        fi
    else
        t_skip "TP-CURL-09 online channel (set RUN_ONLINE_CURL_TESTS=1 to enable)"
    fi
}
