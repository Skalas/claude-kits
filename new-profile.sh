#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  echo "Usage: $0 <profile-name>"
  echo ""
  echo "Scaffolds a new profile directory under profiles/<profile-name>/"
  echo "with template files for agents, commands, settings, and CLAUDE.md."
  exit 1
}

if [ $# -lt 1 ]; then
  usage
fi

PROFILE="$1"
PROFILE_DIR="$SCRIPT_DIR/profiles/$PROFILE"

if [ -d "$PROFILE_DIR" ]; then
  echo "Error: profile '$PROFILE' already exists at $PROFILE_DIR"
  exit 1
fi

echo "Scaffolding profile: $PROFILE"

mkdir -p "$PROFILE_DIR"/{agents,commands}

# --- Template: settings.json ---
cat > "$PROFILE_DIR/settings.json" <<'EOF'
{
  "agentGroups": {},
  "hooks": {}
}
EOF

# --- Template: CLAUDE.md ---
cat > "$PROFILE_DIR/CLAUDE.md" <<EOF
# ${PROFILE} Profile

The team engineering standards (Clean Architecture, DRY, KISS, Clean Code) apply. The conventions below extend those standards with domain-specific guidance.

## Technical Stack

<!-- Define the languages, frameworks, and tools for this profile -->

## Conventions

<!-- Add domain-specific coding conventions, patterns, and best practices -->

## Project Structure

<!-- Describe the expected directory layout -->

## Testing

<!-- Define testing strategy: frameworks, patterns, coverage expectations -->
EOF

# --- Template: domain agent ---
AGENT_NAME="${PROFILE}-engineer"
cat > "$PROFILE_DIR/agents/${AGENT_NAME}.md" <<EOF
---
name: ${AGENT_NAME}
description: "Use this agent for ${PROFILE} tasks. Add a detailed description of what this agent covers."
model: sonnet
color: green
---

You are a ${PROFILE} engineer. Describe the agent's role and expertise here.

{{STANDARDS}}

## Technical Stack

<!-- Define the languages, frameworks, and tools for this domain -->

## Conventions

<!-- Add domain-specific coding conventions, patterns, and best practices -->
EOF

# --- Template: example command ---
cat > "$PROFILE_DIR/commands/.gitkeep" <<'EOF'
EOF

echo ""
echo "Profile scaffolded at: $PROFILE_DIR"
echo ""
echo "Directory structure:"
echo "  $PROFILE_DIR/"
echo "  ├── agents/           # Domain agent (template created)"
echo "  ├── commands/         # Add skill/command .md files here"
echo "  ├── settings.json     # Agent groups, hooks, MCP config"
echo "  └── CLAUDE.md         # Profile system prompt"
echo ""
echo "Next steps:"
echo "  1. Edit agent:    vi $PROFILE_DIR/agents/${AGENT_NAME}.md"
echo "  2. Edit conventions: vi $PROFILE_DIR/CLAUDE.md"
echo "  3. Add commands:  create .md files in $PROFILE_DIR/commands/"
echo "  4. Install:       ./install.sh --all"
