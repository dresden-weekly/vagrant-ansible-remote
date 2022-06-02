#!/bin/bash
# This script parses the arguments for the ansible script execution
set -e

# configuration options
# =====================
#
# ANSIBLE_PROJECT_FOLDER (default: "$(pwd)")
#   absolute base folder for the default ansible folders
# ANSIBLE_INVENTORY_DIR (default: "$ANSIBLE_PROJECT_FOLDER/inventory")
#   absolute folder for hosts files
# ANSIBLE_PLAYBOOK_DIR (default: "$ANSIBLE_PROJECT_FOLDER/plays")
#   absolute folder for playbook files
# VAGRANT_INVOKED (default: false)
#   set this to true if this was called through Vagrant
# ANSIBLE_RUN_ARGS
#   default provision arguments, overriden by parameters
# ANSIBLE_RUN_VAGRANT (default: false)
#   enabled by parameter option
# ANSIBLE_RUN_DOCKER (default: false)
#   enabled by parameter option
# ANSIBLE_HOSTS_NAME (default: "default")
#   default relative hosts file, overriden by parameters
#   resolved with $ANSIBLE_INVENTORY_DIR
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
# ANSIBLE_RUN_DOCKER
#   flag whether docker should be used to invoke Ansible
#
# ANSIBLE_RUN_OPTIONS
#   parsed options for the Ansible invocation
#
# ANSIBLE_RUN_HOSTS (default: "$ANSIBLE_INVENTORY_DIR/$ANSIBLE_HOSTS_NAME")
#   absolute path to the hosts file
#
# ANSIBLE_RUN_PLAYBOOK (default: "$ANSIBLE_PLAYBOOK_DIR/$ANSIBLE_PLAYBOOK_NAME.yml")
#   absolute path to the playbook
#
# ANSIBLE_RUN_PROVISION_ARGS
#   additional provision arguments

# --- defaults for configuration options ---
ANSIBLE_PROJECT_FOLDER=${ANSIBLE_PROJECT_FOLDER:=$(pwd)}
ANSIBLE_INVENTORY_DIR=${ANSIBLE_RUN_HOSTS:=$ANSIBLE_PROJECT_FOLDER/inventory}
ANSIBLE_PLAYBOOK_DIR=${ANSIBLE_PLAYBOOK_DIR:=$ANSIBLE_PROJECT_FOLDER/plays}
ANSIBLE_REMEMBER_HOSTS_FILE=${ANSIBLE_REMEMBER_HOSTS_FILE:=$ANSIBLE_PROJECT_FOLDER/.remember}
VAGRANT_INVOKED=${VAGRANT_INVOKED:=false}
DOCKER_INVOKED=${DOCKER_INVOKED:=false}

if [ -z ANSIBLE_RUN_ARGS ]; then
  ANSIBLE_RUN_ARGS=""
fi
ANSIBLE_RUN_VAGRANT=${ANSIBLE_RUN_VAGRANT:=false}
ANSIBLE_RUN_DOCKER=${ANSIBLE_RUN_DOCKER:=false}
ANSIBLE_RUN_VAULT=${ANSIBLE_RUN_VAULT:=false}
if [ -z ANSIBLE_RUN_OPTIONS ]; then
  ANSIBLE_RUN_OPTIONS=""
fi
ANSIBLE_HOSTS_NAME=${ANSIBLE_HOSTS_NAME:=default}
ANSIBLE_PLAYBOOK_NAME=${ANSIBLE_PLAYBOOK_NAME:=provision}
if [ -z ANSIBLE_RUN_PROVISION_ARGS ]; then
  ANSIBLE_RUN_PROVISION_ARGS=""
fi

# --- constants ---
GREEN='\033[0;32m'
NORMAL='\033[0m'

