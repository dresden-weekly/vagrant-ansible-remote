#!/bin/bash
set -e

ANSIBLE_BASE_FOLDER=${ANSIBLE_BASE_FOLDER:=`pwd`}

ANSIBLE_RUN_ARGS=
ANSIBLE_RUN_LOCAL=${ANSIBLE_RUN_LOCAL:=false}
ANSIBLE_RUN_HOSTS=${ANSIBLE_RUN_HOSTS:=$ANSIBLE_BASE_FOLDER/hosts/vagrant}
ANSIBLE_RUN_PLAYBOOK=${ANSIBLE_RUN_PLAYBOOK:=$ANSIBLE_BASE_FOLDER/provision.yml}
ANSIBLE_RUN_PROVISION_ARGS=${ANSIBLE_RUN_PROVISION_ARGS:=}

GREEN='\033[0;32m'
NORMAL='\033[0m'

if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
  cmd_line=remote
  where_lines=
  # help
  cmd_line="$cmd_line [-h|--help]"
  where_lines="$where_lines
    -h|--help   show this help message"
  if [ "$VAGRANT_OPTIONAL" == true ]; then
    # local
    cmd_line="$cmd_line [-l|--local]"
    where_lines="$where_lines
    -l|--local  skip vagrant and use the local Ansible installation"
  fi
  # hosts
  cmd_line="$cmd_line [hosts]"
  where_lines="$where_lines
    hosts       hosts/groups-file where playbook is executed (default: vagrant)"
  # playbook
  cmd_line="$cmd_line [playbook]"
  where_lines="$where_lines
    playbook    basename of the playbook that should be executed (default: provision)"
  # extra args
  cmd_line="$cmd_line [extra args...]"
  where_lines="$where_lines
    extra args  arguments passed as PROVISION_ARGS environment variable to the playbook"

  echo "$cmd_line

where:$where_lines"
  exit 99
fi

if [ "$VAGRANT_OPTIONAL" == true ]; then
  if [ "$1" == "--local" ] || [ "$1" == "-l" ]; then
    ANSIBLE_RUN_LOCAL=true
    shift
  fi
fi

ANSIBLE_RUN_ARGS=$@
if [ ! -z "$1" ] ; then
  if [ -s "${ANSIBLE_BASE_FOLDER}/hosts/$1" ] ; then
    ANSIBLE_RUN_HOSTS=${ANSIBLE_BASE_FOLDER}/hosts/$1
    echo -e "${GREEN}Target:${NORMAL} $1"
    shift
  fi
fi

if [ ! -z "$1" ] ; then
  if [ -s "${ANSIBLE_BASE_FOLDER}/$1.yml" ] ; then
    ANSIBLE_RUN_PLAYBOOK=${ANSIBLE_BASE_FOLDER}/$1.yml
    echo -e "${GREEN}Action:${NORMAL} $1"
    shift
  fi
fi

if [ ! -z "$1" ] ; then
  ANSIBLE_RUN_PROVISION_ARGS=$@
  echo -e "${GREEN}Arguments:${NORMAL} $@"
fi
