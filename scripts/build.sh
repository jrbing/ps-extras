#!/usr/bin/env bash
#===============================================================================
# vim: softtabstop=2 shiftwidth=2 expandtab fenc=utf-8 spelllang=en ft=sh
#===============================================================================
#
#          FILE: build.sh
#
#         USAGE: ./build.sh
#
#===============================================================================

set -e          # Exit immediately on error
set -u          # Treat unset variables as an error
set -o pipefail # Prevent errors in a pipeline from being masked
IFS=$'\n\t'     # Set the internal field separator to a tab and newline

# shellcheck disable=2086
: ${MOCK_CONFIG:?"MOCK_CONFIG must be defined"}
# shellcheck disable=2086
: ${MOCK_PACKAGE:?"MOCK_PACKAGE must be defined"}

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
}

function run_docker_build() {
  echoinfo "Running docker build"
  docker run \
    --cap-add=SYS_ADMIN \
    --security-opt apparmor:unconfined \
    -e MOCK_CONFIG="${MOCK_CONFIG}" \
    -e MOCK_PACKAGE="${MOCK_PACKAGE}" \
    --volume /tmp/rpmbuild:/rpmbuild \
    jrbing/ps-extras
}

run_docker_build
