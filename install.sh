#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
AGENTS_DIR="$CLAUDE_DIR/agents"
COMMANDS_DIR="$CLAUDE_DIR/commands"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"
MANIFEST_FILE="$CLAUDE_DIR/.installed-profile"

usage() {
  echo "Usage: $0 [--all | <profile-name>]"
  echo ""
  echo "Installs claude-profiles configuration into ~/.claude/"
  echo ""
  echo "Options:"
  echo "  --all              Install base + ALL profiles (agents, commands, settings, CLAUDE.md)"
  echo "  <profile-name>     Install base + a single profile"
  echo ""
  echo "Available profiles:"
  for dir in "$SCRIPT_DIR/profiles"/*/; do
    [ -d "$dir" ] && echo "  - $(basename "$dir")"
  done
  exit 1
}

if [ $# -lt 1 ]; then
  usage
fi

# Check for jq
if ! command -v jq &>/dev/null; then
  echo "Error: jq is required. Install it with: brew install jq"
  exit 1
fi

# Determine which profiles to install
PROFILES=()
if [ "$1" = "--all" ]; then
  for dir in "$SCRIPT_DIR/profiles"/*/; do
    [ -d "$dir" ] && PROFILES+=("$(basename "$dir")")
  done
  PROFILE_LABEL="all"
else
  PROFILE="$1"
  PROFILE_DIR="$SCRIPT_DIR/profiles/$PROFILE"
  if [ ! -d "$PROFILE_DIR" ]; then
    echo "Error: profile '$PROFILE' not found at $PROFILE_DIR"
    usage
  fi
  PROFILES+=("$PROFILE")
  PROFILE_LABEL="$PROFILE"
fi

# Ensure target directories exist
mkdir -p "$AGENTS_DIR"
mkdir -p "$COMMANDS_DIR"

# Initialize settings.json if it doesn't exist
if [ ! -f "$SETTINGS_FILE" ]; then
  echo '{}' > "$SETTINGS_FILE"
fi

# --- Uninstall previous installation if one is active ---
if [ -f "$MANIFEST_FILE" ]; then
  echo "Uninstalling previous installation..."
  bash "$SCRIPT_DIR/uninstall.sh"
fi

echo "Installing: $PROFILE_LABEL"
echo "  base:     $SCRIPT_DIR/base"
echo "  profiles: ${PROFILES[*]}"
echo ""

# --- Track installed files for clean uninstall ---
INSTALLED_AGENTS=()
INSTALLED_COMMANDS=()

# --- Merge settings.json (base + all profiles → existing user config) ---
MERGED_SETTINGS=$(cat "$SCRIPT_DIR/base/settings.json")

for p in "${PROFILES[@]}"; do
  pdir="$SCRIPT_DIR/profiles/$p"
  if [ -f "$pdir/settings.json" ]; then
    MERGED_SETTINGS=$(echo "$MERGED_SETTINGS" | jq -s '.[0] * .[1]' - "$pdir/settings.json")
  fi
done

EXISTING_SETTINGS=$(cat "$SETTINGS_FILE")
FINAL_SETTINGS=$(echo "$EXISTING_SETTINGS" | jq -s '
  .[0] as $existing |
  .[1] as $new |
  $existing * $new
' - <(echo "$MERGED_SETTINGS"))

cp "$SETTINGS_FILE" "$SETTINGS_FILE.bak"
echo "$FINAL_SETTINGS" | jq '.' > "$SETTINGS_FILE"
echo "  [ok] Merged settings.json (backup at settings.json.bak)"

# --- Copy base agents ---
if [ -d "$SCRIPT_DIR/base/agents" ]; then
  for agent in "$SCRIPT_DIR/base/agents"/*.md; do
    [ -f "$agent" ] || continue
    BASENAME=$(basename "$agent")
    cp "$agent" "$AGENTS_DIR/$BASENAME"
    INSTALLED_AGENTS+=("$BASENAME")
    echo "  [ok] Installed base agent: $BASENAME"
  done
fi

# --- Copy base commands ---
if [ -d "$SCRIPT_DIR/base/commands" ]; then
  for cmd in "$SCRIPT_DIR/base/commands"/*.md; do
    [ -f "$cmd" ] || continue
    BASENAME=$(basename "$cmd")
    cp "$cmd" "$COMMANDS_DIR/$BASENAME"
    INSTALLED_COMMANDS+=("$BASENAME")
    echo "  [ok] Installed base command: $BASENAME"
  done
fi

# --- Copy profile agents and commands ---
for p in "${PROFILES[@]}"; do
  pdir="$SCRIPT_DIR/profiles/$p"

  if [ -d "$pdir/agents" ]; then
    for agent in "$pdir/agents"/*.md; do
      [ -f "$agent" ] || continue
      BASENAME=$(basename "$agent")
      cp "$agent" "$AGENTS_DIR/$BASENAME"
      INSTALLED_AGENTS+=("$BASENAME")
      echo "  [ok] Installed $p agent: $BASENAME"
    done
  fi

  if [ -d "$pdir/commands" ]; then
    for cmd in "$pdir/commands"/*.md; do
      [ -f "$cmd" ] || continue
      BASENAME=$(basename "$cmd")
      cp "$cmd" "$COMMANDS_DIR/$BASENAME"
      INSTALLED_COMMANDS+=("$BASENAME")
      echo "  [ok] Installed $p command: $BASENAME"
    done
  fi
done

# --- Handle CLAUDE.md (append base only — domain expertise is in agents) ---
CLAUDE_MD="$CLAUDE_DIR/CLAUDE.md"
CLAUDE_MD_MARKER="# --- claude-profiles: $PROFILE_LABEL ---"

{
  echo ""
  echo "$CLAUDE_MD_MARKER"
  [ -f "$SCRIPT_DIR/base/CLAUDE.md" ] && cat "$SCRIPT_DIR/base/CLAUDE.md"
  echo "# --- end claude-profiles ---"
} >> "$CLAUDE_MD"
echo "  [ok] Appended CLAUDE.md (interaction preferences only)"

# --- Write manifest ---
{
  echo "PROFILE=$PROFILE_LABEL"
  echo "INSTALLED_AT=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "SETTINGS_BACKUP=$SETTINGS_FILE.bak"
  echo "AGENTS=\"${INSTALLED_AGENTS[*]}\""
  echo "COMMANDS=\"${INSTALLED_COMMANDS[*]}\""
} > "$MANIFEST_FILE"

echo ""
echo "Installation complete: $PROFILE_LABEL"
echo "  Agents:   ${#INSTALLED_AGENTS[@]}"
echo "  Commands: ${#INSTALLED_COMMANDS[@]}"
echo "  Profiles: ${#PROFILES[@]}"
echo "Manifest written to $MANIFEST_FILE"
