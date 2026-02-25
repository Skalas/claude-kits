# Claude Profiles

This repository manages reusable Claude Code configuration profiles. Each profile bundles agents, commands, settings, and system prompt instructions that get installed into `~/.claude/`.

## Repository Structure

```
base/                  # Shared foundation applied to ALL profiles
  CLAUDE.md            # System prompt appended for every profile
  settings.json        # Settings merged into every profile
  agents/              # Agent definitions available in every profile
  commands/            # Command definitions available in every profile

profiles/<name>/       # Role-specific profiles (one active at a time)
  CLAUDE.md            # Profile-specific system prompt
  settings.json        # Profile-specific settings
  agents/              # Profile-specific agent definitions
  commands/            # Profile-specific command definitions
```

## How Installation Works

`install.sh <profile>` layers base + profile into `~/.claude/`:
1. Deep-merges `base/settings.json` + `profiles/<name>/settings.json` into `~/.claude/settings.json`
2. Copies agents from both `base/agents/` and `profiles/<name>/agents/`
3. Appends both `base/CLAUDE.md` and `profiles/<name>/CLAUDE.md` to `~/.claude/CLAUDE.md`
4. Writes a manifest to `~/.claude/.installed-profile` for clean uninstall

Only one profile can be active at a time. Installing a new profile auto-uninstalls the previous one.

## Available Profiles

- **ai-connectors** — AI service integrations (FastAPI, Docker, GCP, OpenAI/Anthropic/Google AI)
- **nestjs-backend** — NestJS backend development with clean architecture
- **gcp-cloudops** — GCP infrastructure, Terraform, CI/CD, monitoring
- **performance-engineering** — Performance profiling and optimization for Python/Node.js on GCP
- **vue-frontend** — Vue.js frontend development

## Commands

```bash
./install.sh <profile>      # Install a profile
./uninstall.sh              # Remove the active profile
./new-profile.sh <name>     # Scaffold a new profile
```
