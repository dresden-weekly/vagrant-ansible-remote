#!/bin/bash

# configuration options
# =====================
#
# PROJECT_FOLDER (default: "$(pwd)")
#   Absolute path of the Project
# DOCKER_ANSIBLE_IMAGE (default: "hnhs/ansible-2.5.4:latest")
#   Docker image name that has Ansible installed
# VAGRANT_PROJECT_MOUNT (default: "/vagrant")
#   Where is the project mounted into the docker container
# VAGRANT_ANSIBLE_REMOTE (default: "vagrant_ansible_remote")
#   Relative path of vagrant-ansible-remote to the project
# VAGRANT_ANSIBLE_INVOKE_PREFIX (default: "")
#   Prefix command for the invokation script
# VAGRANT_ANSIBLE_INVOKE_SCRIPT (default: "remote.sh")
#   Path of the invokated script relative to vagrant-ansible-remote
# DOCKER_ENV_ARGS
#   Extra environment variables set inside the docker container
#   use: "--env NAME=value [...]"
# DOCKER_MOUNT_ARGS
#   Extra mounts to make files available to the docker container
#   example: "--mount src=$user/.ssh,target=/root/.ssh,type=bind,readonly [...]""

PROJECT_FOLDER=${PROJECT_FOLDER:=$(pwd)}
DOCKER_ANSIBLE_IMAGE=${DOCKER_ANSIBLE_IMAGE:=hnhs/ansible-2.5.4:latest}
VAGRANT_PROJECT_MOUNT=${VAGRANT_PROJECT_MOUNT:=/ansible}
VAGRANT_ANSIBLE_REMOTE=${VAGRANT_ANSIBLE_REMOTE:=vagrant_ansible_remote}
VAGRANT_ANSIBLE_INVOKE_SCRIPT=${VAGRANT_ANSIBLE_INVOKE_SCRIPT:=remote.sh}

# --- build the command ---
COMMAND="/bin/bash $VAGRANT_PROJECT_MOUNT/$VAGRANT_ANSIBLE_INVOKE_SCRIPT $ANSIBLE_RUN_ARGS"

if [ ! -z $VAGRANT_ANSIBLE_INVOKE_PREFIX ]; then
  COMMAND="$VAGRANT_ANSIBLE_INVOKE_PREFIX $COMMAND"
fi

# --- build environment ---
ENV_ARGS="--env DOCKER_INVOKED=true"
ENV_ARGS="--env VAGRANT_ANSIBLE_REMOTE=$VAGRANT_ANSIBLE_REMOTE $ENV_ARGS"
ENV_ARGS="--env PROJECT_FOLDER=$VAGRANT_PROJECT_MOUNT $ENV_ARGS"

if [ ! -z $DOCKER_ENV_ARGS ]; then
  ENV_ARGS="$DOCKER_ENV_ARGS $ENV_ARGS"
fi

MOUNT_ARGS="--mount src=$PROJECT_FOLDER,target=$VAGRANT_PROJECT_MOUNT,type=bind"

if [ ! -z "$DOCKER_MOUNT_ARGS" ]; then
  MOUNT_ARGS="$DOCKER_MOUNT_ARGS $MOUNT_ARGS"
fi

# --- run the command ---
echo docker run -it --rm $MOUNT_ARGS $ENV_ARGS $DOCKER_ANSIBLE_IMAGE $COMMAND
docker run -it --rm $MOUNT_ARGS $ENV_ARGS $DOCKER_ANSIBLE_IMAGE $COMMAND
