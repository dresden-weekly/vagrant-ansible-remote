@echo off
:: This script should be placed in the root of your project
:: 
:: Configure project specific customizations here and allow custom overrides.
:: Use .remote.bat/sh to configure user specific customizasions.
::
SETLOCAL ENABLEEXTENSIONS

::   Absolute path of the project
set "PROJECT_FOLDER=%~dp0"

::   Relative path of vagrant-ansible-remote to the project
set "VAGRANT_ANSIBLE_REMOTE=vagrant-ansible-remote"

::   Vagrant name of the machine with Ansible
if not defined VAGRANT_ANSIBLE_MACHINE (
  set "VAGRANT_ANSIBLE_MACHINE=ansible-vm"
)

::   Docker image with Ansible installed
if not defined DOCKER_IMAGE (
  set "DOCKER_IMAGE=ansible:2.5.4"
)

::   Transfer some environment variables
if not defined ANSIBLE_ENV ( set "ANSIBLE_ENV= " )

if defined SECRET_KEY_BASE if "%ANSIBLE_ENV:SECRET_KEY_BASE=%." == "%ANSIBLE_ENV%." (
  set "ANSIBLE_ENV=SECRET_KEY_BASE=%SECRET_KEY_BASE% %ANSIBLE_ENV%"
  set "DOCKER_ENV_ARGS=--env SECRET_KEY_BASE=%SECRET_KEY_BASE% %DOCKER_ENV_ARGS%"
)

call "%PROJECT_FOLDER%/%VAGRANT_ANSIBLE_REMOTE%/remote.bat" %*

ENDLOCAL
