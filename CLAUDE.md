# Claude Profiles

This repository manages reusable Claude Code configuration profiles. Each profile bundles conventions, agents, commands, settings, and system prompt instructions that get installed into `~/.claude/`.

## Repository Structure

```
base/                  # Shared foundation applied to ALL profiles
  CLAUDE.md            # Team engineering standards (Clean Architecture, DRY, KISS, Clean Code)
  settings.json        # Settings merged into every profile
  agents/              # Task-oriented agents (code-reviewer, test-generator, dependency-auditor)
  commands/            # Slash commands (/review, /explain, /audit-deps, /standup)

profiles/<name>/       # Domain-specific profiles (one active at a time)
  CLAUDE.md            # Full domain expertise and conventions for the tech stack
  settings.json        # Profile-specific settings
  agents/              # Optional profile-specific agents
  commands/            # Optional profile-specific commands
```

## How Installation Works

`install.sh <profile>` layers base + profile into `~/.claude/`:
1. Deep-merges `base/settings.json` + `profiles/<name>/settings.json` into `~/.claude/settings.json`
2. Copies agents from both `base/agents/` and `profiles/<name>/agents/`
3. Copies commands from both `base/commands/` and `profiles/<name>/commands/`
4. Appends both `base/CLAUDE.md` and `profiles/<name>/CLAUDE.md` to `~/.claude/CLAUDE.md`
5. Writes a manifest to `~/.claude/.installed-profile` for clean uninstall

Only one profile can be active at a time. Installing a new profile auto-uninstalls the previous one.

## Design Principles

- **Conventions in CLAUDE.md** — coding standards live in `CLAUDE.md` files (always active in the main agent), not in agent definitions (isolated subprocesses)
- **Shared principles in base** — Clean Architecture, DRY, KISS, Clean Code are defined once in `base/CLAUDE.md`, not duplicated per profile
- **Agents for tasks, not personas** — agents are scoped to discrete, parallelizable jobs (reviewing, testing, auditing) where subprocess isolation is a benefit

## Available Profiles

- **ai-connectors** — FastAPI, Python async, AI API patterns, Docker, GCP
- **nestjs-backend** — NestJS modules, Prisma, PostgreSQL, Jest
- **gcp-cloudops** — GCP services, Terraform, CI/CD, networking, IAM, monitoring
- **performance-engineering** — Python/Node.js profiling, USE/RED methods, concurrency, HA
- **vue-frontend** — Vue 3 Composition API, TypeScript, Pinia, Vue Router, SOLID

## Commands

```bash
./install.sh <profile>      # Install a profile
./uninstall.sh              # Remove the active profile
./new-profile.sh <name>     # Scaffold a new profile
```
