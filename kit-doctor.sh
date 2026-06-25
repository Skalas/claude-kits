#!/usr/bin/env bash
set -euo pipefail

# kit-doctor — drift detector for an installed claude-kits profile.
#
# For every kit-owned file recorded in ~/.claude/.installed-profile, it
# regenerates what install.sh *would* produce from the kit source (expanding
# {{STANDARDS}} for agents) and diffs it against what is actually installed.
# This catches the silent failure mode where a kit-owned file is hand-edited
# in place: such an edit must be backported to the kit or it is lost on the
# next install. It also reports whether the installed revision (.kit-lock) is
# behind the current kit HEAD.
#
# Exit codes: 0 = everything in sync; 1 = drift or missing files detected.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
AGENTS_DIR="$CLAUDE_DIR/agents"
COMMANDS_DIR="$CLAUDE_DIR/commands"
SKILLS_DIR="$CLAUDE_DIR/skills"
MANIFEST_FILE="$CLAUDE_DIR/.installed-profile"
KIT_LOCK="$CLAUDE_DIR/.kit-lock"
STANDARDS_FILE="$SCRIPT_DIR/base/standards.md"

if [ ! -f "$MANIFEST_FILE" ]; then
  echo "No installed profile found at $MANIFEST_FILE — nothing to check."
  exit 0
fi

# shellcheck disable=SC1090
source "$MANIFEST_FILE"

DRIFTED=0
MISSING=0
OK=0

# Locate a kit source file by basename across base/ and every profile.
find_source() {
  local kind="$1" base="$2" hit
  hit="$SCRIPT_DIR/base/$kind/$base"
  [ -f "$hit" ] && { echo "$hit"; return 0; }
  for p in "$SCRIPT_DIR"/profiles/*/"$kind"/"$base"; do
    [ -f "$p" ] && { echo "$p"; return 0; }
  done
  return 1
}

# Render what install.sh would write for an agent (expand {{STANDARDS}}).
render_agent() {
  local src="$1" out="$2"
  if grep -qF '{{STANDARDS}}' "$src"; then
    awk 'NR==FNR{gsub(/&/,"\\\\&"); standards=standards (NR>1?"\n":"") $0; next} {gsub(/\{\{STANDARDS\}\}/, standards); print}' "$STANDARDS_FILE" "$src" > "$out"
  else
    cp "$src" "$out"
  fi
}

check() {
  local label="$1" installed="$2" expected="$3" base
  base=$(basename "$installed")
  if [ ! -f "$installed" ]; then
    echo "  MISSING (not installed): $label/$base"; MISSING=$((MISSING+1)); return
  fi
  if [ ! -f "$expected" ]; then
    echo "  ORPHAN  (no kit source):  $label/$base"; DRIFTED=$((DRIFTED+1)); return
  fi
  if diff -q "$expected" "$installed" >/dev/null 2>&1; then
    OK=$((OK+1))
  else
    echo "  DRIFTED (edited locally): $label/$base — backport to the kit or it is lost on reinstall"
    DRIFTED=$((DRIFTED+1))
  fi
}

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "kit-doctor — checking installed profile '${PROFILE:-?}' against $SCRIPT_DIR"
echo ""

echo "Commands:"
for c in ${COMMANDS:-}; do
  if src=$(find_source commands "$c"); then
    check commands "$COMMANDS_DIR/$c" "$src"
  else
    check commands "$COMMANDS_DIR/$c" "/nonexistent"
  fi
done

echo "Agents:"
for a in ${AGENTS:-}; do
  if src=$(find_source agents "$a"); then
    render_agent "$src" "$TMP/$a"
    check agents "$AGENTS_DIR/$a" "$TMP/$a"
  else
    check agents "$AGENTS_DIR/$a" "/nonexistent"
  fi
done

# Skills: only SKILL.md is kit code; my-voice.md and samples/ are user data.
echo "Skills (SKILL.md only — user data ignored):"
for s in ${SKILLS:-}; do
  src="$SCRIPT_DIR/base/skills/$s/SKILL.md"
  check skills "$SKILLS_DIR/$s/SKILL.md" "$src"
done

# Revision check against the kit lock.
echo ""
echo "Revision:"
if [ -f "$KIT_LOCK" ]; then
  # shellcheck disable=SC1090
  LOCKED_SHA=$(sed -n 's/^KIT_SHA=//p' "$KIT_LOCK")
  HEAD_SHA=$(git -C "$SCRIPT_DIR" rev-parse HEAD 2>/dev/null || echo unknown)
  if [ "$LOCKED_SHA" = "$HEAD_SHA" ]; then
    echo "  in sync with kit HEAD (${HEAD_SHA:0:9})"
  else
    behind=$(git -C "$SCRIPT_DIR" rev-list --count "$LOCKED_SHA..$HEAD_SHA" 2>/dev/null || echo "?")
    echo "  installed ${LOCKED_SHA:0:9}, kit HEAD ${HEAD_SHA:0:9} — $behind kit commit(s) not yet installed (run ./install.sh)"
  fi
else
  echo "  no .kit-lock — install predates lock tracking; re-run ./install.sh to record provenance"
fi

echo ""
echo "Summary: $OK in sync, $DRIFTED drifted, $MISSING missing"
[ "$((DRIFTED + MISSING))" -eq 0 ] && exit 0 || exit 1
