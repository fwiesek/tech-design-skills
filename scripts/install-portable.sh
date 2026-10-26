#!/usr/bin/env bash
# Install the skills into a non-plugin skills folder (Codex, other agents, or ~/.claude/skills).
# Each skill is copied as tech-design-<skill> with its frontmatter name rewritten to match,
# so the generic names (start, refine, ...) cannot collide with other skills.
# Usage: scripts/install-portable.sh <skills-dir>   e.g. ~/.agents/skills
set -euo pipefail
target="${1:?usage: $0 <skills-dir>}"
root="$(cd "$(dirname "$0")/.." && pwd)"
"$root/scripts/sync-conventions.sh" --check
mkdir -p "$target"
for dir in "$root"/skills/*/; do
  skill="$(basename "$dir")"
  dest="$target/tech-design-$skill"
  rm -rf "$dest"
  cp -r "$dir" "$dest"
  sed -i.bak "0,/^name: .*/s//name: tech-design-$skill/" "$dest/SKILL.md" && rm "$dest/SKILL.md.bak"
  echo "installed: $dest"
done