function show_help {
  cmd_line="remote"
  option_lines=
  argument_lines=
  # forget
  option_lines="$option_lines
    --forget            forget the remembered hosts"
  # help
  option_lines="$option_lines
    -h|--help           show this help message"
  # remember
  option_lines="$option_lines
    --remember          remember the hosts as the default for future runs"
  # step
  option_lines="$option_lines
    --step              one-step-at-a-time: confirm each task before running"
  # syntax check
  option_lines="$option_lines
    --syntax-check      only perform a syntax check on the playbook"
  # tags
  option_lines="$option_lines
    -t|--tags TAGS,..   run Ansible playbook with given tags only"
  # skip tags
  option_lines="$option_lines
    --skip-tags TAGS,.. run Ansible playbook without the given tags"
  # limits
  option_lines="$option_lines
    -l|--limit HOSTS,.. run Ansible playbook limited to the given hosts"
  # vagrant
  if [ ! "$VAGRANT_INVOKED" == true ]; then
    option_lines="$option_lines
    -v|--vagrant        use Vagrant for Ansible invocation"
  fi
  # docker
  if [ ! "$DOCKER_INVOKED" == true ]; then
    option_lines="$option_lines
    -d|--docker         use Docker for Ansible invocation"
  fi

  # vault
  cmd_line="$cmd_line [vault ...] |"
  argument_lines="$argument_lines
    vault ...      Invoke the ansible-vault and quit."

  # options
  cmd_line="$cmd_line [options]*"
  argument_lines="$argument_lines
    options        additional options in any order. See below!"
  # hosts
  cmd_line="$cmd_line [hosts]"
  argument_lines="$argument_lines
    hosts          hosts inventory where playbook is executed (default: ${ANSIBLE_RUN_HOSTS_NAME})"
  # playbook
  cmd_line="$cmd_line [playbook]"
  argument_lines="$argument_lines
    playbook       folder and basename of the playbook that should be executed (default: ${ANSIBLE_PLAYBOOK_NAME})"
  # extra args
  cmd_line="$cmd_line [extra args]*"
  argument_lines="$argument_lines
    extra args     arguments passed as PROVISION_ARGS environment variable to the playbook"

  echo "$cmd_line

arguments:$argument_lines

options:$option_lines"
  exit 99
}

function remove_remember_hosts_file {
  if [ -s "$ANSIBLE_REMEMBER_HOSTS_FILE" ]; then
    rm $ANSIBLE_REMEMBER_HOSTS_FILE
    echo -e "${GREEN}Forgot stored hosts.${NORMAL}"
  fi
  unset ANSIBLE_REMEMBERED_HOSTS_NAME
  ANSIBLE_RUN_HOSTS_NAME=$ANSIBLE_HOSTS_NAME
}

#restore remembered host
if [ -s "$ANSIBLE_REMEMBER_HOSTS_FILE" ]; then
  ANSIBLE_REMEMBERED_HOSTS_NAME=$(< $ANSIBLE_REMEMBER_HOSTS_FILE)
  ANSIBLE_RUN_HOSTS_NAME=$ANSIBLE_REMEMBERED_HOSTS_NAME
else
  ANSIBLE_RUN_HOSTS_NAME=$ANSIBLE_HOSTS_NAME
fi

#options
if [ "$VAGRANT_INVOKED" == true ]; then
  ANSIBLE_RUN_VAGRANT=true
fi
if [ "$DOCKER_INVOKED" == true ]; then
  ANSIBLE_RUN_DOCKER=true
fi
ANSIBLE_RUN_REMEMBER=false
ANSIBLE_RUN_ARGS=$@
while (($#)); do
  case $1 in
  vault)
    shift
    ANSIBLE_RUN_VAULT=true
    ANSIBLE_RUN_VAULT_ARGS="$@"
    shift $#
    break
    ;;
  --forget)
    remove_remember_hosts_file
    shift
    ;;
  -h|--help)
    show_help
    ;;
  --remember)
    ANSIBLE_RUN_REMEMBER=true
    shift
    ;;
  --skip-tags)
    shift
    ANSIBLE_RUN_OPTIONS="$ANSIBLE_RUN_OPTIONS --skip-tags=$1"
    shift
    ;;
  --step)
    ANSIBLE_RUN_OPTIONS="$ANSIBLE_RUN_OPTIONS --step"
    shift
    ;;
  --syntax-check)
    ANSIBLE_RUN_OPTIONS="$ANSIBLE_RUN_OPTIONS --syntax-check"
    shift
    ;;
  -t|--tags)
    shift
    ANSIBLE_RUN_OPTIONS="$ANSIBLE_RUN_OPTIONS --tags=$1"
    shift
    ;;
  -l|--limit)
    shift
    ANSIBLE_RUN_OPTIONS="$ANSIBLE_RUN_OPTIONS --limit=$1"
    shift
    ;;
  -v|--vagrant)
    ANSIBLE_RUN_VAGRANT=true
    shift
    ;;
  -d|--docker)
    ANSIBLE_RUN_DOCKER=true
    shift
    ;;
  *)
    break
  esac
