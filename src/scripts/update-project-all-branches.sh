#!/usr/bin/env bash
set -euo pipefail

# ---------- Configuration ----------
module_roots=("." "testing/")
branches=("jdk8" "jdk11" "jdk17" "jdk21" "jdk25" "jdk26" "main")
profiles="check-versions,gpg,release-sign-artifacts,sonatype-central-portal-deployment,sonatype-central-snapshots,sonatype-releases,sonatype-snapshots,sonatype-staging"
# -----------------------------------

# ---------- Helper functions ----------
log() {
  local level="$1"
  shift
  printf "[%s] %s: %s\n" "$(date +'%Y-%m-%d %H:%M:%S')" "$level" "$*"
}

init_sdkman() {
  if [[ -z "${SDKMAN_DIR:-}" ]]; then
    export SDKMAN_DIR="$HOME/.sdkman"
  fi

  local init_file="${SDKMAN_DIR}/bin/sdkman-init.sh"

  if [[ ! -s "$init_file" ]]; then
    log "ERROR" "SDKMAN init script not found at $init_file"
    exit 1
  fi

  # Disable nounset while we source the init script (prevents ZSH_VERSION,
  # sdkman_curl_retry, etc. from triggering “unbound variable”).
  set +u
  # shellcheck source=/dev/null
  source "$init_file"
  set -u

  if ! command -v sdk >/dev/null 2>&1; then
    log "ERROR" "'sdk' command still not available after sourcing init script"
    exit 1
  fi
}

# Wrapper that runs any `sdk` sub‑command with nounset temporarily disabled.
run_sdk() {
  # Preserve the current shell options, then turn off nounset.
  set +u
  sdk "$@"
  # Restore the original strict mode.
  set -u
}

fetch() {
  log "INFO" "Fetching updates from remotes"
  git fetch --all --tags --prune
}

checkout_branch() {
  local branch="$1"
  local current_branch
  current_branch=$(git branch --show-current)

  if [[ "$current_branch" == "$branch" ]]; then
    log "INFO" "Branch '$branch' is already checked out, skipping checkout"
  fi

  log "INFO" "Checking out $branch"
  git checkout "$branch"
}

branch_exists_on_remote() {
  local remote="$1"
  local branch="$2"
  git ls-remote --heads "$remote" "$branch" | grep -q "refs/heads/$branch"
}

sync_branch() {
  local branch="$1"
  # Only sync upstream to origin if the branch exists on the upstream remote
  if branch_exists_on_remote "upstream" "$branch"; then
    log "INFO" "Pulling $branch branch from upstream remote"
    git pull upstream "$branch"
    log "INFO" "Pushing $branch branch to origin remote"
    git push origin "$branch"
  else
    log "WARN" "The $branch branch wasn't found on upstream remote, skipping sync to origin"
  fi
  # Only sync origin to local if the branch exists on the origin remote
  if branch_exists_on_remote "origin" "$branch"; then
    log "INFO" "Pulling $branch branch from origin remote"
    git pull origin "$branch"
  else
    log "WARN" "The $branch branch wasn't found on origin remote, skipping sync from origin"
  fi
}

build_project() {
  for module_root in "${module_roots[@]}"; do
    log "INFO" "Running Maven for module root ${module_root}"
    ./mvnw -f "${module_root}" -P${profiles} clean install
  done
}

clean_project() {
  for module_root in "${module_roots[@]}"; do
    log "INFO" "Running Maven for module root ${module_root}"
    ./mvnw -f "${module_root}" -P${profiles} clean
  done
}
# ---------------------------------------

# Initialize SDKMAN once
init_sdkman

# Fetch remotes to make sure local repo is current
fetch

# Check if a single branch parameter was provided
if [[ $# -gt 0 ]]; then
  single_branch="$1"
  log "INFO" "Single branch mode enabled for: $single_branch"
  branches=("$single_branch")
fi

for branch in "${branches[@]}"; do
  printf "\n\n\n\n"
  log "INFO" "===   🌿   Processing $branch branch   🌿   ==="
  checkout_branch "$branch"
  sync_branch "$branch"

  # Use the wrapper to avoid the "$2: unbound variable" problem.
  run_sdk env

  build_project
  clean_project
done

#if [[ $# -gt 0 ]]; then
#  log "INFO" "✅ Branch operations completed successfully for $single_branch"
#else
  log "INFO" "✅ All branch operations completed successfully"
#fi

exit 0
# ---------------------------------------
