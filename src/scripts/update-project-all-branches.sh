#!/usr/bin/env bash
set -euf -o pipefail

# Script to update a project across multiple branches
# Usage: update-project-all-branches.sh [ <branch> ]

# Establish the directory where scripts reside, used for relative path handling
SCRIPT_PATH="$(realpath "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(dirname "${SCRIPT_PATH}")"

# Include the utils
source "${SCRIPT_DIR}"/utils.sh

# Verify script is running in bash v5+
check_bash_version 5

# Establish the project root directory
PROJECT_ROOT="$(find_path_in_parent_chain ".git")"
log "DEBUG" "PROJECT_ROOT ==> ${PROJECT_ROOT}"

# ---------- Configuration ----------
module_roots=("./pom.xml" "testing/pom.xml")
branches=("jdk8" "jdk11" "jdk17" "jdk21" "jdk25" "jdk26" "main")
profiles="check-versions,gpg,release-sign-artifacts,sonatype-central-portal-deployment,sonatype-central-snapshots,sonatype-releases,sonatype-snapshots,sonatype-staging"
# -----------------------------------

# Initialize SDKMAN once
init_sdkman

# Fetch remotes to make sure local repo is current
fetch_remotes

# Check if a single branch parameter was provided, and if so, reset the branches array to only this value
if [[ $# -gt 0 ]]; then
  single_branch="$1"
  log "INFO" "Single branch mode enabled for: $single_branch"
  branches=("$single_branch")
fi

for branch in "${branches[@]}"; do
  printf "\n\n\n\n"
  log "INFO" "===   🌿   Processing $branch branch   🌿   ==="
  checkout_branch "$branch"
  current_branch=$(git branch --show-current)
  sync_branch "$branch"

  # Use the wrapper to avoid the "$2: unbound variable" problem.
  run_sdk env

  build_project "${profiles}" "${module_roots[@]}"
  clean_project "${profiles}" "${module_roots[@]}"

  log "INFO" "✅ Branch operations completed successfully for $current_branch"
done

log "INFO" "✅ All branch operations completed successfully"

exit 0
