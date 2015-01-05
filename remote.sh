#!/bin/bash
set -e

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

# --- option defaults ---
ANSIBLE_PROJECT_FOLDER=${ANSIBLE_PROJECT_FOLDER:=$PROJECT_FOLDER/ansible}

# --- resolve arguments ---
source $PROJECT_FOLDER/$VAGRANT_ANSIBLE_REMOTE/ansible/run-args.sh

# --- vagrant invocation ---
if [ ! "$VAGRANT_INVOKED" == true ] && [ "$ANSIBLE_RUN_VAGRANT" == true ]; then
  source $PROJECT_FOLDER/$VAGRANT_ANSIBLE_REMOTE/vagrant/ssh-ansible.sh
  exit 0
fi

# --- direct invocation ---
source $PROJECT_FOLDER/ansible/install.sh
source $PROJECT_FOLDER/ansible/run.sh
