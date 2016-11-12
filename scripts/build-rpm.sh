#!/usr/bin/env bash
#===============================================================================
# vim: softtabstop=2 shiftwidth=2 expandtab fenc=utf-8 spelllang=en ft=sh
#===============================================================================
#
#          FILE: build-rpm.sh
#
#         USAGE: ./build-rpm.sh
#
#===============================================================================

set -e          # Exit immediately on error
set -u          # Treat unset variables as an error
set -o pipefail # Prevent errors in a pipeline from being masked
IFS=$'\n\t'     # Set the internal field separator to a tab and newline

readonly MOCK_BIN=/usr/bin/mock
readonly MOCK_BASE=/rpmbuild
readonly SPECDIR="$MOCK_BASE/SPECS"
readonly SRPMSDIR="$MOCK_BASE/SRPMS"
readonly SOURCEDIR="$MOCK_BASE/SOURCES"
readonly RPMSDIR="$MOCK_BASE/RPMS"
readonly CACHEDIR="$MOCK_BASE/cache/mock"

# shellcheck disable=2086
: ${MOCK_CONFIG:?"MOCK_CONFIG must be defined"}
# shellcheck disable=2086
: ${MOCK_PACKAGE:?"MOCK_PACKAGE must be defined"}

readonly SPECFILEPATH="${SPECDIR}/${MOCK_PACKAGE}".spec

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

function download_spec_source() {
  echoinfo "Downloading source files"
  spectool --get-files \
    --sourcedir \
    --force \
    "$SPECFILEPATH"
}

function initialize_mock_chroot() {
  echoinfo "Initializing mock chroot"
  $MOCK_BIN --root="$MOCK_CONFIG" \
    --init
}

function install_spec_dependencies() {
  echoinfo "Installing dependencies to chroot"
  $MOCK_BIN --root="$MOCK_CONFIG" \
    --install openssl-devel boost libxml2-devel
}

function create_source_rpm() {
  echoinfo "Creating source rpm"
  $MOCK_BIN --root="$MOCK_CONFIG" \
    --buildsrpm \
    --spec="$SPECFILEPATH" \
    --sources="$SOURCEDIR" \
    --resultdir="$SRPMSDIR" \
    --no-cleanup-after
}

function build_rpm() {
  echoinfo "Building rpm"
  # shellcheck disable=2155
  local source_rpm=$(find $SRPMSDIR -type f -name "*.src.rpm")
  $MOCK_BIN --root="${MOCK_CONFIG}" \
    --rebuild "$source_rpm" \
    --resultdir="$RPMSDIR" \
    --no-clean
}

function cleanup_before_exit () {
  echoinfo "Cleaning up"
}
trap cleanup_before_exit EXIT

##########
#  Main  #
##########
download_spec_source
initialize_mock_chroot
install_spec_dependencies
create_source_rpm
build_rpm
