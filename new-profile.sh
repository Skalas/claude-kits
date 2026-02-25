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

## Team Engineering Standards

These standards apply to all work regardless of domain or technology.

### Clean Architecture

Organize code in layers with dependencies pointing inward:

1. **Domain** (innermost) — Core business logic, entities, value objects, repository interfaces, custom exceptions. No framework imports. Pure language constructs.
2. **Application** — Use cases and services that orchestrate domain logic. Depends only on domain interfaces. Contains DTOs/schemas and port definitions.
3. **Infrastructure** — Concrete implementations: database adapters, external API clients, messaging, file storage. Implements the ports defined in the application layer.
4. **Presentation** (outermost) — Controllers, routers, CLI handlers, middleware. Thin — validates input, calls application services, returns responses.

The domain and application layers must never import from infrastructure or presentation. Enforce this through module boundaries and interfaces.

### DRY (Don't Repeat Yourself)

- Extract shared logic into well-named utility functions, base classes, or shared services
- Use generics and protocols/interfaces for repeated patterns
- Centralize validation rules, error messages, configuration constants, and retry policies
- Share data transfer schemas through inheritance or composition when appropriate
- Never sacrifice clarity for DRY — if two things look similar but serve different purposes, keep them separate

### KISS (Keep It Simple, Stupid)

- Choose the simplest solution that satisfies the requirements
- Avoid unnecessary abstractions — don't create an interface for a class that will only ever have one implementation (unless it's at an architecture boundary)
- Prefer composition over deep inheritance hierarchies
- Use framework built-in features before reaching for external libraries
- If a pattern feels overly complex, step back and simplify
- Flat is better than nested: avoid deeply nested conditionals and callbacks

### Clean Code

- **Naming**: Names reveal intent. A function name tells you what it does without reading the body. Use domain language consistently.
- **Functions**: Small, focused, single-responsibility. Ideally under 20 lines. One level of abstraction per function.
- **Comments**: Code should be self-documenting. Only comment *why*, never *what*. If you need a comment to explain what the code does, refactor the code instead.
- **Error handling**: Use domain-specific exceptions and structured error responses. Never swallow errors. Never use generic catch-all error messages.
- **No magic**: No magic numbers, no magic strings. Use enums, constants, and configuration.

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
