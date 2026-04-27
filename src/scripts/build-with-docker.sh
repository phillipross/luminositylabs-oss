#!/usr/bin/env bash

set -euf -o pipefail

P=luminositylabs-oss                                       # project name
I=ghcr.io/luminositylabs/openjdk                           # image name
PF=check-versions,sonatype-snapshots,sonatype-staging,sonatype-releases,sonatype-central-snapshots   # maven profiles
S=".github/settings.xml"                                   # sonatype settings file
CBD="/usr/src/build"                                       # container directory

# java openjdk and zulu versions
J8VER="8u502" Z8VER="8.96.0.19"
J11VER="11.0.32" Z11VER="11.90.19"
J17VER="17.0.20" Z17VER="17.68.17"
J21VER="21.0.12" Z21VER="21.52.15"
J25VER="25.0.4" Z25VER="25.36.15"
J26VER="26.0.2" Z26VER="26.32.13"
# docker image tags
TAGS=(
#  "${J8VER}_zulu-${Z8VER}"
#  "${J8VER}_zulu-alpine-${Z8VER}"
#  "${J11VER}_zulu-${Z11VER}"
#  "${J11VER}_zulu-alpine-${Z11VER}"
#  "${J17VER}_zulu-${Z17VER}"
#  "${J17VER}_zulu-alpine-${Z17VER}"
#  "${J21VER}_zulu-${Z21VER}"
#  "${J21VER}_zulu-alpine-${Z21VER}"
  "${J25VER}_zulu-${Z25VER}"
  "${J25VER}_zulu-alpine-${Z25VER}"
#  "${J26VER}_zulu-${Z26VER}"
#  "${J26VER}_zulu-alpine-${Z26VER}"
)

GLOBAL_REPO_VOL="mvn-repo-vol" # This volume is a maven repo shared globally
printf "global mvn repo volume: %s\n" "${GLOBAL_REPO_VOL}"
PROJ_REPO_VOL="${P}-${GLOBAL_REPO_VOL}" # This volume is a maven repo shared only by the project
printf "project mvn repo volume: %s\n" "${PROJ_REPO_VOL}"

USE_REPO_TYPE=G # G=global P=project T=tag
USE_TEMP_VOL=false # set to "true" to have new volume created and removed after each build
for TAG in "${TAGS[@]}"; do
  printf "> Running with tag %s\n" "${TAG}"
  VOL="${GLOBAL_REPO_VOL}"
  case "${USE_REPO_TYPE}" in
    P) printf "   Using configured repo type [%s] ==> project volume: %s\n" "${USE_REPO_TYPE}" "${PROJ_REPO_VOL}"
      VOL="${PROJ_REPO_VOL}"
      ;;
    T) printf "   Using configured repo type [%s] ==> tag volumes\n" "${USE_REPO_TYPE}"
      VOL="${PROJ_REPO_VOL/${P}/${P}-${TAG}}"
      ;;
    G | *) printf "   Using configured repo type [%s] ==> global volume: %s\n" "${USE_REPO_TYPE}" "${GLOBAL_REPO_VOL}" ;;
  esac
  if [[ "${USE_TEMP_VOL}" == "true" ]]; then VOL="${VOL/mvn-repo-vol/$(date -u +%Y%m%d_%H%M%S_%s)}" ; fi
  printf "   Using volume %s \n" "${VOL}"

  docker container run --rm -it -v "$(pwd)":"${CBD}" -v ${VOL}:/root/.m2 -w "${CBD}" "${I}:${TAG}" ./mvnw -B -U -V -ntp -s ${S} -P${PF} dependency:list-repositories
  docker container run --rm -it -v "$(pwd)":"${CBD}" -v ${VOL}:/root/.m2 -w "${CBD}" "${I}:${TAG}" ./mvnw -B -U -V -ntp -s ${S} -P${PF} dependency:tree
  docker container run --rm -it -v "$(pwd)":"${CBD}" -v ${VOL}:/root/.m2 -w "${CBD}" "${I}:${TAG}" ./mvnw -B -U -V -ntp -s ${S} -P${PF} help:active-profiles clean install
  docker container run --rm -it -v "$(pwd)":"${CBD}" -v ${VOL}:/root/.m2 -w "${CBD}" "${I}:${TAG}" ./mvnw -B -U -V -ntp -s ${S} -P${PF} site site:stage
  docker container run --rm -it -v "$(pwd)":"${CBD}" -v ${VOL}:/root/.m2 -w "${CBD}" "${I}:${TAG}" ./mvnw -f ./testing -B -U -V -ntp -s ${S} -P${PF} -Djavadoc.path="/usr/bin/javadoc" dependency:list-repositories dependency:tree help:active-profiles clean install site site:stage
  if [[ "${USE_TEMP_VOL}" == "true" ]]; then docker volume rm "${VOL}" || true ; fi
done
