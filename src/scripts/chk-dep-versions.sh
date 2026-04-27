#!/usr/bin/env bash

set -euf -o pipefail

# Script to check for outdated Maven dependencies
# Usage: ./chk-dep-versions.sh [path-to-pom.xml]

POM_PATH="${1:-pom.xml}"
MVN_OUTPUT_TMP_FILE="maven-output.txt"
PROFILES="check-versions,sonatype-central-snapshots,sonatype-releases,sonatype-snapshots,sonatype-staging"

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

# Function to clean up temporary file
cleanup() {
    if [[ -f "$MVN_OUTPUT_TMP_FILE" ]]; then
        rm -f "$MVN_OUTPUT_TMP_FILE"
    fi
}
# ---------------------------------------

# Register cleanup function to be called on EXIT, INT, and TERM signals
trap cleanup EXIT INT TERM

# Check if POM file exists
[[ ! -f "$POM_PATH" ]] && { log "ERROR" "POM file not found at $POM_PATH"; exit 1; }

# Check if temporary file already exists and error out if the file does exist
[[ -f "$MVN_OUTPUT_TMP_FILE" ]] && { log "ERROR" "Temporary file $MVN_OUTPUT_TMP_FILE already exists. Refusing to overwrite."; exit 1; }

# Initialize SDKMAN once
init_sdkman

# Use the wrapper to avoid the "$2: unbound variable" problem.
run_sdk env

log "INFO" "Checking dependencies in $POM_PATH..."
log "INFO" "(Writing temporary output to $MVN_OUTPUT_TMP_FILE)"

# Run maven versions goals and pipe output to the temp file for processing later
./mvnw -f "${POM_PATH}" validate -P${PROFILES} >"$MVN_OUTPUT_TMP_FILE" 2>/dev/null

# Check if the command succeeded
[[ $? -ne 0 ]] && { log "ERROR" "Maven command failed"; rm -f "$MVN_OUTPUT_TMP_FILE"; exit 1; }

# Parse the output to find newer versions
log "INFO" "Checking for newer versions..."

# DEBUG print out the output
#echo "\n\n\n\n\n\n\n=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+="
#cat "$MVN_OUTPUT_TMP_FILE"
#echo "=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+="

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

# The following maven goals are run in the validate phase and produce respective output:
# ==> versions:display-parent-updates
# ==> versions:display-plugin-updates
# "The following plugin updates are available"
# "The following dependencies in pluginManagement of plugins have newer versions"
# "The following dependencies in Plugin Dependencies have newer versions"
# ==> versions:display-dependency-updates
# "The following dependencies in Dependency Management have newer versions"
# ==> versions:display-property-updates
# "The following version property updates are available"

