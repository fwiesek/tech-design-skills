#!/usr/bin/env bash
# Copy conventions/CONVENTIONS.md into every skill folder, so each skill stays standalone.
# --check: exit non-zero if any copy differs from the canonical file (use in CI / before commit).
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
src="$root/conventions/CONVENTIONS.md"
status=0
for dir in "$root"/skills/*/; do
  dest="${dir%/}/CONVENTIONS.md"
  if [[ "${1:-}" == "--check" ]]; then
    if ! cmp -s "$src" "$dest"; then
      echo "out of sync: ${dest#"$root"/}" >&2
      status=1
    fi
  else
    cp "$src" "$dest"
    echo "synced: ${dest#"$root"/}"
  fi
done
exit $status
