#!/usr/bin/env bash
# List skills/agents currently installed on this PC, for selecting which to attach
# to an avatar. Prints "invocation<TAB>kind<TAB>description".
#   - personal skills  -> /<name>        (kind: skill)
#   - plugin skills     -> /<name>        (kind: skill)
#   - subagents         -> @agent-<name>  (kind: agent)
# Deduplicates by invocation. Excludes the avatar-creator meta-skills themselves.
set -euo pipefail

HOME_DIR="${CLAUDE_HOME:-$HOME/.claude}"
EXCLUDE_RE='^(create-avatar|define-role|add-skill)$'

# field 1 of a SKILL.md/agent frontmatter: the `description:` value (first line only)
desc_of() {
  awk -F': ' '
    /^---$/ { c++; next }
    c==1 && /^description:/ { sub(/^description:[[:space:]]*/,""); print; exit }
  ' "$1" 2>/dev/null | cut -c1-140
}

emit() { printf '%s\t%s\t%s\n' "$1" "$2" "$3"; }

seen_file="$(mktemp)"
trap 'rm -f "$seen_file"' EXIT
mark() { grep -qxF "$1" "$seen_file" && return 1; echo "$1" >> "$seen_file"; return 0; }

# Skills: personal + plugins
while IFS= read -r f; do
  name="$(basename "$(dirname "$f")")"
  [[ "$name" =~ $EXCLUDE_RE ]] && continue
  mark "/$name" || continue
  emit "/$name" "skill" "$(desc_of "$f")"
done < <(
  find "$HOME_DIR/skills" -maxdepth 2 -name SKILL.md 2>/dev/null
  find "$HOME_DIR/plugins" -path '*/skills/*/SKILL.md' 2>/dev/null
)

# Agents: personal + plugins
while IFS= read -r f; do
  name="$(basename "$f" .md)"
  mark "@agent-$name" || continue
  emit "@agent-$name" "agent" "$(desc_of "$f")"
done < <(
  find "$HOME_DIR/agents" -maxdepth 1 -name '*.md' 2>/dev/null
  find "$HOME_DIR/plugins" -path '*/agents/*.md' 2>/dev/null
)