done

# hosts
if [ ! -z "$1" ] ; then
  if [ -s "$ANSIBLE_INVENTORY_DIR/$1" ]; then
    ANSIBLE_RUN_HOSTS_NAME=$1
    if [ ! "$DOCKER_INVOKED" == true ] && [ ! "$VAGRANT_INVOKED" == true ]; then
      echo -e "${GREEN}Hosts:${NORMAL} inventory/$ANSIBLE_RUN_HOSTS_NAME"
    fi
    shift
  elif [ -s "$ANSIBLE_INVENTORY_DIR/$1.yml" ]; then
    ANSIBLE_RUN_HOSTS_NAME=$1.yml
    if [ ! "$DOCKER_INVOKED" == true ] && [ ! "$VAGRANT_INVOKED" == true ]; then
      echo -e "${GREEN}Hosts:${NORMAL} inventory/$ANSIBLE_RUN_HOSTS_NAME"
    fi
    shift
  fi
fi
if [ "$ANSIBLE_REMEMBERED_HOSTS_NAME" != "$ANSIBLE_HOSTS_NAME" ] && [ "$ANSIBLE_RUN_HOSTS_NAME" == "$ANSIBLE_REMEMBERED_HOSTS_NAME" ]; then
  if [ "$ANSIBLE_RUN_VAGRANT" == true ]; then
    echo -e "${GREEN}Remembered Hosts though Vagrant:${NORMAL} $ANSIBLE_RUN_HOSTS_NAME"
  elif [ "$ANSIBLE_RUN_DOCKER" == true ]; then
    echo -e "${GREEN}Remembered Hosts though Docker:${NORMAL} $ANSIBLE_RUN_HOSTS_NAME"
  else
    echo -e "${GREEN}Remembered Hosts:${NORMAL} $ANSIBLE_RUN_HOSTS_NAME"
  fi
fi
ANSIBLE_RUN_HOSTS=$ANSIBLE_INVENTORY_DIR/$ANSIBLE_RUN_HOSTS_NAME
if [ "$ANSIBLE_RUN_REMEMBER" == true ]; then
  echo $ANSIBLE_RUN_HOSTS_NAME>$ANSIBLE_REMEMBER_HOSTS_FILE
  echo -e "${GREEN}Will remember hosts:${NORMAL} $ANSIBLE_RUN_HOSTS_NAME"
fi

# playbook
ANSIBLE_RUN_PLAYBOOK_FOLDER=
while [ ! -z "$1" ] && [ -d "$ANSIBLE_PLAYBOOK_DIR$ANSIBLE_RUN_PLAYBOOK_FOLDER/$1" ]; do
  ANSIBLE_RUN_PLAYBOOK_FOLDER="$ANSIBLE_RUN_PLAYBOOK_FOLDER/$1"
  shift
done
if [ ! -z "$1" ] && [ -s "$ANSIBLE_PLAYBOOK_DIR$ANSIBLE_RUN_PLAYBOOK_FOLDER/$1.yml" ]; then
  ANSIBLE_PLAYBOOK_NAME=$1
  if [ ! "$DOCKER_INVOKED" == true ] && [ ! "$VAGRANT_INVOKED" == true ]; then
    echo -e "${GREEN}Action:${NORMAL} plays$ANSIBLE_RUN_PLAYBOOK_FOLDER/$ANSIBLE_PLAYBOOK_NAME.yml"
  fi
  shift
elif [ ! -z "$ANSIBLE_RUN_PLAYBOOK_FOLDER" ]; then
  if [ ! "$DOCKER_INVOKED" == true ] && [ ! "$VAGRANT_INVOKED" == true ]; then
    echo -e "${GREEN}Action:${NORMAL} plays$ANSIBLE_RUN_PLAYBOOK_FOLDER/$ANSIBLE_PLAYBOOK_NAME.yml"
  fi
fi
ANSIBLE_RUN_PLAYBOOK="$ANSIBLE_PLAYBOOK_DIR$ANSIBLE_RUN_PLAYBOOK_FOLDER/$ANSIBLE_PLAYBOOK_NAME.yml"

# provision arguments
if [ ! -z "$1" ] ; then
  ANSIBLE_RUN_PROVISION_ARGS=$@
  echo -e "${GREEN}Arguments:${NORMAL} $@"
fi
