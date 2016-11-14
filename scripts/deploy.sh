#!/usr/bin/env bash
# shellcheck disable=2086
#===============================================================================
# vim: softtabstop=2 shiftwidth=2 expandtab fenc=utf-8 spelllang=en ft=sh
#===============================================================================
#
#          FILE: deploy.sh
#
#   DESCRIPTION: Upload the generated packages to packagecloud.io
#
#===============================================================================

set -e          # Exit immediately on error
set -u          # Treat unset variables as an error
set -o pipefail # Prevent errors in a pipeline from being masked
IFS=$'\n\t'     # Set the internal field separator to a tab and newline

: ${OS:?"OS must be defined"}
: ${DIST:?"DIST must be defined"}
: ${PACKAGE:?"PACKAGE must be defined"}
: ${PACKAGECLOUD_USER:?"PACKAGECLOUD_USER must be defined"}
: ${PACKAGECLOUD_REPO:?"PACKAGECLOUD_REPO must be defined"}
: ${PACKAGECLOUD_TOKEN:?"PACKAGECLOUD_TOKEN must be defined"}

readonly BUILDDIR="/tmp/rpmbuild/OUTPUT"

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

function show_package_summary() {
  echo
  echo '-----------------------------------------------------------'
  echo "Package:          ${PACKAGE}"
  echo "OS:               ${OS}"
  echo "OS Release:       ${RELEASE}"
  echo "PackageCloud:     ${PACKAGECLOUD_REPO}"
  echo '-----------------------------------------------------------'
  echo
}

function install_packagecloud_gem() {
  echoinfo "Installing packagecloud gem"
  gem install package_cloud
}

function deploy_package() {
  echoinfo "Exporting packages to packagecloud.io repo ${PACKAGECLOUD_REPO}"
  if [[ "${OS}" == "centos" ]] || [[ "${OS}" == "rhel" ]]; then
    echoinfo "Deploying RHEL/CentOS package"
    package_cloud push ${PACKAGECLOUD_USER}/${PACKAGECLOUD_REPO}/el/${DIST}/ \
      ${BUILDDIR}/*[!src].rpm --skip-errors
  elif [[ "${OS}" == "ol" ]]; then
    echoinfo "Deploying Oracle Linux package"
    package_cloud push ${PACKAGECLOUD_USER}/${PACKAGECLOUD_REPO}/ol/${DIST}/ \
      ${BUILDDIR}/*[!src].rpm --skip-errors
  else
    echoerror "Could not deploy for operating system ${OS}"
  fi
}

show_package_summary
install_packagecloud_gem
deploy_package
