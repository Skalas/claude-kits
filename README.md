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
- **`base/standards.md`** — Single source of truth for engineering standards. Injected into agents via `{{STANDARDS}}` placeholder at install time. Not installed to `~/.claude/` directly.
- **`profiles/<name>/CLAUDE.md`** — Domain expertise source material. Used to compose the domain agent file. Not appended to `~/.claude/CLAUDE.md`.
- **`profiles/<name>/agents/`** — Domain agent with `{{STANDARDS}}` placeholder + domain expertise. Agents run as isolated subprocesses, so standards are injected at install time.
- **`profiles/<name>/commands/`** — Profile-specific slash commands that leverage the domain agent.
- **`base/agents/`** — Task-oriented agents for discrete jobs (reviewing, testing, security, refactoring, docs, migrations, deps).
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

### Standards injection ({{STANDARDS}} template)

Agent `.md` files use `{{STANDARDS}}` as a placeholder instead of duplicating the standards block. During `install.sh`, this placeholder is replaced with the contents of `base/standards.md`. This keeps standards in one place — edit `base/standards.md` and re-run install to update all agents.

## Shared Task Agents

These agents are available in every installation:

| Agent | Purpose |
|-------|---------|
| `code-reviewer` | Reviews diffs for quality issues. Returns structured findings (blocker/warning/suggestion) |
| `test-generator` | Generates tests for source files following Arrange-Act-Assert |
| `dependency-auditor` | Audits dependency manifests for unused, heavy, or vulnerable packages |
| `security-auditor` | Audits code for OWASP Top 10, hardcoded secrets, injection risks, insecure configs |
| `documentation-writer` | Generates or updates READMEs, API docs, ADRs, and module documentation |
| `refactorer` | Identifies code smells, complexity hotspots, and recommends specific refactorings |
| `migration-planner` | Plans database migrations, dependency upgrades, and framework transitions |

## Slash Commands

### Base Commands (all installations)

| Command | Description |
|---------|-------------|
| `/review` | Review staged or recent changes for quality issues |
| `/explain <path>` | Explain the architecture and purpose of a file or module |
| `/audit-deps` | Audit project dependencies |
| `/standup` | Generate a standup summary from recent git activity |
| `/commit` | Generate a conventional commit message from staged changes |
| `/refactor <path>` | Identify refactoring opportunities in a file or module |
| `/security [path]` | Run a security audit on a file, module, or staged changes |
| `/doc <path>` | Generate or update documentation for a file or module |
| `/todo` | Scan codebase for TODO/FIXME/HACK comments and prioritize them |

### Profile-Specific Commands

| Command | Profile | Description |
|---------|---------|-------------|
| `/generate-module <name>` | nestjs-backend | Scaffold a NestJS feature module with clean architecture layers |
| `/create-component <name>` | vue-frontend | Scaffold a Vue 3 component with TypeScript and tests |
| `/tf-plan` | gcp-cloudops | Review a Terraform plan for risks and best practices |
| `/api-design <endpoint>` | ai-connectors | Design or review a FastAPI endpoint for AI connectors |
| `/profile <path>` | performance-engineering | Analyze code for performance issues using USE/RED methods |

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

The generated agent uses the `{{STANDARDS}}` placeholder — standards are injected at install time from `base/standards.md`. Fill in the domain-specific sections (Technical Stack, Conventions) and customize the agent description and role statement.

## Uninstalling

```bash
./uninstall.sh
```

This restores `settings.json` from the backup, removes installed agents and commands, strips the profile sections from `CLAUDE.md`, and deletes the manifest.

## License

MIT
