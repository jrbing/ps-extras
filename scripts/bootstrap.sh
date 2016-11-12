#!/usr/bin/env bash
#===============================================================================
# vim: softtabstop=2 shiftwidth=2 expandtab fenc=utf-8 spelllang=en ft=sh
#===============================================================================
#
#          FILE: bootstrap.sh
#
#         USAGE: ./bootstrap.sh
#
#===============================================================================

set -e          # Exit immediately on error
set -u          # Treat unset variables as an error
set -o pipefail # Prevent errors in a pipeline from being masked
IFS=$'\n\t'     # Set the internal field separator to a tab and newline

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

function create_buildroot() {
  echoinfo "Creating buildroot directory"
  mkdir -p /tmp/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS,tmp}
  cp specs/* /tmp/rpmbuild/SPECS/
  chown -R 1000:1000 /tmp/rpmbuild
}

function build_docker_image() {
  echoinfo "Building docker image"
  docker build -t jrbing/ps-extras .
}

function inspect_docker_image() {
  echoinfo "Inspecting docker image"
  docker inspect "jrbing/ps-extras"
}

function show_mock_version() {
  echoinfo "Getting mock version"
  docker run --rm "jrbing/ps-extras" /usr/bin/mock --version
}

##########
#  Main  #
##########

create_buildroot
build_docker_image
inspect_docker_image
show_mock_version
