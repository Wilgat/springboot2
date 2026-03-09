# springboot2

<img src="https://img.shields.io/badge/Version-1.0.2-blue?style=flat-square" alt="Version">  
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
4. Creates a fresh minimal project in `~/spring-boot-hello-sdkman`
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

The fastest way:

```bash
curl -fsSL https://raw.githubusercontent.com/Wilgat/springboot2/main/springboot2 | sh
```

**If you get permission denied** (most Linux/macOS systems when writing to `/usr/local/bin`):

```bash
sudo curl -fsSL https://raw.githubusercontent.com/Wilgat/springboot2/main/springboot2 | sudo sh
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
# → springboot2 version 1.0.2

springboot2 help
# shows this help
```

## Project location & cleanup

- Created in: `~/spring-boot-hello-sdkman`
- If you run `springboot2` again → **old folder is deleted** and recreated
- Want to keep your experiments? → rename or move the folder before re-running

## Requirements

- curl
- bash / sh compatible shell
- internet connection (first run)
- ~400–800 MB disk space (mainly for SDKMAN + Java + Maven caches)

No Docker, no manual SDKMAN install, no fighting with `JAVA_HOME`.

## Why this exists

Spring Boot 2.7 reached end-of-life in Nov 2023, but many legacy systems, training materials, certification exams, and client projects still run on it in 2026~.

This tiny script removes 90% of the "but on my machine it works with Java 17…" friction when you need a **genuine Java 8 + SB 2.7** environment quickly.

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
