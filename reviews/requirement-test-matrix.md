# Requirement ↔ test matrix — springboot2

**Updated:** 2026-08-10  
**Suite:** `./tests/run.sh` (PASS=174 FAIL=0 SKIP=1 on 2026-08-10 fix-all)

| Requirement key | Area | TP families | Coverage notes |
|-----------------|------|-------------|----------------|
| requirement-class-software-dev | class | TP-CLI-01 · suite residual | Class residual honesty; stack points to peers |
| requirement-domain-springboot2 | domain | TP-DOM-01..09 · TP-LC-01..02 · TP-CURL-02 | Pins, scaffold, preserve/reset, payload isolation |
| requirement-shell-cli-interface | shell | TP-CLI-01..07,09,11 · TP-DOM-01,08 | Commands, flags, unknown, help |
| requirement-shell-cli-zero-arguments | shell | TP-LC-01 · TP-DOM-03 · TP-CURL-02..03 · TP-CLI-09 | Type O-P combined ensure |
| requirement-shell-payload-online-install | shell | TP-LC-01..03 · TP-DOM-04,09 · TP-CLI-03 · TP-CURL-* | Layer split; first pipe |
| requirement-shell-self-management | shell | TP-LC-04..09 · TP-CLI-11 | version-check, self-*, downgrade, bad channel |
| requirement-shell-automatic-checksum | shell | TP-CSUM-02..05 · TP-CLI-01 · TP-CURL-01 | Shape A + B; no help CHECKSUM |
| requirement-shell-output-requirements | shell | TP-CLI-02,04,06,07 · TP-DOM-07 | out_* types; quiet; JSON |
| requirement-shell-cli-storage | shell | TP-CLI-05 | effective_storage / isolation |
| requirement-shell-idempotency | shell | TP-LC-05 · TP-CURL-03 · TP-DOM-05 | re-run / second pipe / preserve |
| requirement-shell-interactive-vs-noninteractive | shell | TP-LC-03,07 · TP-CURL-* · TP-U-04 | confirm gates; pipe loudness |
| requirement-shell-modular-function-design | shell | TP-MOD-01 · TP-MOD-02 · TP-U-* | Prefix hygiene + no template authority |

**Absent by design (no Core TP):** Type 1 sudoers elev tables, Spring Boot 3.x retarget, real public SDKMAN install.
