#!/usr/bin/env bash
# Add a skill entry to an avatar's "보유 skill" manifest. Idempotent.
# Two modes:
#   authored: update-manifest.sh <avatar> <skill> "<desc>"
#             -> "- /<avatar>-<skill> — <desc>"
#   attach:   update-manifest.sh --attach <avatar> <invocation> "<desc>"
#             -> "- <invocation> — <desc> (기존)"   (e.g. /doc-coauthoring, @agent-requirements-analyst)
# Removes the "- (없음)" placeholder on first add; creates the section if absent.
set -euo pipefail

MODE=authored
if [ "${1:-}" = "--attach" ]; then MODE=attach; shift; fi

AVATAR="${1:?avatar slug required}"
NAME="${2:?skill name / invocation required}"
DESC="${3:?description required}"

AGENT_FILE="${CLAUDE_HOME:-$HOME/.claude}/agents/${AVATAR}.md"
[ -f "$AGENT_FILE" ] || { echo "error: avatar not found: $AGENT_FILE" >&2; exit 1; }

if [ "$MODE" = attach ]; then
  ENTRY="- ${NAME} — ${DESC} (기존)"
  DEDUP="${NAME} —"
else
  ENTRY="- /${AVATAR}-${NAME} — ${DESC}"
  DEDUP="/${AVATAR}-${NAME} —"
fi

# Idempotent
if grep -qF "$DEDUP" "$AGENT_FILE"; then
  echo "already present: $DEDUP"
  exit 0
fi

# Ensure the section exists
if ! grep -q '^## 보유 skill' "$AGENT_FILE"; then
  printf '\n## 보유 skill\n' >> "$AGENT_FILE"
fi

tmp="$(mktemp)"
awk -v entry="$ENTRY" '
  /^## 보유 skill/ { print; insec=1; next }
  insec==1 && /^## /    { print entry; inserted=1; insec=0; print; next }
  insec==1 && $0 ~ /^-[[:space:]]*\(없음\)[[:space:]]*$/ { next }
  { print }
  END { if (insec==1 && !inserted) print entry }
' "$AGENT_FILE" > "$tmp"

mv "$tmp" "$AGENT_FILE"
echo "added: $ENTRY"
