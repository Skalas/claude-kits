#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
AGENTS_DIR="$CLAUDE_DIR/agents"
COMMANDS_DIR="$CLAUDE_DIR/commands"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"
MANIFEST_FILE="$CLAUDE_DIR/.installed-profile"

usage() {
  echo "Usage: $0 <profile-name>"
  echo ""
  echo "Installs a claude-profiles profile into ~/.claude/"
  echo "Merges base + profile settings into existing user config using jq."
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

PROFILE="$1"
PROFILE_DIR="$SCRIPT_DIR/profiles/$PROFILE"

if [ ! -d "$PROFILE_DIR" ]; then
  echo "Error: profile '$PROFILE' not found at $PROFILE_DIR"
  usage
fi

# Check for jq
if ! command -v jq &>/dev/null; then
  echo "Error: jq is required. Install it with: brew install jq"
  exit 1
fi

# Ensure target directories exist
mkdir -p "$AGENTS_DIR"
mkdir -p "$COMMANDS_DIR"

# Initialize settings.json if it doesn't exist
if [ ! -f "$SETTINGS_FILE" ]; then
  echo '{}' > "$SETTINGS_FILE"
fi

# --- Uninstall previous profile if one is active ---
if [ -f "$MANIFEST_FILE" ]; then
  echo "Uninstalling previous profile before installing '$PROFILE'..."
  bash "$SCRIPT_DIR/uninstall.sh"
fi

echo "Installing profile: $PROFILE"
echo "  base:    $SCRIPT_DIR/base"
echo "  profile: $PROFILE_DIR"
echo ""

# --- Track installed files for clean uninstall ---
INSTALLED_AGENTS=()
INSTALLED_COMMANDS=()

# --- Merge settings.json (base + profile → existing user config) ---
# Start with base settings
MERGED_SETTINGS=$(cat "$SCRIPT_DIR/base/settings.json")

# Overlay profile settings if they exist
if [ -f "$PROFILE_DIR/settings.json" ]; then
  MERGED_SETTINGS=$(echo "$MERGED_SETTINGS" | jq -s '.[0] * .[1]' - "$PROFILE_DIR/settings.json")
fi

# Deep-merge into existing user settings
# Strategy: profile agent groups and hooks are added/merged, existing unrelated keys are preserved
EXISTING_SETTINGS=$(cat "$SETTINGS_FILE")
FINAL_SETTINGS=$(echo "$EXISTING_SETTINGS" | jq -s '
  .[0] as $existing |
  .[1] as $new |
  $existing * $new
' - <(echo "$MERGED_SETTINGS"))

# Back up current settings
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

# --- Copy profile agents ---
if [ -d "$PROFILE_DIR/agents" ]; then
  for agent in "$PROFILE_DIR/agents"/*.md; do
    [ -f "$agent" ] || continue
    BASENAME=$(basename "$agent")
    cp "$agent" "$AGENTS_DIR/$BASENAME"
    INSTALLED_AGENTS+=("$BASENAME")
    echo "  [ok] Installed profile agent: $BASENAME"
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

# --- Copy profile commands ---
if [ -d "$PROFILE_DIR/commands" ]; then
  for cmd in "$PROFILE_DIR/commands"/*.md; do
    [ -f "$cmd" ] || continue
    BASENAME=$(basename "$cmd")
    cp "$cmd" "$COMMANDS_DIR/$BASENAME"
    INSTALLED_COMMANDS+=("$BASENAME")
    echo "  [ok] Installed profile command: $BASENAME"
  done
fi

# --- Handle CLAUDE.md (append base + profile to user-level) ---
CLAUDE_MD="$CLAUDE_DIR/CLAUDE.md"
CLAUDE_MD_MARKER="# --- claude-profiles: $PROFILE ---"

if [ -f "$SCRIPT_DIR/base/CLAUDE.md" ] || [ -f "$PROFILE_DIR/CLAUDE.md" ]; then
  {
    echo ""
    echo "$CLAUDE_MD_MARKER"
    [ -f "$SCRIPT_DIR/base/CLAUDE.md" ] && cat "$SCRIPT_DIR/base/CLAUDE.md"
    echo ""
    [ -f "$PROFILE_DIR/CLAUDE.md" ] && cat "$PROFILE_DIR/CLAUDE.md"
    echo "# --- end claude-profiles ---"
  } >> "$CLAUDE_MD"
  echo "  [ok] Appended CLAUDE.md sections"
fi

# --- Write manifest ---
{
  echo "PROFILE=$PROFILE"
  echo "INSTALLED_AT=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "SETTINGS_BACKUP=$SETTINGS_FILE.bak"
  echo "AGENTS=${INSTALLED_AGENTS[*]}"
  echo "COMMANDS=${INSTALLED_COMMANDS[*]}"
} > "$MANIFEST_FILE"

echo ""
echo "Profile '$PROFILE' installed successfully."
echo "Manifest written to $MANIFEST_FILE"
