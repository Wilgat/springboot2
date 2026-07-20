# Security Policy

## Supported Versions

| Version | Supported |
|---------|-----------|
| **2.3.0** (current) | Yes — report security issues against this release |
| 2.2.0 | Superseded; upgrade to current when possible |
| 2.1.0 | Superseded; upgrade to current when possible |
| 2.0.x | Superseded; upgrade to current when possible |
| Older / unreleased | No public support matrix — prefer current when reporting |

## Reporting a Vulnerability

Please **do not** open a public issue for security-sensitive reports when a private channel is available.

**Maintainer contact (email):** `wilgat.wong@gmail.com`

- Source of contact: product **author-email** SSOT in [`LICENSE.md`](./LICENSE.md) (Copyright line).  
- Prefer email for vulnerability details, reproduction steps, and impact.  
- You should receive an acknowledgment when the report is received and actionable.  
- Do not include exploit weaponization guides in public channels.

For non-sensitive questions, product usage, or general bugs that are not security-sensitive, use normal project channels (for example public issues on the project repository when available).

## Security Design Principles (CIAO)

This project follows **[CIAO](https://github.com/cloudgen/ciao)** / **CIAO-Lite** defensive design. Security-relevant intent:

| Letter | Principle | Security application |
|--------|-----------|----------------------|
| **C** | **Caution** | Assume hostile input, hostile networks, and misconfiguration. Validate install paths, checksums, and privilege boundaries; fail closed on integrity mismatch when a digest is present. |
| **I** | **Intentional** | Privilege typing (Type 0 self-management), channel URL (`SCRIPT_URL`), checksum modes, and per-user scratch storage resolve are deliberate and documented—not accidental. Prefer clear “why” over silent magic. |
| **A** | **Anti-fragile** | Survive harsh environments (minimal containers, missing tools, non-interactive `curl \| bash`). Prefer automatic SHA-256 sidecar checks when available, least privilege for day-to-day use, and recoverable failure over brittle trust. |
| **O** | **Over-protect** | Defense in depth on critical paths (integrity verify before install/update, isolated scratch roots, CIAO Protection Zones in the ship unit, loud failure). Do not “simplify away” safety for brevity. |

Full principles: [CIAO Defensive Programming](https://github.com/cloudgen/ciao) · agent contract: [CIAO-Lite](https://github.com/cloudgen/ciao-lite).

This section describes **design posture**. It is **not** a claim of third-party certification (ISO, OWASP “compliant”, etc.).

## Install integrity trust bounds

This product implements **automatic companion-checksum** when the release channel publishes `{{SCRIPT_URL}}.sha256` next to the ship unit:

| Fact | Posture |
|------|---------|
| Primary integrity UX | Automatic fetch of companion `.sha256`; transparent **link / value / result** reporting |
| Strict pin (secondary) | Optional process-env `CHECKSUM` for CI/out-of-band freeze installs — **not** primary help/about surface |
| Same-channel digests | Prove **byte consistency** of script + companion on that channel |
| Not claimed | Independent host authenticity, code signing, or third-party attestation |

See product [`README.md`](./README.md) and law `docs/requirements/requirement-shell-automatic-checksum.md` for install detail.

## Scope notes

- Preferred language for reports: English.  
- Out of scope: social engineering of third parties, physical attacks, spam.  
- Scratch/cache paths resolve per user (`APP_NAME` + username isolation) when storage law applies — see README Environment.  
- Related product docs: [`README.md`](./README.md), [`LICENSE.md`](./LICENSE.md), [`CHANGELOG.md`](./CHANGELOG.md).
