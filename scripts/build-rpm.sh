#!/usr/bin/env bash
# shellcheck disable=2086
#===============================================================================
# vim: softtabstop=2 shiftwidth=2 expandtab fenc=utf-8 spelllang=en ft=sh
#===============================================================================
#
#          FILE: build-rpm.sh
#
#   DESCRIPTION: Build the rpm within a docker container
#
#===============================================================================

set -e          # Exit immediately on error
set -u          # Treat unset variables as an error
set -o pipefail # Prevent errors in a pipeline from being masked
IFS=$'\n\t'     # Set the internal field separator to a tab and newline

: ${OS:?"OS must be defined"}
: ${DIST:?"DIST must be defined"}
: ${PACKAGE:?"PACKAGE must be defined"}

readonly MOCK_CONFIG="epel-${DIST}-x86_64"
readonly MOCK_BIN=/usr/bin/mock
readonly BUILDROOT=./build
#readonly BUILDROOT=/rpmbuild

readonly SPECDIR="$BUILDROOT/SPECS"
readonly SOURCEDIR="$BUILDROOT/SOURCES"
readonly CACHEDIR="$BUILDROOT/CACHE"
readonly OUTPUTDIR="$BUILDROOT/OUTPUT"
readonly SPECFILEPATH="${SPECDIR}/${PACKAGE}".spec

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

function copy_spec_files() {
  echoinfo "Copying spec files to buildroot"
  cp specs/* "${SPECDIR}/"
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
  # NOTE: we have to disregard the return code of this because of an incompatability
  #       issue with btrfs on versions earlier than CentOS 7
  set +e
  $MOCK_BIN --root="$MOCK_CONFIG" \
    --init
  set -e
}

function install_spec_dependencies() {
  echoinfo "Installing dependencies to chroot"
  #$MOCK_BIN --root="$MOCK_CONFIG" \
    #--install openssl-devel boost libxml2-devel ncurses-devel libevent-devel
  # shellcheck disable=2155
  local source_rpm=$(find $OUTPUTDIR -type f -name "*.src.rpm")
  $MOCK_BIN --root="$MOCK_CONFIG" \
    --installdeps "$source_rpm"
}

function create_source_rpm() {
  echoinfo "Creating source rpm"
  $MOCK_BIN --root="$MOCK_CONFIG" \
    --buildsrpm \
    --spec="$SPECFILEPATH" \
    --sources="$SOURCEDIR" \
    --resultdir="$OUTPUTDIR" \
    --no-cleanup-after
}

function build_rpm() {
  echoinfo "Building rpm"
  # shellcheck disable=2155
  local source_rpm=$(find $OUTPUTDIR -type f -name "*.src.rpm")
  $MOCK_BIN --root="${MOCK_CONFIG}" \
    --rebuild "$source_rpm" \
    --resultdir="$OUTPUTDIR" \
    --no-clean
}

##########
#  Main  #
##########
create_buildroot
copy_spec_files
download_spec_source
initialize_mock_chroot
create_source_rpm
install_spec_dependencies
build_rpm
