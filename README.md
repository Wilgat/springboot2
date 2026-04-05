# springboot2

<img src="https://img.shields.io/badge/Version-2.0.0-blue?style=flat-square" alt="Version">  
<img src="https://img.shields.io/badge/Java-8-orange?style=flat-square&logo=openjdk" alt="Java 8">  
<img src="https://img.shields.io/badge/Spring%20Boot-2.7.18-brightgreen?style=flat-square&logo=springboot" alt="Spring Boot 2.7.18">  
<img src="https://img.shields.io/badge/Maven-3.9.14-red?style=flat-square&logo=apachemaven" alt="Maven 3.9.14">  
<img src="https://img.shields.io/badge/License-MIT-green?style=flat-square" alt="MIT License">

**The friendliest way to run and maintain Spring Boot 2.7.18 projects.**

> A robust, extremely defensive Bash script that installs SDKMAN!, Java 8 (Amazon Corretto), Maven, and reliably sets up/runs Spring Boot 2.7.18 applications — with strong project preservation by default.  
> Part of the Wilgat defensive tool family (aligned with [pomo](https://github.com/Wilgat/pomo) and [ciao](https://github.com/Wilgat/ciao)).

---

## ✨ Features

- One-liner install (`curl | bash`)
- Supports both **user** (`~/.local/bin`) and **system** (`/usr/local/bin`) installation
- Automatically installs SDKMAN! + pinned Java 8 (Amazon Corretto) + Maven 3.9.14
- Creates or re-uses a minimal Spring Boot 2.7.18 project
- **Project preservation by default** — repeated runs keep your changes (`--reset` to start fresh)
- Full support for existing legacy projects via `--project-dir`
- New commands: `status`, `about` (with rich diagnostics)
- `--no-run` flag for CI / Docker environments
- `--json` + `--quiet` support for scripting and diagnostics
- Self-installing, self-updating, and version checking
- Multi-shell PATH setup (bash, zsh, fish)
- Extremely defensive coding style with repeated safe defaults

---

## 🚀 Quick Installation

**For normal users:**
```bash
curl -fsSL https://raw.githubusercontent.com/Wilgat/springboot2/main/springboot2 | bash
```

**System-wide (requires root):**
```bash
curl -fsSL https://raw.githubusercontent.com/Wilgat/springboot2/main/springboot2 | sudo bash
```

After installation, simply run:
```bash
springboot2
```

The application will be available at **http://localhost:8080**

---

## 📖 Usage

```bash
springboot2                          # Setup + build + run (preserves project by default)
springboot2 --reset                  # Full reset: delete and regenerate project
springboot2 --project-dir <path>     # Work with an existing legacy project
springboot2 --no-run                 # Setup only (no build/run) — useful for CI/Docker
springboot2 status                   # Show if the app is running
springboot2 about                    # Full diagnostics (Java, Maven, project, etc.)
springboot2 about --json             # Machine-readable diagnostics
springboot2 version
springboot2 version-check
springboot2 self-update
springboot2 help
```

### Key Behaviors

- **Normal run**: Preserves your existing project folder, `pom.xml`, source code, and `application.properties`.
- **`--reset`**: Completely wipes and regenerates the project (replaces old `--force`).
- **`--project-dir`**: Point to any existing Spring Boot 2.7 project.
- **`--no-run`**: Only sets up the environment and project — does not build or start the app.

---

## Important Notes (2026)

Spring Boot 2.7.18 is the **final OSS release** of the 2.7 series (OSS support ended in 2023).  
Commercial support continues until the end of 2026.  
This tool is designed specifically for **legacy project maintenance**.

---

## Platform Notes

### Alpine Linux
Requires **bash** (SDKMAN! does not work reliably under BusyBox ash).  
The script auto-detects Alpine and shows clear instructions.

### Other Platforms
Fully supported on macOS, Git Bash (Windows), Ubuntu, Rocky Linux, etc., with defensive fallbacks.

---

## Platform Compatibility

| Platform                  | Status       | Notes |
|---------------------------|--------------|-------|
| **Alpine Linux**          | Good         | Requires `apk add bash` |
| **Git Bash (Windows)**    | Good         | Defensive handling |
| **Ubuntu / Debian**       | Excellent    | Default bash |
| **Rocky / RHEL / CentOS** | Excellent    | No issues |
| **macOS (bash/zsh)**      | Good         | Full support |

---

## Why the Defensive Style?

This script follows the strict **Wilgat defensive coding style** (same as `pomo`, `countdown`, and `ciao`):
- Repeated safe defaults and redundant checks
- Heavy protective comments (`!!! DO NOT MODIFY OR SIMPLIFY !!!`)
- Flag-first parsing and single source of truth for output

**Purpose**: Survive harsh environments (`curl | bash`, non-interactive shells, missing `$HOME`, Alpine, Git Bash, etc.) and resist accidental simplification.

---

## Contributing

Contributions are welcome, but **please preserve the defensive style** and protective comments.  
Any changes should maintain reliability in edge cases.

---

## License

MIT

---

**Part of the Wilgat defensive tool family.**  
*Last updated: April 2026*

---

**Note**: This tool is intended for maintenance of existing Spring Boot 2.7.18 projects. For new projects, consider newer Spring Boot versions.
