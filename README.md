# springboot2

<img src="https://img.shields.io/badge/Version-1.0.8-blue?style=flat-square" alt="Version">  
<img src="https://img.shields.io/badge/Java-8-orange?style=flat-square&logo=java" alt="Java 8">  
<img src="https://img.shields.io/badge/Spring%20Boot-2.7.18-brightgreen?style=flat-square&logo=spring" alt="Spring Boot 2.7">  
<img src="https://img.shields.io/badge/License-MIT-green?style=flat-square" alt="License MIT">

**One stupidly simple command to get a working Spring Boot 2.7 environment in 2026+**

```bash
springboot2
```

→ installs everything needed → creates a minimal Hello World project → builds it → runs it on port 8080

Perfect when you need to:

- quickly reproduce / test legacy Spring Boot 2.7 behavior
- demonstrate Java 8 + Maven + Spring Boot 2.x setup
- onboard someone to an old codebase without fighting tool versions
- show "it still works in 2026" proof-of-life

## What it actually does (in order)

1. Installs **SDKMAN!** (if not already present)
2. Installs **Java 8** (Amazon Corretto — most reliable free distribution)
3. Installs **Maven 3.9.13** (latest 3.9.x line still fully Java 8 compatible)
4. Creates a fresh minimal project in `~/springboot-springboot2`
   - Spring Boot **2.7.18** (final release of the 2.7 line)
   - Single `@RestController` returning "Hello from Spring Boot..."
   - Configured to bind to `0.0.0.0:8080`
5. Runs `mvn clean package`
6. Starts the application (`java -jar ...`)

After ~1–3 minutes (depending on internet & machine) you should see:

```
Tomcat started on port(s): 8080 (http) ...
```

Open http://localhost:8080 (or your machine's IP from another device)

## Installation

The fastest way (uses `bash` explicitly because SDKMAN init needs it):

```bash
curl -fsSL https://raw.githubusercontent.com/Wilgat/springboot2/main/springboot2 | bash
```

**If you get permission denied** (most Linux/macOS systems when writing to `/usr/local/bin`):

```bash
sudo curl -fsSL https://raw.githubusercontent.com/Wilgat/springboot2/main/springboot2 | sudo bash
```

### Smart install behavior

- **Root / sudo** → installs to `/usr/local/bin/springboot2`
- **Normal user** → installs to `~/.local/bin/springboot2`
  - creates the directory if missing
  - adds `export PATH="$HOME/.local/bin:$PATH"` to `~/.bashrc` if not already present
  - shows clear instruction to run `. ~/.bashrc` or `source ~/.bashrc`

Interactive terminals ask for confirmation.  
Piped/non-interactive runs (CI, scripts) install automatically.

## Usage

```bash
springboot2
# → setup everything → create project → build → run on :8080

springboot2 version
# → springboot2 version 1.0.8

springboot2 help
# shows this help
```

## Project location & cleanup

- Created in: `~/springboot-springboot2`
- If you run `springboot2` again → **old folder is deleted** and recreated
- Want to keep your experiments? → rename or move the folder before re-running

## Requirements

- curl
- bash (strongly preferred — SDKMAN init relies on it)
- internet connection (first run)
- ~400–800 MB disk space (mainly for SDKMAN + Java + Maven caches)

No Docker, no manual SDKMAN install, no fighting with `JAVA_HOME`.

## Why this exists

Spring Boot 2.7 reached end-of-life in Nov 2023, but many legacy systems, training materials, certification exams, and client projects still run on it in 2026~.

This tiny script removes 90% of the "but on my machine it works with Java 17…" friction when you need a **genuine Java 8 + SB 2.7** environment quickly.

## Design & Development Approach

This script follows a strict, clean, beginner-friendly shell scripting style with these goals in mind:

- Maximum portability (Linux, macOS, minimal containers, etc.)
- Very readable & maintainable code
- Clear progress messages at every step
- Safe self-install (one-liner friendly)
- Graceful handling of SDKMAN's "must source init.sh" behavior

### Requirement Analysis Summary

- **Shell**: `#!/bin/bash` (required because of SDKMAN usage & sourcing needs)
- **Privileges**: auto-detect root vs normal user → `/usr/local/bin` vs `~/.local/bin`
- **Install style**: one-liner `curl | bash` friendly (GitHub raw), user & sudo variants
- **Constants**: all important values (versions, paths, URLs) at the top
- **Safety**: temp files → atomic `mv` for writes, duplicate checks for PATH
- **PATH help**: auto-add `~/.local/bin` to `~/.bashrc` (idempotent) + friendly message
- **SDKMAN special case**: explicit sourcing in current session + fallback warning if not available yet

### High-Level Flow / Pseudo-code Overview

| Step | Action / Module                     | Main purpose / Logic                                                                 |
|------|-------------------------------------|--------------------------------------------------------------------------------------|
| 1    | Header & constants                  | Define colors, versions, URLs, paths, project name, etc.                             |
| 2    | Detect install location             | Root → `/usr/local/bin`, normal user → `~/.local/bin`                                |
| 3    | Check if already installed          | Smart check: look in both global & user dir for normal users                         |
| 4    | Self-install (if missing)           | Download to temp → chmod → mv → add to PATH if needed → success message              |
| 5    | Parse arguments                     | `help`, `version`, or default = run full setup                                       |
| 6    | Setup SDKMAN                        | Install if missing → source init.sh → check `sdk` exists or warn & exit              |
| 7    | Setup Java 8 Corretto               | `sdk install java 8-amzn` → set default → verify                                     |
| 8    | Setup Maven                         | `sdk install maven 3.9.13` → set default → verify                                    |
| 9    | Create Spring Boot project          | Delete old dir → create structure → write pom.xml / Java / properties (atomic)       |
| 10   | Build & run                         | `mvn clean package` → `java -jar target/*.jar`                                       |

## Contributing

Ideas welcome:

- `--project-dir=/custom/path`
- `--spring-boot-version=2.7.10` (or other 2.7.x patch)
- `--java-vendor=adoptium` / `--java-version=8.0.XXX-tem`
- `--no-run` / `--only-setup`
- Support for Gradle instead of Maven
- `--keep-project` flag

## License

[MIT License](LICENSE)

Made with mild frustration and one cup of espresso  
2026-
