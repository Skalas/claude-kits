# claude-profiles

Manage [Claude Code](https://docs.anthropic.com/en/docs/claude-code) configuration profiles — domain agents, task agents, commands, settings, and system prompts — from a single repository.

## Why?

Claude Code reads its configuration from `~/.claude/` (settings, agents, commands, `CLAUDE.md`). When you work across different projects — backend APIs, cloud infrastructure, frontend apps — you want domain-specific expertise available. Manually managing agent files is tedious and error-prone.

**claude-profiles** gives you:
- **Domain agents** — self-contained agents with full engineering standards and deep domain expertise, all available simultaneously
- **Task agents** — code reviewer, test generator, dependency auditor available in every session
- **Slash commands** — `/review`, `/explain`, `/audit-deps`, `/standup` ready to use
- **One-command setup** — install everything with `./install.sh --all`
- **Clean uninstall** — a manifest tracks every file so nothing is left behind

## Quick Start

```bash
# Clone the repo
git clone https://github.com/skalas/claude-profiles.git
cd claude-profiles

# Install all profiles (recommended)
./install.sh --all

# Or install a single profile
./install.sh ai-connectors

# Remove the active installation
./uninstall.sh
```

### Requirements

- **jq** — used for JSON merging (`brew install jq`)
- **bash** 4+

## Available Profiles

| Profile | Agent | Domain |
|---------|-------|--------|
| `ai-connectors` | `ai-connector-engineer` | FastAPI, Python async, AI API patterns, Docker, GCP |
| `nestjs-backend` | `nestjs-engineer` | NestJS modules, Prisma, PostgreSQL, Jest |
| `gcp-cloudops` | `gcp-cloudops-engineer` | GCP services, Terraform, CI/CD, networking, IAM, monitoring |
| `performance-engineering` | `performance-engineer` | Python/Node.js profiling, USE/RED methods, concurrency, HA |
| `vue-frontend` | `vue-engineer` | Vue 3 Composition API, TypeScript, Pinia, Vue Router, SOLID |

## Architecture

```
base/                        # Shared by ALL profiles
  ├── CLAUDE.md              # Interaction preferences (working approach, communication style)
  ├── standards.md           # Engineering standards source (not installed — embedded in agents)
  ├── settings.json          # Common settings
  ├── agents/                # Task agents (code-reviewer, test-generator, dependency-auditor)
  └── commands/              # Slash commands (/review, /explain, /audit-deps, /standup)

profiles/<name>/             # Domain-specific profiles
  ├── CLAUDE.md              # Domain expertise source (used to compose agents)
  ├── settings.json          # Profile-specific settings
  ├── agents/                # Domain agent (self-contained with standards + expertise)
  └── commands/              # Optional profile-specific commands
```

### What goes where

- **`base/CLAUDE.md`** — Interaction preferences for the main Claude session. Slim — just working approach and communication style.
- **`base/standards.md`** — Full engineering standards (Clean Architecture, DRY, KISS, Clean Code). Repo-internal reference embedded into each agent file. Not installed to `~/.claude/`.
- **`profiles/<name>/CLAUDE.md`** — Domain expertise source material. Used to compose the domain agent file. Not appended to `~/.claude/CLAUDE.md`.
- **`profiles/<name>/agents/`** — Self-contained domain agent with engineering standards + domain expertise baked in. Agents run as isolated subprocesses, so they need everything inline.
- **`base/agents/`** — Task-oriented agents for discrete jobs (reviewing code, generating tests, auditing deps).
- **`base/commands/`** — Slash commands that orchestrate agents or git operations.

### How installation works

When you run `./install.sh --all`:

1. **Settings** — all `settings.json` files are deep-merged into `~/.claude/settings.json`. A backup is saved.
2. **Agents** — all `.md` files from `base/agents/` and every `profiles/*/agents/` are copied to `~/.claude/agents/`.
3. **Commands** — all command files are copied to `~/.claude/commands/`.
4. **CLAUDE.md** — only `base/CLAUDE.md` (interaction preferences) is appended to `~/.claude/CLAUDE.md`.
5. **Manifest** — tracks everything installed for clean uninstall.

### Why agents are self-contained

Agents run as isolated subprocesses. They don't inherit `~/.claude/CLAUDE.md` content. So each domain agent embeds the full engineering standards and domain expertise directly. This means:
- Every agent applies the same Clean Architecture, DRY, KISS, Clean Code principles
- Domain expertise is always available to the agent, not dependent on which profile is "active"
- All domain agents can be installed simultaneously with `--all`

## Shared Task Agents

These agents are available in every installation:

| Agent | Purpose |
|-------|---------|
| `code-reviewer` | Reviews diffs for quality issues. Returns structured findings (blocker/warning/suggestion) |
| `test-generator` | Generates tests for source files following Arrange-Act-Assert |
| `dependency-auditor` | Audits dependency manifests for unused, heavy, or vulnerable packages |

## Slash Commands

These commands are available in every installation:

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
  ├── agents/
  │   └── my-profile-engineer.md   # Template agent with standards embedded
  ├── commands/
  ├── settings.json
  └── CLAUDE.md                    # Domain conventions source
```

The generated agent includes the full engineering standards section. Fill in the domain-specific sections (Technical Stack, Conventions) and customize the agent description and role statement.

## Uninstalling

```bash
./uninstall.sh
```

This restores `settings.json` from the backup, removes installed agents and commands, strips the profile sections from `CLAUDE.md`, and deletes the manifest.

## License

MIT
