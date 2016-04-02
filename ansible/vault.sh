#!/bin/bash
# This script runs Ansible Vault
set -e

# configuration options
# =====================
#
# ANSIBLE_PROJECT_FOLDER (default: "$(pwd)")
#   absolute base folder for the default ansible folders
# SOURCE_ANSIBLE (default: false)
#   flag whether custom Ansible installation should be sourced
# ANSIBLE_DIR (default: "$ANSIBLE_PROJECT_FOLDER/.ansible")
#   absolute folder path for the custom Ansible installation
#
# parameters
# ==========
#
# ANSIBLE_RUN_VAULT_ARGS
#   arguments for the vault

# --- configuration options defaults ---
ANSIBLE_PROJECT_FOLDER=${ANSIBLE_PROJECT_FOLDER:=$(pwd)}
SOURCE_ANSIBLE=${SOURCE_ANSIBLE:=false}
ANSIBLE_DIR=${ANSIBLE_DIR:=$ANSIBLE_PROJECT_FOLDER/.ansible}

# --- parameter defaults ---
ANSIBLE_RUN_VAULT_ARGS=${ANSIBLE_RUN_VAULT_ARGS:=}

# --- constants ---
RED='\033[0;31m'
GREEN='\033[0;32m'
NORMAL='\033[0m'

# --- use non system Ansible ---
if [ "$SOURCE_ANSIBLE" == true ]; then
  echo -e "${GREEN}Using Ansible from ${ANSIBLE_DIR} v$(cat $ANSIBLE_DIR/VERSION)${NORMAL}"
  cd $ANSIBLE_DIR # switch folder otherwise vagrant folder might not work
  set +e
  source ${ANSIBLE_DIR}/hacking/env-setup
  set -e
fi

# --- run ---
echo -e "${GREEN}Running Ansible Vault${NORMAL}"
cd $ANSIBLE_PROJECT_FOLDER
pwd
echo "ansible-vault $ANSIBLE_RUN_VAULT_ARGS"
ansible-vault $ANSIBLE_RUN_VAULT_ARGS
