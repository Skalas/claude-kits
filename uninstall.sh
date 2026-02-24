#!/usr/bin/env bash
set -euo pipefail

CLAUDE_DIR="$HOME/.claude"
COMMANDS_DIR="$CLAUDE_DIR/commands"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"
MANIFEST_FILE="$CLAUDE_DIR/.installed-profile"
CLAUDE_MD="$CLAUDE_DIR/CLAUDE.md"

if [ ! -f "$MANIFEST_FILE" ]; then
  echo "No profile is currently installed (no manifest at $MANIFEST_FILE)."
  exit 0
fi

# Read manifest
source "$MANIFEST_FILE"

echo "Uninstalling profile: $PROFILE"

# --- Restore settings.json from backup ---
BACKUP="${SETTINGS_BACKUP:-$SETTINGS_FILE.bak}"
if [ -f "$BACKUP" ]; then
  cp "$BACKUP" "$SETTINGS_FILE"
  rm -f "$BACKUP"
  echo "  [ok] Restored settings.json from backup"
else
  echo "  [warn] No settings backup found, settings.json left as-is"
fi

# --- Remove installed commands ---
if [ -n "${COMMANDS:-}" ]; then
  for cmd in $COMMANDS; do
    if [ -f "$COMMANDS_DIR/$cmd" ]; then
      rm -f "$COMMANDS_DIR/$cmd"
      echo "  [ok] Removed command: $cmd"
    fi
  done
fi

# --- Remove CLAUDE.md sections ---
if [ -f "$CLAUDE_MD" ]; then
  MARKER="# --- claude-profiles: $PROFILE ---"
  END_MARKER="# --- end claude-profiles ---"
  if grep -qF "$MARKER" "$CLAUDE_MD"; then
    # Remove everything between markers (inclusive)
    sed -i '' "/$MARKER/,/$END_MARKER/d" "$CLAUDE_MD"
    echo "  [ok] Removed CLAUDE.md profile sections"
  fi
fi

# --- Remove manifest ---
rm -f "$MANIFEST_FILE"

echo ""
echo "Profile '$PROFILE' uninstalled successfully."
