#!/bin/bash
set -e

RED='\033[0;31m'
NORMAL='\033[0m'

if [ -z "$PROJECT_FOLDER" ] || [ ! -d "$PROJECT_FOLDER" ]; then
  echo -e "${RED}PROJECT_FOLDER is not valid${NORMAL}"
  exit 20
fi
if [ -z "$VAGRANT_ANSIBLE_REMOTE" ] || [ ! -d $VAGRANT_ANSIBLE_REMOTE ]; then
  echo -e "${RED}VAGRANT_ANSIBLE_REMOTE is not valid${NORMAL}"
  exit 21
fi

ANSIBLE_PROJECT_FOLDER=${ANSIBLE_PROJECT_FOLDER:=$PROJECT_FOLDER/ansible}
ANSIBLE_DIR=${ANSIBLE_DIR:=/opt/ansible}
SOURCE_ANSIBLE=${SOURCE_ANSIBLE:=true}

# this script is always called in vagrant
VAGRANT_INVOKED=true

source $VAGRANT_ANSIBLE_REMOTE/ansible/run-args.sh

source $ANSIBLE_PROJECT_FOLDER/install.sh
source $ANSIBLE_PROJECT_FOLDER/run.sh
