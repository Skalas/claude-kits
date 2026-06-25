#!/usr/bin/env bash
set -euo pipefail

CLAUDE_DIR="$HOME/.claude"
AGENTS_DIR="$CLAUDE_DIR/agents"
COMMANDS_DIR="$CLAUDE_DIR/commands"
SKILLS_DIR="$CLAUDE_DIR/skills"
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

# --- Surgically remove only claude-kits settings keys ---
BACKUP="${SETTINGS_BACKUP:-$SETTINGS_FILE.bak}"
KITS_SETTINGS="$CLAUDE_DIR/.claude-kits-settings.json"

if [ -f "$KITS_SETTINGS" ] && [ -f "$BACKUP" ]; then
  # For each key in current settings:
  #   - If claude-kits managed it AND it existed pre-install → restore original value
  #   - If claude-kits managed it AND it didn't exist pre-install → remove it
  #   - If claude-kits didn't manage it → keep current value (preserves user additions)
  jq --slurpfile backup "$BACKUP" \
     --slurpfile kits "$KITS_SETTINGS" '
    $backup[0] as $b | $kits[0] as $k |
    [ to_entries[] | . as $entry |
      if ($k | has($entry.key)) then
        if ($b | has($entry.key)) then
          $entry | .value = $b[$entry.key]
        else
          empty
        end
      else
        $entry
      end
    ] | from_entries
  ' "$SETTINGS_FILE" > "${SETTINGS_FILE}.tmp" && mv "${SETTINGS_FILE}.tmp" "$SETTINGS_FILE"
  rm -f "$BACKUP" "$KITS_SETTINGS"
  echo "  [ok] Removed claude-kits settings (preserved user additions)"
elif [ -f "$BACKUP" ]; then
  # Fallback for installations before surgical uninstall was added
  cp "$BACKUP" "$SETTINGS_FILE"
  rm -f "$BACKUP"
  echo "  [ok] Restored settings.json from backup (legacy)"
else
  echo "  [warn] No settings backup found, settings.json left as-is"
fi

# --- Remove installed agents ---
if [ -n "${AGENTS:-}" ]; then
  for agent in $AGENTS; do
    if [ -f "$AGENTS_DIR/$agent" ]; then
      rm -f "$AGENTS_DIR/$agent"
      echo "  [ok] Removed agent: $agent"
    fi
  done
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

# --- Remove installed skills (preserve user data) ---
# We only touch skill directories we installed (tracked in SKILLS).
# User-added skills elsewhere under $SKILLS_DIR are never touched.
# Within each tracked skill dir we remove SKILL.md, the unfilled my-voice.md
# template, and the shipped samples/README.md. We keep the user's edited
# my-voice.md and any samples they added. The dir is removed only if empty.
if [ -n "${SKILLS:-}" ]; then
  for skill in $SKILLS; do
    skill_dir="$SKILLS_DIR/$skill"
    [ -d "$skill_dir" ] || continue

    rm -f "$skill_dir/SKILL.md"

    if [ -f "$skill_dir/my-voice.md" ] && grep -q '{{UNFILLED}}' "$skill_dir/my-voice.md"; then
      rm -f "$skill_dir/my-voice.md"
    fi

    if [ -d "$skill_dir/samples" ]; then
      rm -f "$skill_dir/samples/README.md"
      user_samples=$(find "$skill_dir/samples" -mindepth 1 ! -name '.gitkeep' 2>/dev/null | head -n 1)
      if [ -z "$user_samples" ]; then
        rm -f "$skill_dir/samples/.gitkeep"
        rmdir "$skill_dir/samples" 2>/dev/null || true
      fi
    fi

    if [ -z "$(ls -A "$skill_dir" 2>/dev/null)" ]; then
      rmdir "$skill_dir"
      echo "  [ok] Removed skill: $skill"
    else
      echo "  [info] Skill '$skill' kept at $skill_dir (user data present)"
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
