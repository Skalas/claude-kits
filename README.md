# claude-profiles

Manage switchable [Claude Code](https://docs.anthropic.com/en/docs/claude-code) configuration profiles — conventions, agents, commands, settings, and system prompts — from a single repository.

## Why?

Claude Code reads its configuration from `~/.claude/` (settings, agents, commands, `CLAUDE.md`). When you work across different projects — backend APIs, cloud infrastructure, frontend apps — you want different conventions and tools active. Manually swapping files is tedious and error-prone.

**claude-profiles** gives you:
- **Shared standards** — Clean Architecture, DRY, KISS, Clean Code applied to every profile via `base/CLAUDE.md`
- **Domain expertise** — each profile's `CLAUDE.md` carries deep conventions for its tech stack
- **Task-oriented agents** — code reviewer, test generator, dependency auditor available in every profile
- **Slash commands** — `/review`, `/explain`, `/audit-deps`, `/standup` ready to use
- **One-command switching** — install/uninstall with a single script
- **Clean uninstall** — a manifest tracks every file so nothing is left behind

## Quick Start

```bash
# Clone the repo
git clone https://github.com/skalas/claude-kits.git
cd claude-kits

# See available profiles
./install.sh

# Install a profile
./install.sh ai-connectors

# Switch to a different profile (auto-uninstalls the previous one)
./install.sh gcp-cloudops

# Remove the active profile
./uninstall.sh
```

### Requirements

- **jq** — used for JSON merging (`brew install jq`)
- **bash** 4+

## Available Profiles

| Profile | Domain |
|---------|--------|
| `ai-connectors` | FastAPI, Python async, AI API patterns, Docker, GCP |
| `nestjs-backend` | NestJS modules, Prisma, PostgreSQL, Jest |
| `gcp-cloudops` | GCP services, Terraform, CI/CD, networking, IAM, monitoring |
| `performance-engineering` | Python/Node.js profiling, USE/RED methods, concurrency, HA |
| `vue-frontend` | Vue 3 Composition API, TypeScript, Pinia, Vue Router, SOLID |

## Architecture

```
base/                        # Shared by ALL profiles
  ├── CLAUDE.md              # Team standards: Clean Architecture, DRY, KISS, Clean Code
  ├── settings.json          # Common settings
  ├── agents/                # Task-oriented agents (code-reviewer, test-generator, dependency-auditor)
  └── commands/              # Slash commands (/review, /explain, /audit-deps, /standup)

profiles/<name>/             # One active at a time
  ├── CLAUDE.md              # Domain-specific conventions (full tech stack guidance)
  ├── settings.json          # Profile-specific settings
  ├── agents/                # Optional profile-specific agents
  └── commands/              # Optional profile-specific commands
```

### What goes where

- **`base/CLAUDE.md`** — Framework-agnostic engineering principles. Always active. Every profile inherits these.
- **`profiles/<name>/CLAUDE.md`** — Deep domain expertise: framework conventions, project structure, testing strategy, tool-specific best practices.
- **`base/agents/`** — Task-oriented agents for discrete jobs (reviewing code, generating tests, auditing deps). These run as isolated subprocesses — isolation is a benefit for focused tasks.
- **`base/commands/`** — Slash commands that orchestrate agents or git operations.

### How installation works

When you run `./install.sh <profile>`:

1. **Settings** — `base/settings.json` is merged with `profiles/<name>/settings.json`, then deep-merged into your existing `~/.claude/settings.json`. A backup is saved.
2. **Agents & Commands** — Files from both `base/` and the profile are copied into `~/.claude/agents/` and `~/.claude/commands/`.
3. **CLAUDE.md** — Both base and profile `CLAUDE.md` contents are appended to `~/.claude/CLAUDE.md` between markers for clean removal.
4. **Manifest** — A manifest at `~/.claude/.installed-profile` tracks everything that was installed.

Installing a new profile automatically uninstalls the previous one first.

## Shared Agents

These agents are available in every profile:

| Agent | Purpose |
|-------|---------|
| `code-reviewer` | Reviews diffs for quality issues. Returns structured findings (blocker/warning/suggestion) |
| `test-generator` | Generates tests for source files following Arrange-Act-Assert |
| `dependency-auditor` | Audits dependency manifests for unused, heavy, or vulnerable packages |

## Slash Commands

These commands are available in every profile:

| Command | Description |
|---------|-------------|
| `/review` | Review staged or recent changes for quality issues |
| `/explain <path>` | Explain the architecture and purpose of a file or module |
| `/audit-deps` | Audit project dependencies |
| `/standup` | Generate a standup summary from recent git activity |

## Creating a New Profile

```bash
./new-profile.sh my-profile
```

This scaffolds:

```
profiles/my-profile/
  ├── agents/           # Optional profile-specific agents
  ├── commands/         # Optional profile-specific commands
  ├── settings.json     # Agent groups, hooks, MCP config
  └── CLAUDE.md         # Domain conventions (template with section headers)
```

The generated `CLAUDE.md` includes the standard opening paragraph referencing base standards and section headers (Technical Stack, Conventions, Project Structure, Testing) to fill in.

## Uninstalling

```bash
./uninstall.sh
```

This restores `settings.json` from the backup, removes installed agents and commands, strips the profile sections from `CLAUDE.md`, and deletes the manifest.

## License

MIT
