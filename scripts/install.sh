#!/usr/bin/env bash
# Install (or update) the avatar-creator meta-skills into ~/.claude/skills/.
# Copies whole skill folders, so bundled scripts/ come along.
# Usage: scripts/install.sh [--dry-run]
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST="${CLAUDE_HOME:-$HOME/.claude}/skills"
SKILLS=(create-avatar define-role add-skill)

DRY=0
[ "${1:-}" = "--dry-run" ] && DRY=1

mkdir -p "$DEST"
for s in "${SKILLS[@]}"; do
  src="$REPO_ROOT/skills/$s"
  if [ ! -f "$src/SKILL.md" ]; then
    echo "error: missing $src/SKILL.md" >&2; exit 1
  fi
  if [ "$DRY" = 1 ]; then
    echo "would install: $s -> $DEST/$s"
  else
    rm -rf "${DEST:?}/$s"
    cp -R "$src" "$DEST/$s"
    chmod +x "$DEST/$s/scripts/"*.sh 2>/dev/null || true
    echo "installed: $s -> $DEST/$s"
  fi
done
