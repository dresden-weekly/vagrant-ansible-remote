#!/bin/bash
# This script should be placed in the root of your project

#   Absolute path of the project
PROJECT_FOLDER=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

#   Relative path of vagrant-ansible-remote to the project
VAGRANT_ANSIBLE_REMOTE=vagrant-ansible-remote

#   Vagrant name of the machine with Ansible
VAGRANT_ANSIBLE_MACHINE=${VAGRANT_ANSIBLE_MACHINE:=ansible-vm}

#   Docker image with Ansible installed
DOCKER_IMAGE=${DOCKER_IMAGE:=hnhs/ansible-2.5.4:latest}

#   default relative hosts file, overriden by parameters
ANSIBLE_HOSTS_NAME=${ANSIBLE_HOSTS_NAME:=yourapp-vm}

source "$PROJECT_FOLDER/$VAGRANT_ANSIBLE_REMOTE/remote.sh"
