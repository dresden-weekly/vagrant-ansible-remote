@echo off
:: This script should be placed in the root of your project
SETLOCAL ENABLEEXTENSIONS

::   Absolute path of the project
set "PROJECT_FOLDER=%~dp0"

::   Relative path of vagrant-ansible-remote to the project
set "VAGRANT_ANSIBLE_REMOTE=vagrant-ansible-remote"

::   Vagrant name of the machine with Ansible
if not defined VAGRANT_ANSIBLE_MACHINE (
  set "VAGRANT_ANSIBLE_MACHINE=ansible-vm"
)

call "%PROJECT_FOLDER%/%VAGRANT_ANSIBLE_REMOTE%/remote.bat" %*

ENDLOCAL
