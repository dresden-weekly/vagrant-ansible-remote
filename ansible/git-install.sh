#!/bin/bash
set -e

ANSIBLE_VERSION=${ANSIBLE_VERSION:=1.8.2}
ANSIBLE_OPTIONS=${ANSIBLE_OPTIONS:=}

ANSIBLE_DIR=${ANSIBLE_DIR:=$HOME/ansible}
export ANSIBLE_ROLES_PATH=${ANSIBLE_ROLES_PATH:=$ANSIBLE_DIR/roles}

RED='\033[0;31m'
GREEN='\033[0;33m'
NORMAL='\033[0m'

if [ -f ${ANSIBLE_DIR}/VERSION ]; then
  if [ $(<${ANSIBLE_DIR}/VERSION) != $ANSIBLE_VERSION ]; then
    echo -e "${RED}Removing old Ansible version $(<${ANSIBLE_DIR}/VERSION)${NORMAL}"
    rm -rf ${ANSIBLE_DIR}
  fi
fi

if [ ! -d $ANSIBLE_DIR ]; then
  if [ "$USER" = "root" ]; then
    echo -e "${GREEN}Updating apt cache${NORMAL}"
    apt-get update -qq
    echo -e "${GREEN}Installing Ansible dependencies and Git${NORMAL}"
    apt-get install -y git python-yaml python-paramiko python-jinja2
  else
    echo "Install Ansible prerequisites:\nsudo apt-get install -y git python-yaml python-paramiko python-jinja2"
  fi
  echo -e "${GREEN}Cloning Ansible${NORMAL}"
  git clone --recurse-submodules --branch release$ANSIBLE_VERSION --depth 1 git://github.com/ansible/ansible.git $ANSIBLE_DIR
fi
