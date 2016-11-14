#!/usr/bin/env bash
#===============================================================================
# vim: softtabstop=2 shiftwidth=2 expandtab fenc=utf-8 spelllang=en ft=sh
#===============================================================================
#
#          FILE: install.sh
#
#   DESCRIPTION: Creates the directory layout for the package build, copies the
#                spec files, and creates the docker container image to be used
#                for building the packages
#
#===============================================================================

set -e          # Exit immediately on error
set -u          # Treat unset variables as an error
set -o pipefail # Prevent errors in a pipeline from being masked
IFS=$'\n\t'     # Set the internal field separator to a tab and newline

###############
#  Variables  #
###############

readonly HOST_VOLUME_BUILDROOT="/tmp/rpmbuild"
readonly SPECDIR="$HOST_VOLUME_BUILDROOT/SPECS"
readonly SOURCEDIR="$HOST_VOLUME_BUILDROOT/SOURCES"
readonly CACHEDIR="$HOST_VOLUME_BUILDROOT/CACHE"
readonly OUTPUTDIR="$HOST_VOLUME_BUILDROOT/OUTPUT"

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
  mkdir -p "${SPECDIR}"
  mkdir -p "${SOURCEDIR}"
  mkdir -p "${CACHEDIR}"
  mkdir -p "${OUTPUTDIR}"
}

function modify_buildroot_ownership() {
  echoinfo "Modifying buildroot ownership"
  chown -R 1000:1000 "${HOST_VOLUME_BUILDROOT}"
}

function copy_spec_files() {
  echoinfo "Copying specfiles to buildroot"
  cp specs/* "${SPECDIR}/"
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
copy_spec_files
modify_buildroot_ownership
build_docker_image
inspect_docker_image
show_mock_version
