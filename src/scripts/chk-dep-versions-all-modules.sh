#!/usr/bin/env bash
set -euf -o pipefail

# Script to check for outdated Maven dependencies across multiple modules
# Usage: chk-dep-versions-all-modules.sh

# Establish the directory where scripts reside, used for relative path handling
SCRIPT_PATH="$(realpath "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(dirname "${SCRIPT_PATH}")"

# Include the utils
source "${SCRIPT_DIR}"/utils.sh

# Verify yq utility is available (needed for reading configs)
cmd_available yq

# Verify script is running in bash v5+
check_bash_version 5

# Establish the project root directory
PROJECT_ROOT="$(find_path_in_parent_chain ".git")"
log "DEBUG" "PROJECT_ROOT ==> ${PROJECT_ROOT}"

# Read configs
TOML_FILE="${PROJECT_ROOT}/project.toml"
[[ -f $TOML_FILE ]] || { echo "Error: $TOML_FILE file not found."; exit 1; }
#mapfile -t branches < <(yq '.branches[]' "$TOML_FILE")
mapfile -t poms < <(yq '.poms[]' "$TOML_FILE")

for pom in "${poms[@]}"; do
  "${SCRIPT_DIR}"/chk-dep-versions.sh "${pom}"
done

exit 0
