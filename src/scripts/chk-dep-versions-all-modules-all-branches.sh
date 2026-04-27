#!/usr/bin/env bash
set -euf -o pipefail

# Script to check for outdated Maven dependencies
# Usage: ./chk-dep-versions-all-modules-all-branches.sh

# ---------- Configuration ----------
branches=("jdk8" "jdk11" "jdk17" "jdk21" "jdk25" "jdk26" "main")
# -----------------------------------

# ---------- Helper functions ----------
log() {
  local level="$1"
  shift
  printf "[%s] %s: %s\n" "$(date +'%Y-%m-%d %H:%M:%S')" "$level" "$*"
}

checkout_branch() {
  local branch="$1"
  log "INFO" "Checking out $branch"
  git checkout "$branch"
}


# ---------------------------------------

for branch in "${branches[@]}"; do
  printf "\n\n\n\n"
  log "INFO" "===   🌿   Processing $branch branch   🌿   ==="
  checkout_branch "$branch"

  ./src/scripts/chk-dep-versions-all-modules.sh
done

log "INFO" "✅ All branch operations completed successfully"

exit 0
# ---------------------------------------
