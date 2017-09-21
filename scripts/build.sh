#!/usr/bin/env bash
# shellcheck disable=2086
#===============================================================================
# vim: softtabstop=2 shiftwidth=2 expandtab fenc=utf-8 spelllang=en ft=sh
#===============================================================================
#
#          FILE: build.sh
#
#   DESCRIPTION: Run the docker container to generate the rpm packages
#
#===============================================================================

set -e          # Exit immediately on error
set -u          # Treat unset variables as an error
set -o pipefail # Prevent errors in a pipeline from being masked
IFS=$'\n\t'     # Set the internal field separator to a tab and newline

: ${OS:?"OS must be defined"}
: ${DIST:?"DIST must be defined"}
: ${PACKAGE:?"PACKAGE must be defined"}

readonly HOST_VOLUME_BUILDROOT="${HOME}/rpmbuild"
readonly CONTAINER_VOLUME_BUILDROOT="/rpmbuild"

###############
#  Functions  #
###############

function echoinfo() {
  local GC="\033[1;32m"
  local EC="\033[0m"
  printf "${GC} ☆  INFO${EC}: %s\n" "$@";
}

function echoerror() {
  local RC="\033[1;31m"
  local EC="\033[0m"
  printf "${RC} ✖  ERROR${EC}: %s\n" "$@" 1>&2;
  exit 1
}

function run_docker_build() {
  echoinfo "Running docker build"
  docker run \
    --cap-add=SYS_ADMIN \
    --security-opt apparmor:unconfined \
    --rm \
    -e OS="${OS}" \
    -e DIST="${DIST}" \
    -e PACKAGE="${PACKAGE}" \
    --volume "${HOST_VOLUME_BUILDROOT}":"${CONTAINER_VOLUME_BUILDROOT}" \
    jrbing/ps-extras
}

run_docker_build
