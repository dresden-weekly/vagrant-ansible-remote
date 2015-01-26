#!/bin/bash
# This script installs Ansible Galaxy Roles and runs an Ansible Playbook
set -e

# configuration options
# =====================
#
# ANSIBLE_PROJECT_FOLDER (default: "$(pwd)")
#   absolute base folder for the default ansible folders
# ANSIBLE_PROJECT_ROLES (default: "$ANSIBLE_PROJECT_FOLDER/roles")
#   absolute folder path for project specific roles
# ANSIBLE_GALAXY_ROLEFILE (default: "$ANSIBLE_PROJECT_FOLDER/Rolefile")
#   absolute file path for the Ansible Galaxy Rolefile
#   if a ${ANSIBLE_GALAXY_ROLEFILE}.yml (new syntax) exists it is preferred!
#   Ansible Galaxy will only be used if the file is present
# ANSIBLE_GALAXY_ROLES (default: "$ANSIBLE_PROJECT_FOLDER/.roles")
#   absolute folder path where Ansible Galaxy will install the roles of the Rolefile
# SOURCE_ANSIBLE (default: false)
#   flag whether custom Ansible installation should be sourced
# ANSIBLE_DIR (default: "$ANSIBLE_PROJECT_FOLDER/.ansible")
#   absolute folder path for the custom Ansible installation
#
# parameters
# ==========
#
# ANSIBLE_OPTIONS
#   additional options for ansible
# ANSIBLE_RUN_HOSTS (default: "$ANSIBLE_PROJECT_FOLDER/hosts/default")
#   absolute path to the hosts file
# ANSIBLE_RUN_PLAYBOOK (default: "$ANSIBLE_PROJECT_FOLDER/provision.yml")
#   absolute path to the playbook
# ANSIBLE_RUN_PROVISION_ARGS
#   additional provision arguments
#
# outputs/changes
# ===============
#
# ANSIBLE_ROLES_PATH is exported
# PROVISION_ARGS is exported

# --- configuration options defaults ---
ANSIBLE_PROJECT_FOLDER=${ANSIBLE_PROJECT_FOLDER:=$(pwd)}
ANSIBLE_PROJECT_ROLES=${ANSIBLE_PROJECT_ROLES:=$ANSIBLE_PROJECT_FOLDER/roles}
ANSIBLE_GALAXY_ROLEFILE=${ANSIBLE_GALAXY_ROLEFILE:=$ANSIBLE_PROJECT_FOLDER/Rolefile}
ANSIBLE_GALAXY_ROLES=${ANSIBLE_GALAXY_ROLES:=$ANSIBLE_PROJECT_FOLDER/.roles}
SOURCE_ANSIBLE=${SOURCE_ANSIBLE:=false}
ANSIBLE_DIR=${ANSIBLE_DIR:=$ANSIBLE_PROJECT_FOLDER/.ansible}

# --- parameter defaults ---
ANSIBLE_OPTIONS=${ANSIBLE_OPTIONS:=}
ANSIBLE_RUN_HOSTS=${ANSIBLE_RUN_HOSTS:=$ANSIBLE_PROJECT_FOLDER/hosts/default}
ANSIBLE_RUN_PLAYBOOK=${ANSIBLE_RUN_PLAYBOOK:=$ANSIBLE_PROJECT_FOLDER/provision.yml}
ANSIBLE_RUN_PROVISION_ARGS=${ANSIBLE_RUN_PROVISION_ARGS:=}

# --- constants ---
RED='\033[0;31m'
GREEN='\033[0;32m'
NORMAL='\033[0m'

# --- checks files ---
if [ ! -s $ANSIBLE_RUN_HOSTS ]; then
  echo -e "${RED}Cannot find Ansible hosts $ANSIBLE_RUN_HOSTS${NORMAL}"
  exit 11
fi
if [ ! -s $ANSIBLE_RUN_PLAYBOOK ]; then
  echo -e "${RED}Cannot find Ansible playbook $ANSIBLE_RUN_PLAYBOOK${NORMAL}"
  exit 10
fi

# --- check hosts executable flags ---
# Windows/Vagrant shares default to executable
# Ansible will try to execute hosts files if they are executable
# Solution:
#   fix config.vm.synced_folder ".", "/vagrant", :mount_options => ["dmode=777","fmode=666"]
if [ -x "$ANSIBLE_RUN_HOSTS" ]; then
  echo -e "${RED}Warning:${NORMAL} $ANSIBLE_RUN_HOSTS is executable! Apply the following fix if this run fails."
  echo -e "   fix config.vm.synced_folder \".\", \"/vagrant\", :mount_options => [\"dmode=777\",\"fmode=666\"]"
fi

# --- use non system Ansible ---
if [ "$SOURCE_ANSIBLE" == true ]; then
  echo -e "${GREEN}Using Ansible from ${ANSIBLE_DIR} v$(cat $ANSIBLE_DIR/VERSION)${NORMAL}"
  cd $ANSIBLE_DIR # switch folder otherwise vagrant folder might not work
  source ${ANSIBLE_DIR}/hacking/env-setup
fi

# --- use ansible-galaxy Rolefile ---
if [ -r "${ANSIBLE_GALAXY_ROLEFILE}.yml" ]; then
  ANSIBLE_GALAXY_ROLEFILE="${ANSIBLE_GALAXY_ROLEFILE}.yml"
fi
ANSIBLE_ROLES_PATH=$ANSIBLE_PROJECT_ROLES
if [ -r "$ANSIBLE_GALAXY_ROLEFILE" ]; then
  echo -e "${GREEN}Using Rolefile${NORMAL}"
  ANSIBLE_ROLES_PATH=$ANSIBLE_ROLES_PATH:$ANSIBLE_GALAXY_ROLES
  if [ ! -d $ANSIBLE_GALAXY_ROLES ]; then
    mkdir -p $ANSIBLE_GALAXY_ROLES
    export ANSIBLE_ROLES_PATH=$ANSIBLE_ROLES_PATH
    ansible-galaxy install --role-file=$ANSIBLE_GALAXY_ROLEFILE
  fi
fi

# --- run ---
echo -e "${GREEN}Running Ansible${NORMAL}"
export ANSIBLE_ROLES_PATH=$ANSIBLE_ROLES_PATH
export PROVISION_ARGS=$ANSIBLE_RUN_PROVISION_ARGS
echo "ansible-playbook $ANSIBLE_OPTIONS $ANSIBLE_RUN_PLAYBOOK --inventory-file=$ANSIBLE_RUN_HOSTS"
ansible-playbook $ANSIBLE_OPTIONS $ANSIBLE_RUN_PLAYBOOK --inventory-file=$ANSIBLE_RUN_HOSTS
