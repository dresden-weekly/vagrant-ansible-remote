#!/bin/bash
set -e

# --- configuration defaults ---
ANSIBLE_VERSION=${ANSIBLE_VERSION:=1.8.2}
ANSIBLE_OPTIONS=${ANSIBLE_OPTIONS:=}

ANSIBLE_DIR=${ANSIBLE_DIR:=$ANSIBLE_PROJECT_FOLDER/.ansible}
SOURCE_ANSIBLE=true

# --- constants ---
RED='\033[0;31m'
GREEN='\033[0;33m'
NORMAL='\033[0m'

# --- remove mismatching version ---
if [ -f ${ANSIBLE_DIR}/VERSION ]; then
  if [ $(<${ANSIBLE_DIR}/VERSION) != $ANSIBLE_VERSION ]; then
    echo -e "${RED}Removing old Ansible version $(<${ANSIBLE_DIR}/VERSION)${NORMAL}"
    rm -rf ${ANSIBLE_DIR}
  fi
fi

if [ ! -d $ANSIBLE_DIR ]; then
  if [ "$USER" = "root" ]; then
    ROOT_PREFIX=""
  elif [ -z "$PS1" ]; then
    ROOT_PREFIX="sudo -n " #non interactive shell
  else
    ROOT_PREFIX="sudo "
  fi
  echo -e "${GREEN}Updating apt cache${NORMAL}"
  ${ROOT_PREFIX}apt-get update -qq
  echo -e "${GREEN}Installing Ansible dependencies and Git${NORMAL}"
  ${ROOT_PREFIX}apt-get install -y git python-yaml python-paramiko python-jinja2
  # echo "Install Ansible prerequisites:\nsudo apt-get install -y git python-yaml python-paramiko python-jinja2"

  echo -e "${GREEN}Cloning Ansible${NORMAL}"
  mkdir -p $ANSIBLE_DIR 2>/dev/null || GIT_PREFIX=$ROOT_PREFIX
  ${GIT_PREFIX}git clone --recurse-submodules --branch release$ANSIBLE_VERSION --depth 1 git://github.com/ansible/ansible.git $ANSIBLE_DIR
fi
