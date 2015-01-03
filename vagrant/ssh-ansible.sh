#!/bin/bash
set -e

REMOTE_PATH=${REMOTE_PATH:=/vagrant}
VAGRANT_ANSIBLE_REMOTE=${VAGRANT_ANSIBLE_REMOTE:=vagrant_ansible_remote}
REMOTE_VAGRANT_ANSIBLE_REMOTE=${REMOTE_VAGRANT_ANSIBLE_REMOTE:=$REMOTE_PATH/$VAGRANT_ANSIBLE_REMOTE}

INVOKE_ANSIBLE=${INVOKE_ANSIBLE:=$REMOTE_VAGRANT_ANSIBLE_REMOTE/vagrant/invoke-ansible.sh}

COMMAND="/bin/bash $INVOKE_ANSIBLE $ANSIBLE_RUN_ARGS"
COMMAND="VAGRANT_ANSIBLE_REMOTE=$REMOTE_VAGRANT_ANSIBLE_REMOTE $COMMAND"
COMMAND="BASE_FOLDER=$REMOTE_PATH $COMMAND"
if [ ! -z $SSH_ARGS ]; then
  COMMAND="$COMMAND -- $SSH_ARGS"
fi
if [ ! -z $ENV ]; then
  COMMAND="$ENV $COMMAND"
fi
COMMAND="vagrant ssh --command \"sudo $COMMAND\""

vagrant status | (read ; while read -a token; do
  if [ ! -z ${token[5]} ]; then
    break
  fi
  if [ ! "${token[1]}" == "running" ]; then
    vagrant up
    break
  fi
done)

$COMMAND 2>/dev/null
