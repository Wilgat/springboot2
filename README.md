# springboot2

<img src="https://img.shields.io/badge/Version-1.9.0-blue?style=flat-square" alt="Version">  
<img src="https://img.shields.io/badge/Java-8-orange?style=flat-square&logo=openjdk" alt="Java 8">  
<img src="https://img.shields.io/badge/Spring%20Boot-2.7.18-brightgreen?style=flat-square&logo=springboot" alt="Spring Boot 2.7.18">  
<img src="https://img.shields.io/badge/Maven-3.9.14-red?style=flat-square&logo=apachemaven" alt="Maven 3.9.14">  
<img src="https://img.shields.io/badge/License-MIT-green?style=flat-square" alt="MIT License">

**The friendliest way to run Spring Boot 2.7.18 in one command.**

> A robust, extremely defensive **Bash** script that installs SDKMAN!, Java 8 (Amazon Corretto), Maven, and instantly creates (or re-uses) + runs a minimal Spring Boot 2.7.18 application.  
> Part of the Wilgat defensive tool family (aligned with [ciao](https://github.com/Wilgat/ciao)).

---

## ✨ Features

- One-liner install (`curl | bash`)
- Supports both **user** (`~/.local/bin`) and **system** (`/usr/local/bin`) installation
- Automatically installs SDKMAN! + pinned Java 8 Amazon Corretto + Maven 3.9.14
- Creates a clean minimal Spring Boot 2.7.18 "Hello World" project
- **New in 1.9.0**: Project preservation by default — re-runs keep your existing files (use `--force` to reset)
- Self-installing, self-updating (`--self-update`), and version checking
- `--force` / `--reinstall`, `--quiet` support
- Multi-shell PATH setup (bash, zsh, fish)
- Extremely defensive coding style with repeated safe defaults

---

## 🚀 Quick Installation

**For normal users:**
```bash
curl -fsSL https://raw.githubusercontent.com/Wilgat/springboot2/main/springboot2 | bash
```

**System-wide (root):**
```bash
curl -fsSL https://raw.githubusercontent.com/Wilgat/springboot2/main/springboot2 | sudo bash
```

After installation, simply run:
```bash
springboot2
```

The app will be available at **http://localhost:8080**

---

## 📖 Usage

```bash
springboot2                    # Setup + build + run (preserves project by default)
springboot2 --force            # Full reset: delete and regenerate project files
springboot2 version            # Show current version
springboot2 version-check      # Compare with latest on GitHub
springboot2 self-update        # Update to latest version
springboot2 help               # Show detailed help
```

### New Behavior in v1.9.0
- **Normal run**: Preserves your existing project folder, `pom.xml`, Java source, and `application.properties` (great for repeated testing or manual edits).
- **`--force` / `--reinstall`**: Completely wipes and regenerates the project for a clean slate.

---

## Important Platform Notes

### Alpine Linux
Requires **bash** (SDKMAN! does not work reliably under BusyBox ash).  
The script auto-detects Alpine and gives clear instructions:
```bash
apk add bash
bash <(curl -fsSL https://raw.githubusercontent.com/Wilgat/springboot2/main/springboot2)
```

### macOS, Git Bash (Windows), and other Linux distributions
Fully supported with defensive fallbacks for SDKMAN! sourcing and PATH setup.

---

## Platform Compatibility

| Platform                  | Status       | Notes |
|---------------------------|--------------|-------|
| **Alpine Linux**          | Good         | Requires `apk add bash` |
| **Git Bash (Windows)**    | Good         | Defensive `chmod` handling |
| **Ubuntu / Debian**       | Excellent    | Default bash |
| **Rocky / RHEL / CentOS** | Excellent    | No issues |
| **macOS (bash/zsh)**      | Good         | Supports official SDKMAN!, Homebrew, etc. |

---

## Program Structure (for curious people)

The script is intentionally kept **linear**, highly readable, and **extremely defensive** following the strict "ciao" coding style.

```text
┌─────────────────────────────────────────────────────────────┐
│  Header + Warnings + Project Constants                      │
│  (APP_NAME, VERSION, SCRIPT_URL, JAVA_ID, etc.)             │
├─────────────────────────────────────────────────────────────┤
│  Safe Variable Defaults (repeated on purpose)               │
│  Root Detection (IS_ROOT)                                   │
│  Force Flags & Quiet Mode                                   │
├─────────────────────────────────────────────────────────────┤
│  Color Output + Logging Functions (die, info, warn, etc.)   │
├─────────────────────────────────────────────────────────────┤
│  Core Utility Functions                                     │
│   • is_installed()            ← robust install detection    │
│   • get_installed_version()                                 │
│   • version_check()                                         │
│   • self_update()                                           │
│   • in_path() + add_to_shell_path()                         │
├─────────────────────────────────────────────────────────────┤
│  Installation Logic                                         │
│   • perform_self_install()    ← heart of self-install       │
│   • maybe_install()           ← interactive + auto-install  │
├─────────────────────────────────────────────────────────────┤
│  SDKMAN + Java + Maven Setup                                │
│   • check_alpine_requirements()                             │
│   • setup_sdkman()                                          │
│   • setup_java()                                            │
│   • setup_maven()                                           │
├─────────────────────────────────────────────────────────────┤
│  Project Management (New in 1.9.0)                          │
│   • setup_springboot_project()                              │
│        ├── Preserves project by default                     │
│        └── Full reset with --force / --reinstall            │
├─────────────────────────────────────────────────────────────┤
│  Build & Run                                                │
│   • build_and_run()           ← ultra-defensive build + exec│
├─────────────────────────────────────────────────────────────┤
│  Help & Main Entry Point                                    │
│   • show_spring2_help()                                     │
│   • main()                                                  │
│        ├── Argument parsing                                 │
│        ├── Special handlers (--version, --self-update, etc.)│
│        ├── maybe_install() if needed                        │
│        └── Full setup flow                                  │
└─────────────────────────────────────────────────────────────┘
```

### Why this structure?

- **Linear flow** — easy to read top-to-bottom even for beginners.
- **Heavy defensiveness** — every critical section has repeated safe defaults, redundant checks, and loud protective comments (`!!! DO NOT MODIFY OR SIMPLIFY !!!`).
- **Separation of concerns** — installation logic, SDKMAN setup, project management, and runtime are clearly separated.
- **Project preservation logic** (introduced in 1.9.0) is highlighted because it changes how users interact with the tool on repeated runs.

This design makes the script:
- Survive harsh environments (`curl | bash`, Alpine, Git Bash, non-interactive shells…)
- Resist accidental simplification by AI tools or contributors
- Serve as a reusable template for other defensive tools in the Wilgat family

---

## Why the Heavy Defensive Style?

This project strictly follows the **ciao defensive coding style**:
- Repeated safe defaults (`: "${VAR:=default}"`)
- Redundant root / environment checks
- Heavy inline comments and `!!! DO NOT MODIFY OR SIMPLIFY !!!` blocks

**Purpose**:
- Survive harsh environments (`curl | bash`, non-interactive shells, missing `$HOME`, Alpine ash, Git Bash, etc.)
- Protect against accidental "cleaning" by AI assistants or contributors
- Serve as a reliable template for other Wilgat tools

---

## Project Philosophy

> "Write code that is easy to copy, hard to break, and self-documenting."

---

## Contributing

Please respect the strict defensive coding style and protective comments.  
Any changes should maintain the ultra-defensive approach.

---

## License

MIT

---

**Part of the Wilgat defensive tool family.**  
*Last updated: April 2026*

---

**Note**: Spring Boot 2.7.18 is the final OSS release of the 2.7 series (OSS support ended in 2023). Commercial support is available until the end of 2026. This tool is designed for maintenance of existing legacy projects.
