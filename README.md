# claude-profiles

Manage switchable [Claude Code](https://docs.anthropic.com/en/docs/claude-code) configuration profiles — agents, commands, settings, and system prompts — from a single repository.

## Why?

Claude Code reads its configuration from `~/.claude/` (settings, agents, commands, `CLAUDE.md`). When you work across different projects — backend APIs, cloud infrastructure, frontend apps — you want different agents and instructions active. Manually swapping files is tedious and error-prone.

**claude-profiles** gives you:
- **Profiles** — named bundles of agents, commands, settings, and prompts
- **A shared base** — common configuration inherited by every profile
- **One-command switching** — install/uninstall with a single script
- **Clean uninstall** — a manifest tracks every file so nothing is left behind

## Quick Start

```bash
# Clone the repo
git clone https://github.com/skalas/claude-profiles.git
cd claude-profiles

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

| Profile | Description |
|---------|-------------|
| `ai-connectors` | AI service integrations — FastAPI, Docker, GCP, connectors for OpenAI/Anthropic/Google AI |
| `nestjs-backend` | NestJS backend with clean architecture, Prisma, PostgreSQL |
| `gcp-cloudops` | GCP infrastructure — Terraform, CI/CD pipelines, IAM, monitoring, cost optimization |
| `performance-engineering` | Performance profiling and optimization for Python/Node.js applications on GCP |
| `vue-frontend` | Vue.js frontend development |

## How It Works

```
base/                        # Shared by ALL profiles
  ├── CLAUDE.md              # Common system prompt
  ├── settings.json          # Common settings
  ├── agents/                # Common agents
  └── commands/              # Common commands

profiles/<name>/             # One active at a time
  ├── CLAUDE.md              # Profile-specific prompt
  ├── settings.json          # Profile-specific settings
  ├── agents/                # Profile-specific agents
  └── commands/              # Profile-specific commands
```

When you run `./install.sh <profile>`:

1. **Settings** — `base/settings.json` is merged with `profiles/<name>/settings.json`, then deep-merged into your existing `~/.claude/settings.json`. A backup is saved as `settings.json.bak`.
2. **Agents & Commands** — Files from both `base/` and the profile are copied into `~/.claude/agents/` and `~/.claude/commands/`.
3. **CLAUDE.md** — Both base and profile `CLAUDE.md` contents are appended to `~/.claude/CLAUDE.md` between markers for clean removal.
4. **Manifest** — A manifest at `~/.claude/.installed-profile` tracks everything that was installed, enabling clean uninstall.

Installing a new profile automatically uninstalls the previous one first.

## Creating a New Profile

```bash
./new-profile.sh my-profile
```

This scaffolds:

```
profiles/my-profile/
  ├── agents/           # Add agent .md files here
  ├── commands/         # Add command .md files here
  ├── settings.json     # Agent groups, hooks, MCP config
  └── CLAUDE.md         # Profile system prompt
```

Then customize the files and install with `./install.sh my-profile`.

## Uninstalling

```bash
./uninstall.sh
```

This restores `settings.json` from the backup, removes installed agents and commands, strips the profile sections from `CLAUDE.md`, and deletes the manifest.

## License

MIT
