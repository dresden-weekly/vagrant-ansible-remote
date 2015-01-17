#!/bin/bash
# This script parses the arguments for the ansible script execution
set -e

# configuration options
# =====================
#
# ANSIBLE_PROJECT_FOLDER (default: "$(pwd)")
#   absolute base folder for the default ansible folders
# ANSIBLE_HOSTS_DIR (default: "$ANSIBLE_PROJECT_FOLDER/hosts")
#   absolute folder for normal hosts files
# ANSIBLE_VAGRANT_HOSTS_DIR (default: "$ANSIBLE_PROJECT_FOLDER/vagrant_hosts")
#   absolute folder for vagrant hosts files
# ANSIBLE_PLAYBOOK_DIR (default: "$ANSIBLE_PROJECT_FOLDER/plays")
#   absolute folder for playbook files
# VAGRANT_INVOKED (default: false)
#   set this to true if this was called through Vagrant
# ANSIBLE_RUN_ARGS
#   default provision arguments, overriden by parameters
# ANSIBLE_RUN_VAGRANT (default: false)
#   enabled by parameter option
# ANSIBLE_HOSTS_NAME (default: "default")
#   default relative hosts file, overriden by parameters
#   resolved with $ANSIBLE_HOSTS_DIR or $ANSIBLE_VAGRANT_HOSTS_DIR
# ANSIBLE_PLAYBOOK_NAME (default: "provision")
#   default relative playbook file, overriden by parameters
#   resolved with $ANSIBLE_PROJECT_FOLDER
#
# output variables
# ================
#
# ANSIBLE_RUN_ARGS
#   all arguments, useful to call ansible inside vagrant
#
# ANSIBLE_RUN_VAGRANT
#   flag whether vagrant should be used to invoke Ansible
#
# ANSIBLE_RUN_HOSTS (default: "$ANSIBLE_HOSTS_DIR/$ANSIBLE_HOSTS_NAME")
#   absolute path to the hosts file
#
# ANSIBLE_RUN_PLAYBOOK (default: "$ANSIBLE_PLAYBOOK_DIR/$ANSIBLE_PLAYBOOK_NAME.yml")
#   absolute path to the playbook
#
# ANSIBLE_RUN_PROVISION_ARGS
#   additional provision arguments

# --- defaults for configuration options ---
ANSIBLE_PROJECT_FOLDER=${ANSIBLE_PROJECT_FOLDER:=$(pwd)}
ANSIBLE_HOSTS_DIR=${ANSIBLE_RUN_HOSTS:=$ANSIBLE_PROJECT_FOLDER/hosts}
ANSIBLE_VAGRANT_HOSTS_DIR=${ANSIBLE_VAGRANT_HOSTS_DIR:=$ANSIBLE_PROJECT_FOLDER/vagrant_hosts}
ANSIBLE_PLAYBOOK_DIR=${ANSIBLE_PLAYBOOK_DIR:=$ANSIBLE_PROJECT_FOLDER/plays}
VAGRANT_INVOKED=${VAGRANT_INVOKED:=false}

ANSIBLE_RUN_ARGS=${ANSIBLE_RUN_ARGS:=}
ANSIBLE_RUN_VAGRANT=${ANSIBLE_RUN_VAGRANT:=false}
ANSIBLE_HOSTS_NAME=${ANSIBLE_HOSTS_NAME:=default}
ANSIBLE_PLAYBOOK_NAME=${ANSIBLE_PLAYBOOK_NAME:=provision}
ANSIBLE_RUN_PROVISION_ARGS=${ANSIBLE_RUN_PROVISION_ARGS:=}

# --- constants ---
GREEN='\033[0;32m'
NORMAL='\033[0m'

