#!/usr/bin/env bash
set -euf -o pipefail

# Script to check for outdated Maven dependencies across multiple modules
# Usage: chk-dep-versions-all-modules.sh

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
module_roots=("pom.xml" "testing/pom.xml")
# -----------------------------------

for module in "${module_roots[@]}"; do
  "${SCRIPT_DIR}"/chk-dep-versions.sh "${module}"
done

exit 0
