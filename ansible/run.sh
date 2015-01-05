#!/bin/bash
set -e

# --- configuration options defaults ---
ANSIBLE_OPTIONS=${ANSIBLE_OPTIONS:=} # additional options

ANSIBLE_PROJECT_FOLDER=${ANSIBLE_PROJECT_FOLDER:=`pwd`}
ANSIBLE_ROLEFILE=${ANSIBLE_ROLEFILE:=$ANSIBLE_PROJECT_FOLDER/Rolefile}
ANSIBLE_ROLES_PATH=${ANSIBLE_ROLES_PATH:=$ANSIBLE_PROJECT_FOLDER/.roles}
ANSIBLE_TMP_HOSTS=${ANSIBLE_TMP_HOSTS:=/tmp/ansible_hosts}

ANSIBLE_RUN_VAGRANT=${ANSIBLE_RUN_VAGRANT:=false}
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

# --- vagrant invocation ---
if [ ! "$VAGRANT_INVOKED" == true ] && [ "$ANSIBLE_RUN_VAGRANT" == true ]; then
  source $VAGRANT_ANSIBLE_REMOTE/vagrant/ssh-ansible.sh
  exit 0
fi

# --- copy the hosts to tmp file ---
# Windows shares default to executable
# Ansible does not like this
if [ -x "$ANSIBLE_RUN_HOSTS" ]; then
  cp $ANSIBLE_RUN_HOSTS $ANSIBLE_TMP_HOSTS
  chmod -x $ANSIBLE_TMP_HOSTS
else
  ANSIBLE_TMP_HOSTS=$ANSIBLE_RUN_HOSTS
fi

# --- use non system Ansible ---
if [ "$SOURCE_ANSIBLE" = "true" ]; then
  ANSIBLE_DIR=${ANSIBLE_DIR:=$HOME/ansible} # folder where ansible is installed
  echo -e "${GREEN}Using Ansible from ${ANSIBLE_DIR} v$(cat $ANSIBLE_DIR/VERSION)${NORMAL}"
  cd $ANSIBLE_DIR # switch folder otherwise vagrant folder might not work
  source ${ANSIBLE_DIR}/hacking/env-setup
fi

# --- use ansible-galaxy Rolefile ---
if [ -f $ANSIBLE_ROLEFILE ]; then
  echo -e "${GREEN}Using Rolefile${NORMAL}"
  if [ ! -d $ANSIBLE_ROLES_PATH ]; then
    mkdir -p $ANSIBLE_ROLES_PATH
  fi
  export ANSIBLE_ROLES_PATH=$ANSIBLE_ROLES_PATH
  ansible-galaxy install --role-file=$ANSIBLE_ROLEFILE --force
fi

# --- run ---
echo -e "${GREEN}Running Ansible${NORMAL}"
export PROVISION_ARGS=$ANSIBLE_RUN_PROVISION_ARGS
ansible-playbook $ANSIBLE_OPTIONS $ANSIBLE_RUN_PLAYBOOK --inventory-file=$ANSIBLE_TMP_HOSTS

# --- clean up ---
if [ -x "$ANSIBLE_RUN_HOSTS" ]; then
  rm $ANSIBLE_TMP_HOSTS
fi
