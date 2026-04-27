#!/usr/bin/env just --justfile

# maven build without tests
clean-all-modules:
   #!/usr/bin/env bash
   source ${SDKMAN_DIR}/bin/sdkman-init.sh
   sdk env
   ./mvnw -f ./pom.xml clean
   ./mvnw -f ./testing/pom.xml clean

verify-all-modules:
   #!/usr/bin/env bash
   source ${SDKMAN_DIR}/bin/sdkman-init.sh
   sdk env
   ./mvnw -f ./pom.xml verify
   ./mvnw -f ./testing/pom.xml verify

clean-install-all-modules:
   #!/usr/bin/env bash
   source ${SDKMAN_DIR}/bin/sdkman-init.sh
   sdk env
   ./mvnw -f ./pom.xml clean install
   ./mvnw -f ./testing/pom.xml clean install

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
