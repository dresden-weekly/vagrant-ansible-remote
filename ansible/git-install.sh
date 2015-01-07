#!/bin/bash
# This script installs Ansible directly from Github
set -e

# configuration options
# =====================
#
# ANSIBLE_PROJECT_FOLDER (default: "$(pwd)")
#   absolute base folder for the default ansible folders
# ANSIBLE_DIR (default: "$ANSIBLE_PROJECT_FOLDER/.ansible")
#   absolute folder path for the custom Ansible installation
# ANSIBLE_VERSION (default: "1.8.2" - the latest)
#   Version of Ansible that is used
#   Should match the content of the VERSION file or Ansible will be reinstalled
# ANSIBLE_GIT_REPO (default: "git://github.com/ansible/ansible.git")
#   Git repository to use
# ANSIBLE_GIT_BRANCH (default: "release$ANSIBLE_VERSION")
#   Git branch of the Ansible repository
#
# outputs/changes
# ===============
#
# SOURCE_ANSIBLE=true use the custom installation

# --- configuration defaults ---
ANSIBLE_PROJECT_FOLDER=${ANSIBLE_PROJECT_FOLDER:=$(pwd)}
ANSIBLE_DIR=${ANSIBLE_DIR:=$ANSIBLE_PROJECT_FOLDER/.ansible}
ANSIBLE_VERSION=${ANSIBLE_VERSION:=1.8.2}
ANSIBLE_GIT_REPO=${ANSIBLE_GIT_REPO:=git://github.com/ansible/ansible.git}
ANSIBLE_GIT_BRANCH=${ANSIBLE_GIT_BRANCH:=release$ANSIBLE_VERSION}

# --- constants ---
RED='\033[0;31m'
GREEN='\033[0;33m'
NORMAL='\033[0m'

# --- functions ---
function with_root {
  if [ "$USER" = "root" ]; then
    $@
  elif [ -z "$PS1" ]; then
    # non interactive shell
    sudo -n $@
  else
    sudo $@
  fi
}

function apt_get_update {
  if [ "$(date +%F-%H)" != "date -r /var/lib/apt/periodic/update-success-stamp +%F-%H" ]; then
    echo -e "${GREEN}Updating apt cache${NORMAL}"
    with_root apt-get update -qq
  fi
}

# --- remove mismatching version ---
if [ -f ${ANSIBLE_DIR}/VERSION ]; then
  if [ $(<${ANSIBLE_DIR}/VERSION) != $ANSIBLE_VERSION ]; then
    echo -e "${RED}Removing old Ansible version $(<${ANSIBLE_DIR}/VERSION)${NORMAL}"
    rm -rf ${ANSIBLE_DIR}
  fi
fi

# --- install ---
if [ ! -d $ANSIBLE_DIR ]; then
  apt_get_update

  echo -e "${GREEN}Installing Ansible dependencies and Git${NORMAL}"
  with_root apt-get install -y git python-yaml python-paramiko python-jinja2 sshpass

  echo -e "${GREEN}Cloning Ansible${NORMAL}"
  mkdir -p $ANSIBLE_DIR 2>/dev/null || GIT_PREFIX="with_root "
  with_root git clone --recurse-submodules --branch $ANSIBLE_GIT_BRANCH --depth 1 $ANSIBLE_GIT_REPO $ANSIBLE_DIR
fi

SOURCE_ANSIBLE=true
