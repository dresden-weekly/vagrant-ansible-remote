#!/bin/bash
set -e

ANSIBLE_OPTIONS=${ANSIBLE_OPTIONS:=} # additional options

ANSIBLE_BASE_FOLDER=${ANSIBLE_BASE_FOLDER:=`pwd`}
ANSIBLE_ROLEFILE=${ANSIBLE_ROLEFILE:=$ANSIBLE_BASE_FOLDER/Rolefile}
ANSIBLE_RUN_PLAYBOOK=${ANSIBLE_RUN_PLAYBOOK:=$ANSIBLE_BASE_FOLDER/provision.yml}
ANSIBLE_RUN_HOSTS=${ANSIBLE_RUN_HOSTS:=$ANSIBLE_BASE_FOLDER/hosts/vagrant}
ANSIBLE_RUN_PROVISION_ARGS=${ANSIBLE_RUN_PROVISION_ARGS:=}

ANSIBLE_TMP_HOSTS=${ANSIBLE_TMP_HOSTS:=/tmp/local_hosts}

RED='\033[0;31m'
GREEN='\033[0;32m'
NORMAL='\033[0m'

if [ ! -f $ANSIBLE_RUN_PLAYBOOK ]; then
  echo -e "${RED}Cannot find Ansible playbook $ANSIBLE_RUN_PLAYBOOK${NORMAL}"
  exit 10
fi

if [ ! -f $ANSIBLE_RUN_HOSTS ]; then
  echo -e "${RED}Cannot find Ansible hosts $ANSIBLE_RUN_HOSTS${NORMAL}"
  exit 11
fi

# copy the hosts file - vagrant files from windows have the wrong rights
cp $ANSIBLE_RUN_HOSTS $ANSIBLE_TMP_HOSTS && chmod -x $ANSIBLE_TMP_HOSTS

if [ "$SOURCE_ANSIBLE" = "true" ]; then
  ANSIBLE_DIR=${ANSIBLE_DIR:=$HOME/ansible} # folder where ansible is installed
  echo -e "${GREEN}Using Ansible from ${ANSIBLE_DIR} v$(cat $ANSIBLE_DIR/VERSION)${NORMAL}"
  cd $ANSIBLE_DIR # switch folder otherwise vagrant folder might not work
  source ${ANSIBLE_DIR}/hacking/env-setup
fi
if [ -f $ANSIBLE_ROLEFILE ]; then
  echo -e "${GREEN}Using Rolefile${NORMAL}"
  ANSIBLE_ROLES_PATH=${ANSIBLE_ROLES_PATH:=$ANSIBLE_BASE_FOLDER/.roles}
  if [ ! -d $ANSIBLE_ROLES_PATH ]; then
    mkdir -p $ANSIBLE_ROLES_PATH
  fi
  export ANSIBLE_ROLES_PATH=$ANSIBLE_ROLES_PATH
  ansible-galaxy install --role-file=$ANSIBLE_ROLEFILE --force
fi

echo -e "${GREEN}Running Ansible${NORMAL}"
export PROVISION_ARGS=$ANSIBLE_RUN_PROVISION_ARGS
ansible-playbook $ANSIBLE_OPTIONS $ANSIBLE_RUN_PLAYBOOK --inventory-file=$ANSIBLE_TMP_HOSTS

# clean up
rm $ANSIBLE_TMP_HOSTS
