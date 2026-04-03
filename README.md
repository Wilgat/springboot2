# springboot2

<img src="https://img.shields.io/badge/Version-1.6.0-blue?style=flat-square" alt="Version">  
<img src="https://img.shields.io/badge/Java-21-orange?style=flat-square&logo=openjdk" alt="Java 21">  
<img src="https://img.shields.io/badge/Spring%20Boot-3.3.5-brightgreen?style=flat-square&logo=springboot" alt="Spring Boot 3.3">  
<img src="https://img.shields.io/badge/Maven-3.9.9-red?style=flat-square&logo=apachemaven" alt="Maven 3.9">  
<img src="https://img.shields.io/badge/License-MIT-green?style=flat-square" alt="MIT License">

**The friendliest way to run Spring Boot 2.7 in one command.**

> A robust, extremely defensive **Bash** script that installs SDKMAN!, Java 8 Amazon Corretto, Maven, and instantly creates + runs a minimal Spring Boot 2.7.18 application — built as part of the Wilgat defensive tool family.

---

## ✨ Features

- One-liner install (`curl | bash`)
- Supports both **user** (`~/.local/bin`) and **root/system** (`/usr/local/bin`) installation
- Automatically installs SDKMAN! + Java 8 Amazon Corretto + Maven 3.9.9
- Creates and runs a clean Spring Boot 2.7.18 demo project
- Self-installing, self-updating, and self-repairing
- `--version-check`, `--self-update`, `--force`, `--quiet` support
- Multi-shell PATH support (bash, zsh, fish)
- Extremely defensive coding style

### New in v1.2.0
- Shebang changed to `#!/bin/bash` for better SDKMAN compatibility
- Improved SDKMAN handling across different installation methods (official, Homebrew, MacPorts)
- Explicit support and instructions for **Alpine Linux** (requires `bash`)
- Better verbose guidance for non-bash environments

---

## 🚀 Quick Installation

**For normal users:**
```sh
curl -fsSL https://raw.githubusercontent.com/Wilgat/springboot2/main/springboot2 | bash
```

**System-wide (root):**
```sh
curl -fsSL https://raw.githubusercontent.com/Wilgat/springboot2/main/springboot2 | sudo bash
```

---

## 📖 Usage

```sh
springboot2                    # Full setup + build + run (default)
springboot2 version            # Show current version
springboot2 version-check      # Compare with latest on GitHub
springboot2 self-update        # Update to latest version
springboot2 help               # Show help
```

After running, open: **http://localhost:8080**

---

## Important Platform Notes

### Alpine Linux (BusyBox ash)
- This script requires **bash** to be installed because SDKMAN! does not work reliably under ash.
- The script will detect Alpine and show clear instructions to install bash first:
  ```sh
  apk add bash
  ```
- After installing bash, re-run the script using `bash`.

### macOS
- The script detects and supports SDKMAN! installed via:
  - Official installer (`curl -s "https://get.sdkman.io" | bash`)
  - Homebrew (`brew install sdkman`)
  - MacPorts
- It provides verbose guidance on how to properly source SDKMAN! in both bash and zsh.

### Git Bash (Windows)
- Fully supported with defensive handling.

### Other Linux (Rocky/RHEL/CentOS, Ubuntu, Debian, etc.)
- Excellent support when bash is available (default on most distributions).

---

## Program Structure

The script follows the strict linear and defensive structure of the `ciao` template (heavily commented, redundant safe defaults, protected functions, etc.).

---

## Platform Compatibility

| Platform                  | Shell     | Status       | Notes |
|---------------------------|-----------|--------------|-------|
| **Alpine Linux**          | ash → bash| Good         | Requires `apk add bash` |
| **Git Bash (Windows)**    | Bash      | Good         | Supported |
| **Rocky / RHEL / CentOS** | Bash      | Excellent    | No issues |
| **macOS**                 | Bash / zsh| Good         | SDKMAN via official / Homebrew / MacPorts supported with guidance |
| **Standard Linux**        | Bash      | Excellent    | Primary target |

---

## Why This Coding Style & Heavy Comments?

This project strictly follows the **ciao defensive coding style**. Extensive comments, repeated safe defaults, redundant checks, and strong warnings (`!!! DO NOT MODIFY OR SIMPLIFY !!!`) are intentional.

### Purpose of This Style
- Survive `curl | bash` in harsh environments
- Protect against AI over-simplification
- Make the script reusable as a template for other Wilgat tools
- Provide maximum clarity and robustness

---

## Project Philosophy

> "Write code that is easy to copy, hard to break, and self-documenting."

---

## Contributing

Please respect the defensive coding style and protective comments when submitting changes.

---

## License

MIT

---

**Part of the Wilgat defensive tool family.**

*Last updated: April 2026*
