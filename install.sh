#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
AGENTS_DIR="$CLAUDE_DIR/agents"
COMMANDS_DIR="$CLAUDE_DIR/commands"
SKILLS_DIR="$CLAUDE_DIR/skills"
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
mkdir -p "$SKILLS_DIR"

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
INSTALLED_SKILLS=()

# --- Load standards for injection into agents ---
STANDARDS_FILE="$SCRIPT_DIR/base/standards.md"
if [ ! -f "$STANDARDS_FILE" ]; then
  echo "Error: standards.md not found at $STANDARDS_FILE"
  exit 1
fi

# Function to copy an agent file, injecting standards at {{STANDARDS}} placeholder
install_agent() {
  local src="$1"
  local dest="$2"
  if grep -qF '{{STANDARDS}}' "$src"; then
    awk 'NR==FNR{gsub(/&/,"\\\\&"); standards=standards (NR>1?"\n":"") $0; next} {gsub(/\{\{STANDARDS\}\}/, standards); print}' "$STANDARDS_FILE" "$src" > "$dest"
  else
    cp "$src" "$dest"
  fi
}

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
echo "$MERGED_SETTINGS" | jq '.' > "$CLAUDE_DIR/.claude-kits-settings.json"
echo "$FINAL_SETTINGS" | jq '.' > "$SETTINGS_FILE"
echo "  [ok] Merged settings.json (backup at settings.json.bak)"

# --- Copy base agents ---
if [ -d "$SCRIPT_DIR/base/agents" ]; then
  for agent in "$SCRIPT_DIR/base/agents"/*.md; do
    [ -f "$agent" ] || continue
    BASENAME=$(basename "$agent")
    install_agent "$agent" "$AGENTS_DIR/$BASENAME"
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

# --- Copy base skills (directories, preserving user data) ---
# Skills are directories under ~/.claude/skills/<skill-name>/. To avoid
# clobbering user-owned skills (e.g. a manually installed humanizer):
#   - We never rm -rf $SKILLS_DIR. We only touch directories we own.
#   - SKILL.md is always overwritten (it's our code).
#   - my-voice.md is copied only if missing (preserve user edits).
#   - samples/ is created if missing; existing user samples are left alone.
#   - Other top-level .md docs in the skill dir are copied fresh.
if [ -d "$SCRIPT_DIR/base/skills" ]; then
  for skill_src in "$SCRIPT_DIR/base/skills"/*/; do
    [ -d "$skill_src" ] || continue
    skill_name=$(basename "$skill_src")
    skill_dest="$SKILLS_DIR/$skill_name"
    mkdir -p "$skill_dest"

    if [ -f "$skill_src/SKILL.md" ]; then
      cp "$skill_src/SKILL.md" "$skill_dest/SKILL.md"
    fi

    if [ -f "$skill_src/my-voice.md" ] && [ ! -f "$skill_dest/my-voice.md" ]; then
      cp "$skill_src/my-voice.md" "$skill_dest/my-voice.md"
    fi

    mkdir -p "$skill_dest/samples"
    if [ -f "$skill_src/samples/README.md" ] && [ ! -f "$skill_dest/samples/README.md" ]; then
      cp "$skill_src/samples/README.md" "$skill_dest/samples/README.md"
    fi

    for other in "$skill_src"*.md; do
      [ -f "$other" ] || continue
      base=$(basename "$other")
      case "$base" in
        SKILL.md|my-voice.md) continue ;;
      esac
      cp "$other" "$skill_dest/$base"
    done

    INSTALLED_SKILLS+=("$skill_name")
    echo "  [ok] Installed skill: $skill_name"
  done
fi

# --- Copy profile agents and commands ---
for p in "${PROFILES[@]}"; do
  pdir="$SCRIPT_DIR/profiles/$p"

  if [ -d "$pdir/agents" ]; then
    for agent in "$pdir/agents"/*.md; do
      [ -f "$agent" ] || continue
      BASENAME=$(basename "$agent")
      install_agent "$agent" "$AGENTS_DIR/$BASENAME"
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
  if [ -f "$SCRIPT_DIR/base/CLAUDE.md" ]; then
    if grep -qF '{{STANDARDS}}' "$SCRIPT_DIR/base/CLAUDE.md"; then
      awk 'NR==FNR{gsub(/&/,"\\\\&"); standards=standards (NR>1?"\n":"") $0; next} {gsub(/\{\{STANDARDS\}\}/, standards); print}' "$STANDARDS_FILE" "$SCRIPT_DIR/base/CLAUDE.md"
    else
      cat "$SCRIPT_DIR/base/CLAUDE.md"
    fi
  fi
  echo "# --- end claude-profiles ---"
} >> "$CLAUDE_MD"
echo "  [ok] Appended CLAUDE.md (standards + interaction preferences)"

# --- Write manifest ---
{
  echo "PROFILE=$PROFILE_LABEL"
  echo "INSTALLED_AT=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "SETTINGS_BACKUP=$SETTINGS_FILE.bak"
  echo "AGENTS=\"${INSTALLED_AGENTS[*]}\""
  echo "COMMANDS=\"${INSTALLED_COMMANDS[*]}\""
  echo "SKILLS=\"${INSTALLED_SKILLS[*]}\""
} > "$MANIFEST_FILE"

echo ""
echo "Installation complete: $PROFILE_LABEL"
echo "  Agents:   ${#INSTALLED_AGENTS[@]}"
echo "  Commands: ${#INSTALLED_COMMANDS[@]}"
echo "  Skills:   ${#INSTALLED_SKILLS[@]}"
echo "  Profiles: ${#PROFILES[@]}"
echo "Manifest written to $MANIFEST_FILE"
