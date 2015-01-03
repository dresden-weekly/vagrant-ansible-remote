#!/bin/bash
set -e

RED='\033[0;31m'
NORMAL='\033[0m'

if [ -z "$BASE_FOLDER" ] || [ ! -d "$BASE_FOLDER" ]; then
  echo -e "${RED}BASE_FOLDER is not valid${NORMAL}"
  exit 20
fi
if [ -z "$VAGRANT_ANSIBLE_REMOTE" ] || [ ! -d $VAGRANT_ANSIBLE_REMOTE ]; then
  echo -e "${RED}VAGRANT_ANSIBLE_REMOTE is not valid${NORMAL}"
  exit 21
fi

ANSIBLE_BASE_FOLDER=${ANSIBLE_BASE_FOLDER:=$BASE_FOLDER/ansible}
ANSIBLE_DIR=${ANSIBLE_DIR:=/opt/ansible}
SOURCE_ANSIBLE=${SOURCE_ANSIBLE:=true}

source $ANSIBLE_BASE_FOLDER/install.sh
source $ANSIBLE_BASE_FOLDER/run.sh
