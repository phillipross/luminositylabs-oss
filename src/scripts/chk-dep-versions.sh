#!/usr/bin/env bash
set -euf -o pipefail

# Script to check for outdated Maven dependencies
# Usage: chk-dep-versions.sh [path-to-pom.xml]

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

POM_PATH="${1:-pom.xml}"
MVN_OUTPUT_TMP_FILE="maven-output.txt"
PROFILES="check-versions,sonatype-central-snapshots,sonatype-releases,sonatype-snapshots,sonatype-staging"

# ---------- Helper functions ----------

# Function to clean up temporary file
cleanup() {
    if [[ -f "$MVN_OUTPUT_TMP_FILE" ]]; then
        rm -f "$MVN_OUTPUT_TMP_FILE"
    fi
}
# ---------------------------------------

# Register cleanup function to be called on EXIT, INT, and TERM signals
trap cleanup EXIT INT TERM

# Check if POM file exists and error out if the file does exist
[[ ! -f "$POM_PATH" ]] && \
    { log "ERROR" "POM file not found at $POM_PATH"; exit 1; }

# Check if temporary file already exists and error out if the file does exist
[[ -f "$MVN_OUTPUT_TMP_FILE" ]] && \
    { log "ERROR" "Temporary file $MVN_OUTPUT_TMP_FILE already exists. Refusing to overwrite."; exit 1; }

# Initialize SDKMAN once
init_sdkman

# Use the wrapper to avoid the "$2: unbound variable" problem.
run_sdk env

log "INFO" "Checking dependencies in $POM_PATH..."
log "INFO" "(Writing temporary output to $MVN_OUTPUT_TMP_FILE)"

# Run maven versions goals and pipe output to the temp file for processing later
! ./mvnw -f "${POM_PATH}" validate -P${PROFILES} >"$MVN_OUTPUT_TMP_FILE" 2>/dev/null && \
    { log "ERROR" "Maven command failed"; rm -f "$MVN_OUTPUT_TMP_FILE"; exit 1; }

# Parse the output to find newer versions
log "INFO" "Checking for newer versions..."

# Extract and display from maven output: plugins with newer versions
log "INFO" "===== Plugins w/ newer versions ==================================="
awk 'BEGIN {s="The following plugin updates are available"; e="^\\[INFO\\] $"}
           {if (!found1) {if ($0 ~ s) {print $0; found1=1}} else {print $0; if ($0 ~ e) {found1=0}}}' < "$MVN_OUTPUT_TMP_FILE"
log "INFO" "========================================================"
echo

# Extract and display from maven output: dependencies with newer versions
log "INFO" "===== Dependencies w/ newer versions ==================================="
awk 'BEGIN {s="The.*newer"; e="^\\[INFO\\] $"}
           {if (!found1) {if ($0 ~ s) {print $0; found1=1}} else {print $0; if ($0 ~ e) {found1=0}}}' < "$MVN_OUTPUT_TMP_FILE"
log "INFO" "========================================================"
echo

# Extract and display from maven output: version properties with newer versions
log "INFO" "===== Version properties w/ newer versions ==================================="
awk 'BEGIN {s="The following version property updates are available"; e="^\\[INFO\\] $"}
           {if (!found1) {if ($0 ~ s) {print $0; found1=1}} else {print $0; if ($0 ~ e) {found1=0}}}' < "$MVN_OUTPUT_TMP_FILE"
log "INFO" "========================================================"
echo

log "INFO" "Dependency check complete."
