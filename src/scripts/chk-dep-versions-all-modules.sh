#!/usr/bin/env bash

set -euf -o pipefail

# Script to check for outdated Maven dependencies
# Usage: ./chk-dep-versions-all-modules.sh

# ---------- Configuration ----------
source .cfg
# -----------------------------------

for module in "${module_roots[@]}"; do
  ./src/scripts/chk-dep-versions.sh "$module"
done

exit 0
# ---------------------------------------
