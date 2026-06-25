# Claude Profiles

This repository manages reusable Claude Code configuration profiles. Each profile provides a self-contained domain agent with full engineering standards and expertise, plus shared task agents, commands, and settings — all installed into `~/.claude/`.

## Repository Structure

```
base/                  # Shared foundation applied to ALL profiles
  CLAUDE.md            # Interaction preferences (working approach, communication style)
  standards.md         # Engineering standards source (Clean Architecture, DRY, KISS, Clean Code)
  settings.json        # Settings merged into every profile
  agents/              # Task-oriented agents (code-reviewer, test-generator, dependency-auditor)
  commands/            # Slash commands — workflow (/plan, /ship, /review) and task (/commit, /explain, /standup)
  skills/<name>/       # Bundled skills installed to ~/.claude/skills/<name>/ (SKILL.md + assets)

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
4. Mirrors each `base/skills/<name>/` into `~/.claude/skills/<name>/`. User-owned skills (directories we didn't install) are never touched. Inside managed skill dirs we overwrite `SKILL.md` but preserve user-edited files such as `my-voice.md` and `samples/` contents
5. Appends `base/CLAUDE.md` (standards + interaction preferences, with `{{STANDARDS}}` injected) to `~/.claude/CLAUDE.md`
6. Writes a manifest to `~/.claude/.installed-profile` for clean uninstall

You can also install a single profile with `install.sh <profile>` if preferred.

## Design Principles

- **Two types of commands** — *Workflow commands* (`/plan`, `/ship`, `/review`) are cognitive modes that change how the main session thinks. *Task commands* (`/commit`, `/explain`, `/standup`) are quick utilities. Workflow commands may delegate to subagents for heavy lifting.
- **Agents are self-contained** — each domain agent includes full engineering standards + domain expertise, since agents run as isolated subprocesses without access to `CLAUDE.md`
- **Commands orchestrate agents** — workflow commands like `/review` launch `code-reviewer`, `security-auditor`, and `refactorer` in parallel, then merge findings into three tiers (CRITICAL / DESIGN / INFORMATIONAL). This combines cognitive modes with specialist delegation.
- **`CLAUDE.md` is slim** — only sets interaction preferences (working approach, communication style) for the main session
- **`base/standards.md` is the single source** — engineering standards live here once; agents use `{{STANDARDS}}` placeholder, and `install.sh` injects the content at install time
- **All domains available at once** — `--all` installs every domain agent; no switching needed

## Available Profiles

| Profile | Domain Agent | Description |
|---------|-------------|-------------|
| `ai-connectors` | `ai-connector-engineer` | FastAPI, Python async, AI API patterns, Docker, GCP |
| `nestjs-backend` | `nestjs-engineer` | NestJS modules, Prisma, PostgreSQL, Jest |
| `gcp-cloudops` | `gcp-cloudops-engineer` | GCP services, Terraform, CI/CD, networking, IAM, monitoring |
| `performance-engineering` | `performance-engineer` | Python/Node.js profiling, USE/RED methods, concurrency, HA |
| `vue-frontend` | `vue-engineer` | Vue 3 Composition API, TypeScript, Pinia, Vue Router, SOLID |

## Agent Template System

Agent `.md` files use `{{STANDARDS}}` as a placeholder for engineering standards. At install time, `install.sh` replaces this placeholder with the contents of `base/standards.md`. This means:
- Standards are defined once in `base/standards.md`
- All agents stay in sync automatically
- To update standards, edit `base/standards.md` and re-run `install.sh`

## Commands

```bash
./install.sh --all          # Install base + ALL profiles (recommended)
./install.sh <profile>      # Install base + a single profile
./uninstall.sh              # Remove the active installation
./new-profile.sh <name>     # Scaffold a new profile with template agent
./kit-doctor.sh             # Report kit-owned files that drifted from the kit
```

## Provenance & Safety

- **Collision guard** — `install.sh` never overwrites a file it doesn't own. A destination is writable only if it doesn't yet exist or was listed in the prior `~/.claude/.installed-profile`. A personal command/agent/skill that name-collides with a kit file is skipped and reported, never clobbered.
- **`.kit-lock`** — each install records the kit remote, ref, SHA, and timestamp to `~/.claude/.kit-lock`, so the installed revision is always identifiable.
- **`kit-doctor.sh`** — regenerates each installed kit file from source (expanding `{{STANDARDS}}`) and diffs it against the installed copy. A kit-owned file hand-edited in place is flagged as `DRIFTED` — backport it to the kit or it is lost on the next install. Also reports whether `.kit-lock` is behind kit HEAD. Exits non-zero on drift (CI/cron friendly).
