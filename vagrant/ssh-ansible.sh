#!/bin/bash
# This script is executed by the remote.sh
set -e

# configuration options
# =====================
#
# VAGRANT_ANSIBLE_MACHINE (default: "default")
#   Vagrant name of the machine with Ansible
# ANSIBLE_ENV
#   Environment variables for the ansible invoke script
#   ENV_NAME=env_value NAME2=Value2
# VAGRANT_SSH_ARGS
#   Extra SSH arguments for vagrant
# VAGRANT_PROJECT_MOUNT (default: "/vagrant")
#   Where is the project mounted in the Vagrant guest
# VAGRANT_ANSIBLE_REMOTE (default: "vagrant_ansible_remote")
#   Relative path of vagrant-ansible-remote to the project
# VAGRANT_ANSIBLE_INVOKE_PREFIX (default: "sudo")
#   Prefix command for the invokation script
#   example: Use "sudo" for local self provisioning
# VAGRANT_ANSIBLE_INVOKE_SCRIPT (default: "vagrant/invoke-ansible.sh")
#   Path of the invokated script relative to vagrant-ansible-remote

# --- option defaults ---
VAGRANT_ANSIBLE_MACHINE=${VAGRANT_ANSIBLE_MACHINE:=default}
VAGRANT_PROJECT_MOUNT=${VAGRANT_PROJECT_MOUNT:=/vagrant}
VAGRANT_ANSIBLE_REMOTE=${VAGRANT_ANSIBLE_REMOTE:=vagrant_ansible_remote}
VAGRANT_ANSIBLE_INVOKE_SCRIPT=${VAGRANT_ANSIBLE_INVOKE_SCRIPT:=vagrant/invoke-ansible.sh}

# --- derived values ---
REMOTE_VAGRANT_ANSIBLE_REMOTE=$VAGRANT_PROJECT_MOUNT/$VAGRANT_ANSIBLE_REMOTE
INVOKE_ANSIBLE=$REMOTE_VAGRANT_ANSIBLE_REMOTE/$VAGRANT_ANSIBLE_INVOKE_SCRIPT

# --- build the command ---
COMMAND="/bin/bash $INVOKE_ANSIBLE $ANSIBLE_RUN_ARGS"
COMMAND="VAGRANT_INVOKED=true $COMMAND"
COMMAND="VAGRANT_ANSIBLE_REMOTE=$REMOTE_VAGRANT_ANSIBLE_REMOTE $COMMAND"
COMMAND="PROJECT_FOLDER=$VAGRANT_PROJECT_MOUNT $COMMAND"
if [ ! -z $ANSIBLE_ENV ]; then
  COMMAND="$ANSIBLE_ENV $COMMAND"
fi
if [ ! -z $VAGRANT_ANSIBLE_INVOKE_PREFIX ]; then
  COMMAND="$VAGRANT_ANSIBLE_INVOKE_PREFIX $COMMAND"
fi
if [ ! -z $VAGRANT_SSH_ARGS ]; then
  VAGRANT_SSH_ARGS=" -- $VAGRANT_SSH_ARGS"
fi

# --- check that all vagrant machines are up ---
vagrant status | read ; while read first second third fourth fifth; do
  if [ ! -z $fifth ]; then
    break
  fi
  if [ ! "$second" == "running" ]; then
    vagrant up
    break
  fi
done

# --- run the command ---
vagrant ssh $VAGRANT_ANSIBLE_MACHINE --command "$COMMAND"$VAGRANT_SSH_ARGS 2>/dev/null
