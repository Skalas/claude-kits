# Claude Profiles

This repository manages reusable Claude Code configuration profiles. Each profile provides a self-contained domain agent with full engineering standards and expertise, plus shared task agents, commands, and settings — all installed into `~/.claude/`.

## Repository Structure

```
base/                  # Shared foundation applied to ALL profiles
  CLAUDE.md            # Interaction preferences (working approach, communication style)
  standards.md         # Engineering standards source (Clean Architecture, DRY, KISS, Clean Code)
  settings.json        # Settings merged into every profile
  agents/              # Task-oriented agents (code-reviewer, test-generator, dependency-auditor)
  commands/            # Slash commands (/review, /explain, /audit-deps, /standup)

profiles/<name>/       # Domain-specific profiles
  CLAUDE.md            # Domain expertise source (used to compose agents, not installed directly)
  settings.json        # Profile-specific settings
  agents/              # Domain agent (self-contained with standards + expertise)
  commands/            # Optional profile-specific commands
```

## How Installation Works

`install.sh --all` layers base + all profiles into `~/.claude/`:
1. Deep-merges `base/settings.json` + all `profiles/*/settings.json` into `~/.claude/settings.json`
2. Copies agents from `base/agents/` and all `profiles/*/agents/` — all domain agents available simultaneously
3. Copies commands from `base/commands/` and all `profiles/*/commands/`
4. Appends `base/CLAUDE.md` (interaction preferences only) to `~/.claude/CLAUDE.md`
5. Writes a manifest to `~/.claude/.installed-profile` for clean uninstall

You can also install a single profile with `install.sh <profile>` if preferred.

## Design Principles

- **Agents are self-contained** — each domain agent includes full engineering standards + domain expertise, since agents run as isolated subprocesses without access to `CLAUDE.md`
- **`CLAUDE.md` is slim** — only sets interaction preferences (working approach, communication style) for the main session
- **`base/standards.md` is the source** — engineering standards live here as a repo-internal reference, embedded into each agent file
- **All domains available at once** — `--all` installs every domain agent; no switching needed

## Available Profiles

| Profile | Domain Agent | Description |
|---------|-------------|-------------|
| `ai-connectors` | `ai-connector-engineer` | FastAPI, Python async, AI API patterns, Docker, GCP |
| `nestjs-backend` | `nestjs-engineer` | NestJS modules, Prisma, PostgreSQL, Jest |
| `gcp-cloudops` | `gcp-cloudops-engineer` | GCP services, Terraform, CI/CD, networking, IAM, monitoring |
| `performance-engineering` | `performance-engineer` | Python/Node.js profiling, USE/RED methods, concurrency, HA |
| `vue-frontend` | `vue-engineer` | Vue 3 Composition API, TypeScript, Pinia, Vue Router, SOLID |

## Commands

```bash
./install.sh --all          # Install base + ALL profiles (recommended)
./install.sh <profile>      # Install base + a single profile
./uninstall.sh              # Remove the active installation
./new-profile.sh <name>     # Scaffold a new profile with template agent
```
