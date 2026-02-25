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

# --- Template: example agent ---
cat > "$PROFILE_DIR/agents/.gitkeep" <<'EOF'
EOF

# --- Template: example command ---
cat > "$PROFILE_DIR/commands/.gitkeep" <<'EOF'
EOF

echo ""
echo "Profile scaffolded at: $PROFILE_DIR"
echo ""
echo "Directory structure:"
echo "  $PROFILE_DIR/"
echo "  ├── agents/           # Add agent .md files here"
echo "  ├── commands/         # Add skill/command .md files here"
echo "  ├── settings.json     # Agent groups, hooks, MCP config"
echo "  └── CLAUDE.md         # Profile system prompt"
echo ""
echo "Next steps:"
echo "  1. Add agents:   cp your-agent.md $PROFILE_DIR/agents/"
echo "  2. Add commands:  create .md files in $PROFILE_DIR/commands/"
echo "  3. Edit settings: vi $PROFILE_DIR/settings.json"
echo "  4. Install:       ./install.sh $PROFILE"
