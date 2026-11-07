#!/usr/bin/env bash
# One-way mirror: canonical Hermes skill -> both repos (+commit+push).
# Canonical: ~/.hermes/skills/devops/mobile-app-dev
# Mirrors : hermes-skills devops/mobile-app-dev ; expo-skills skills/mobile-app-dev
# NEVER hand-edit mirrors; edit canonical then run: bash scripts/sync-repos.sh
set -euo pipefail

SRC="${SKILL_SRC:-$HOME/.hermes/skills/devops/mobile-app-dev}"
[ -d "$SRC" ] || { echo "canonical skill missing: $SRC" >&2; exit 1; }
MSG="sync mobile-app-dev $(date +%F)"

sync_repo() {
  local repo="$1" path="$2" extra="$3"
  (
    cd "$repo"
    rm -rf "$path"
    mkdir -p "$(dirname "$path")"
    cp -r "$SRC" "$path"
    if [ -n "$extra" ]; then
      grep -q 'mobile-app-dev' README.md || \
        sed -i '/^| \*\*react-native-dev\*\*/a | **mobile-app-dev** | `skills/mobile-app-dev/` (SKILL.md + references + scripts/sync-repos.sh) | ✅ Sak-verified lab-app workflow (EAS publish, Expo Go serving) |' README.md
    fi
    git add -- "$path" README.md 2>/dev/null || git add -- "$path"
    if git diff --quiet HEAD 2>/dev/null; then
      echo "  $repo: unchanged, skipped"
    else
      git commit -m "$MSG" >/dev/null
      git push origin HEAD
      echo "  $repo: pushed"
    fi
  ) || echo "  $repo: FAILED ($?)"
}

sync_repo /home/sak/hermes-skills devops/mobile-app-dev ""
sync_repo /home/sak/expo-skills skills/mobile-app-dev README
echo "sync-repos done."