# help
if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
  cmd_line=remote
  where_lines=
  # help
  cmd_line="$cmd_line [-h|--help]"
  where_lines="$where_lines
    -h|--help     show this help message"
  if [ ! "$VAGRANT_INVOKED" == true ]; then
    # vagrant
    cmd_line="$cmd_line [-v|--vagrant]"
    where_lines="$where_lines
    -v|--vagrant  use Vagrant for Ansible invocation"
  fi
  # TODO: system
  # cmd_line="$cmd_line [-s|--system]"
  # where_lines="$where_lines
  #   -s|--system   use the system installation of Ansible"
  # hosts
  cmd_line="$cmd_line [hosts]"
  where_lines="$where_lines
    hosts         hosts/groups-file where playbook is executed (default: vagrant)"
  # playbook
  cmd_line="$cmd_line [playbook]"
  where_lines="$where_lines
    playbook      basename of the playbook that should be executed (default: provision)"
  # extra args
  cmd_line="$cmd_line [extra args...]"
  where_lines="$where_lines
    extra args    arguments passed as PROVISION_ARGS environment variable to the playbook"

  echo "$cmd_line

where:$where_lines"
  exit 99
fi

ANSIBLE_RUN_ARGS=$@

# vagrant
if [ "$VAGRANT_INVOKED" == true ]; then
  ANSIBLE_RUN_VAGRANT=true
else
  if [ "$1" == "--vagrant" ] || [ "$1" == "-v" ]; then
    ANSIBLE_RUN_VAGRANT=true
    shift
  fi
fi

# absolute hosts file default
if [ "$ANSIBLE_RUN_VAGRANT" == true ]; then
  ANSIBLE_RUN_HOSTS=$ANSIBLE_VAGRANT_HOSTS_DIR/$ANSIBLE_HOSTS_NAME
else
  ANSIBLE_RUN_HOSTS=$ANSIBLE_HOSTS_DIR/$ANSIBLE_HOSTS_NAME
fi

# hosts
if [ ! -z "$1" ] ; then
  if [ ! "$ANSIBLE_RUN_VAGRANT" == true ] && [ -s "$ANSIBLE_HOSTS_DIR/$1" ]; then
    ANSIBLE_RUN_HOSTS=$ANSIBLE_HOSTS_DIR/$1
    echo -e "${GREEN}Target:${NORMAL} $1"
    shift
  elif [ -s "$ANSIBLE_VAGRANT_HOSTS_DIR/$1" ]; then
    ANSIBLE_RUN_VAGRANT=true
    ANSIBLE_RUN_HOSTS=$ANSIBLE_VAGRANT_HOSTS_DIR/$1
    echo -e "${GREEN}Target though Vagrant:${NORMAL} $1"
    shift
  fi
fi

# playbook
ANSIBLE_RUN_PLAYBOOK_FOLDER=
while [ ! -z "$1" ] && [ -d "$ANSIBLE_PLAYBOOK_DIR$ANSIBLE_RUN_PLAYBOOK_FOLDER/$1" ]; do
  ANSIBLE_RUN_PLAYBOOK_FOLDER="$ANSIBLE_RUN_PLAYBOOK_FOLDER/$1"
  shift
done
if [ ! -z "$1" ] && [ -s "$ANSIBLE_PLAYBOOK_DIR$ANSIBLE_RUN_PLAYBOOK_FOLDER/$1.yml" ]; then
  ANSIBLE_PLAYBOOK_NAME=$1
  echo -e "${GREEN}Action:${NORMAL} $ANSIBLE_RUN_PLAYBOOK_FOLDER/$ANSIBLE_PLAYBOOK_NAME"
  shift
fi
ANSIBLE_RUN_PLAYBOOK="$ANSIBLE_PLAYBOOK_DIR$ANSIBLE_RUN_PLAYBOOK_FOLDER/$ANSIBLE_PLAYBOOK_NAME.yml"

# provision arguments
if [ ! -z "$1" ] ; then
  ANSIBLE_RUN_PROVISION_ARGS=$@
  echo -e "${GREEN}Arguments:${NORMAL} $@"
fi
