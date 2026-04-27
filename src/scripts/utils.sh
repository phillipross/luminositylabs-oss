# === Utils shell script include file ===
# This include contains variables and functions for use inside shell scripts.  It can be included in a shell
# script with the "source" command.

# Initial declaration for the profile global variable.  It is initialized to an empty string and can be overridden by
# scripts that invoke functions which use profiles.
profiles=""

# ---------- Helper functions ----------

# Compare specified bash versions.
# Returns 0 if the first version is greater than or equal to the second version
# Returns 1 if the first version is less than the second version
version_ge() {
  local -a ver1 ver2
  IFS='.' read -ra ver1 <<< "$1"
  IFS='.' read -ra ver2 <<< "$2"

  local i v1 v2
  for ((i = 0; i < ${#ver1[@]} || i < ${#ver2[@]}; i++)); do
    v1="${ver1[i]:-0}"
    v2="${ver2[i]:-0}"

    # Extract leading numeric portion
    [[ "$v1" =~ ^([0-9]+) ]] && v1="${BASH_REMATCH[1]}" || v1=0
    [[ "$v2" =~ ^([0-9]+) ]] && v2="${BASH_REMATCH[1]}" || v2=0

    if (( 10#${v1} > 10#${v2} )); then return 0; fi
    if (( 10#${v1} < 10#${v2} )); then return 1; fi
  done
  return 0
}

# Error out if the current bash version is lower than the specified version
check_bash_version() {
  local _min_bash_version="$1"
  local _bash_version="${BASH_VERSION}"
  if ! version_ge "${_bash_version}" "${_min_bash_version}"; then
    echo "Error: Bash version ${_min_bash_version}+ required, found ${_bash_version}" >&2
    exit 1
  fi
}

# Recursively search for a path within the parent/ancestor directories of the specified starting path
find_path_in_parent_chain() {
  local target_file="$1"
  local start_dir="${2:-$PWD}"

  local current="$start_dir"

  while true; do
        # Check if the file exists directly in current directory
        if [[ -e "$current/$target_file" ]]; then
            echo "$(cd "$current" && pwd)"
            return 0
        fi

        # If we've reached root, stop searching
        if [[ "$current" == "/" ]]; then
            break
        fi

        # Move to parent directory
        current=$(dirname "$current")
  done

  return 1
}

# Log a message to the specified level
log() {
  local level="$1"
  shift
  printf "[%s] %s: %s\n" "$(date +'%Y-%m-%d %H:%M:%S')" "$level" "$*"
}

# Initialize sdkman
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

# Fetch branches and tags from all remotes, and prune ones that no longer exist
fetch_remotes() {
  log "INFO" "Fetching updates from remotes"
  git fetch --all --tags --prune
}

# Checkout the specified branch (if it's not already checked out as the current branch)
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

# Check if the specified remote contains the specified branch
branch_exists_on_remote() {
  local remote="$1"
  local branch="$2"
  git ls-remote --heads "$remote" "$branch" | grep -q "refs/heads/$branch"
}

# Synchronize the specified branch by:
# 1. Pulling the corresponding branch from the upstream remote (if the branch exists on the upstream remote)
# 2. Pushing the branch to the origin remote (if the branch exists on the origin remote)
# 3. Pulling the branch from the origin remote (if the branch exists on the origin remote)
sync_branch() {
  local branch="$1"
  # Only sync upstream to origin if the branch exists on the upstream remote
  if branch_exists_on_remote "upstream" "$branch"; then
    log "INFO" "Pulling $branch branch from upstream remote"
    git pull upstream "$branch"
    if branch_exists_on_remote "origin" "$branch"; then
      log "INFO" "Pushing $branch branch to origin remote"
      git push origin "$branch"
    else
      log "WARN" "The $branch branch wasn't found on origin remote, skipping sync to origin"
    fi
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

# Iterate through the specified array parameter of pom.xml paths, invoking maven `clean install` on each
build_project() {
  local _profiles="$1"
  shift
  local -a _poms=("$@")
  for _pom in "${_poms[@]}"; do
    log "INFO" "Running Maven for module root ${_pom} with profiles ${_profiles}"
    ./mvnw -f "${_pom}" -P"${_profiles}" clean install
  done
}

# Iterate through the specified array parameter of pom.xml paths, invoking maven `clean` on each
clean_project() {
  local _profiles="$1"
  shift
  local -a _poms=("$@")
  for _pom in "${_poms[@]}"; do
    log "INFO" "Running Maven for module root ${_pom} with profiles ${_profiles}"
    ./mvnw -f "${_pom}" -P"${_profiles}" clean
  done
}

# Check that the specified command is invocable
cmd_available() {
  local req_cmd="$1"
  # Check that the yq utility is in the path
  if ! command -v "$req_cmd" >/dev/null 2>&1; then
    log "ERROR" "Required '$1' util not installed, not in PATH, or otherwise not invocable."
    return 1
  fi
}
