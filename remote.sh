#!/bin/bash
set -e

# configuration options
# =====================
#
# PROJECT_FOLDER (default: "$(pwd)")
#   Absolute path of the Project (containing the Vagrantfile)
# VAGRANT_ANSIBLE_REMOTE (default: "vagrant_ansible_remote")
#   Relative path of vagrant-ansible-remote to the project
# ANSIBLE_PROJECT_FOLDER (default: "$PROJECT_FOLDER/ansible")
#   absolute base folder for the default ansible folders
# VAGRANT_INVOKED (default: false)
#   flag whether this script was invoked through Vagrant
#   inhibits recursive invokation

# --- option defaults ---
PROJECT_FOLDER=${PROJECT_FOLDER:=$(pwd)}
VAGRANT_ANSIBLE_REMOTE=${VAGRANT_ANSIBLE_REMOTE:=vagrant_ansible_remote}
ANSIBLE_PROJECT_FOLDER=${ANSIBLE_PROJECT_FOLDER:=$PROJECT_FOLDER/ansible}
VAGRANT_INVOKED=${VAGRANT_INVOKED:=false}
DOCKER_INVOKED=${DOCKER_INVOKED:=false}

# --- contstants ---
RED='\033[0;31m'
NORMAL='\033[0m'

# --- check environment ---
if [ -z "$PROJECT_FOLDER" ] || [ ! -d "$PROJECT_FOLDER" ]; then
  echo -e "${RED}PROJECT_FOLDER is not valid${NORMAL}"
  exit 20
fi
if [ -z "$VAGRANT_ANSIBLE_REMOTE" ] || [ ! -d "$PROJECT_FOLDER/$VAGRANT_ANSIBLE_REMOTE" ]; then
  echo -e "${RED}VAGRANT_ANSIBLE_REMOTE is not valid${NORMAL}"
  exit 21
fi

# --- load customization ---
if [ -f "$PROJECT_FOLDER/.remote.sh" ]; then
  source "$PROJECT_FOLDER/.remote.sh"
fi

# --- resolve arguments ---
source $PROJECT_FOLDER/$VAGRANT_ANSIBLE_REMOTE/ansible/run-args.sh

# --- vagrant invocation ---
if [ ! "$DOCKER_INVOKED" == true ] && [ ! "$VAGRANT_INVOKED" == true ] && [ "$ANSIBLE_RUN_VAGRANT" == true ]; then
  source $PROJECT_FOLDER/$VAGRANT_ANSIBLE_REMOTE/vagrant/ssh-ansible.sh
  exit 0
fi

# --- docker invocation ---
if [ ! "$DOCKER_INVOKED" == true ] && [ ! "$VAGRANT_INVOKED" == true ] && [ "$ANSIBLE_RUN_DOCKER" == true ]; then
  source $PROJECT_FOLDER/$VAGRANT_ANSIBLE_REMOTE/docker/run-ansible.sh
  exit 0
fi

# --- ansible installation ---
if [ ! "$DOCKER_INVOKED" == true ]; then
  if [ -s "$PROJECT_FOLDER/ansible/install.sh" ]; then
    source $PROJECT_FOLDER/ansible/install.sh
  else
    source $PROJECT_FOLDER/$VAGRANT_ANSIBLE_REMOTE/ansible/git-install.sh
  fi
fi

# --- ansible-vault invocation ---
if [ "$ANSIBLE_RUN_VAULT" == true ]; then
  if [ -s "$PROJECT_FOLDER/ansible/vault.sh" ]; then
    source $PROJECT_FOLDER/ansible/vault.sh
  else
    source $PROJECT_FOLDER/$VAGRANT_ANSIBLE_REMOTE/ansible/vault.sh
  fi
  exit 0
fi

# --- ansible-playbook invocation ---
if [ -s "$PROJECT_FOLDER/ansible/run.sh" ]; then
  source $PROJECT_FOLDER/ansible/run.sh
else
  source $PROJECT_FOLDER/$VAGRANT_ANSIBLE_REMOTE/ansible/run.sh
fi
