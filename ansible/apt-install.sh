#!/bin/bash
# This script installs Ansible with Apt
set -e

# configuration options
# =====================
#
# ANSIBLE_PPA (default: "ansible/ansible")

# --- configuration defaults ---
ANSIBLE_PPA=${ANSIBLE_PPA:=ansible/ansible}

# --- constants ---
GREEN='\033[0;32m'
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

# -- make sure ppa is present ---
if [ ! -f "/etc/apt/sources.list.d/${ANSIBLE_PPA//\//-}-$(lsb_release -sc).list" ]; then
  # -- make sure apt-add-repository is present --
  if [ -z "$(which apt-add-repository)" ]; then
    echo -e "${GREEN}Installing software-properties${NORMAL}"
    apt_get_update
    with_root apt-get install -y software-properties-common
  fi
  echo -e "${GREEN}Adding Ansible ppa${NORMAL}"
  with_root apt-add-repository -y ppa:$ANSIBLE_PPA >/dev/null 2>&1
  with_root apt-get update -qq # forced update
else
  apt_get_update
fi

# -- install changes --
if [ ! -z "$(apt-get -qq -s -o=APT::Get::Show-User-Simulation-Note=no install ansible)" ]; then
  echo -e "${GREEN}Installing Ansible${NORMAL}"
  with_root apt-get install -y ansible
fi
