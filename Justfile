#!/usr/bin/env just --justfile

# maven build without tests
clean-all-modules:
   #!/usr/bin/env bash
   # Include the utils
   source src/scripts/utils.sh
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
   mapfile -t branches < <(yq '.branches[]' "$TOML_FILE")
   mapfile -t poms < <(yq '.poms[]' "$TOML_FILE")
   # Initialize SDKMAN once
   source ${SDKMAN_DIR}/bin/sdkman-init.sh
   sdk env
   for pom in "${poms[@]}"; do
      ./mvnw -f ./pom.xml clean
   done

verify-all-modules:
   #!/usr/bin/env bash
   # Include the utils
   source src/scripts/utils.sh
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
   mapfile -t branches < <(yq '.branches[]' "$TOML_FILE")
   mapfile -t poms < <(yq '.poms[]' "$TOML_FILE")
   # Initialize SDKMAN once
   source ${SDKMAN_DIR}/bin/sdkman-init.sh
   sdk env
   for pom in "${poms[@]}"; do
      ./mvnw -f ./pom.xml verify
   done

clean-install-all-modules:
   #!/usr/bin/env bash
   # Include the utils
   source src/scripts/utils.sh
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
   mapfile -t branches < <(yq '.branches[]' "$TOML_FILE")
   mapfile -t poms < <(yq '.poms[]' "$TOML_FILE")
   # Initialize SDKMAN once
   source ${SDKMAN_DIR}/bin/sdkman-init.sh
   sdk env
   for pom in "${poms[@]}"; do
      ./mvnw -f ./pom.xml clean install
   done

update-project-all-branches:
   #!/usr/bin/env bash
   time ./src/scripts/update-project-all-branches.sh

chk-dep-version-all-modules:
   #!/usr/bin/env bash
   time ./src/scripts/chk-dep-versions-all-modules.sh

chk-dep-version-all-modules-branches:
   #!/usr/bin/env bash
   time ./src/scripts/chk-dep-versions-all-modules-all-branches.sh

build-with-docker:
   #!/usr/bin/env bash
   ./src/scripts/build-with-docker.sh
