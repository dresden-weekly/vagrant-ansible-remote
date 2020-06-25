@echo off
SETLOCAL ENABLEEXTENSIONS

:: configuration options
:: =====================
::
:: PROJECT_FOLDER (default: "%CD%")
::   Absolute path of the Project
:: DOCKER_ANSIBLE_IMAGE (default: "hnhs/ansible-2.5.4:latest")
::   Docker image name that has Ansible installed
:: VAGRANT_PROJECT_MOUNT (default: "/vagrant")
::   Where is the project mounted into the docker container
:: VAGRANT_ANSIBLE_REMOTE (default: "vagrant_ansible_remote")
::   Relative path of vagrant-ansible-remote to the project
:: VAGRANT_ANSIBLE_INVOKE_PREFIX (default: "")
::   Prefix command for the invokation script
:: VAGRANT_ANSIBLE_INVOKE_SCRIPT (default: "remote.sh")
::   Path of the invokated script relative to vagrant-ansible-remote
:: DOCKER_ENV_ARGS
::   Extra environment variables set inside the docker container
::   use: "--env NAME=value [...]"
:: DOCKER_MOUNT_ARGS
::   Extra mounts to make files available to the docker container
::   example: "--mount src=$user/.ssh,target=/root/.ssh,type=bind,readonly [...]""
:: 
if not defined PROJECT_FOLDER (
  set "PROJECT_FOLDER=%CD%"
)
if not defined DOCKER_ANSIBLE_IMAGE (
  set "DOCKER_ANSIBLE_IMAGE=hnhs/ansible-2.5.4:latest"
)
if not defined VAGRANT_PROJECT_MOUNT (
  set "VAGRANT_PROJECT_MOUNT=/ansible"
)
if not defined VAGRANT_ANSIBLE_REMOTE (
  set "VAGRANT_ANSIBLE_REMOTE=vagrant_ansible_remote"
)
if not defined VAGRANT_ANSIBLE_INVOKE_SCRIPT (
  set "VAGRANT_ANSIBLE_INVOKE_SCRIPT=remote.sh"
)

:: --- build the command ---
set "COMMAND=/bin/bash %VAGRANT_PROJECT_MOUNT%/%VAGRANT_ANSIBLE_INVOKE_SCRIPT%"
if not "%*"=="" (
  set "COMMAND=%COMMAND% %*"
)
if defined VAGRANT_ANSIBLE_INVOKE_PREFIX (
  set "COMMAND=%VAGRANT_ANSIBLE_INVOKE_PREFIX% %COMMAND%"
)

:: --- build environment ---
set "ENV_ARGS=--env DOCKER_INVOKED=true"
set "ENV_ARGS=--env VAGRANT_ANSIBLE_REMOTE=%VAGRANT_ANSIBLE_REMOTE:\=/% %ENV_ARGS%"
set "ENV_ARGS=--env PROJECT_FOLDER=%VAGRANT_PROJECT_MOUNT:\=/% %ENV_ARGS%"
if defined DOCKER_ENV_ARGS (
  set "ENV_ARGS=%DOCKER_ENV_ARGS% %ENV_ARGS%"
)

set "MOUNT_ARGS=--mount src=%PROJECT_FOLDER%,target=%VAGRANT_PROJECT_MOUNT%,type=bind"
if defined DOCKER_MOUNT_ARGS (
  set "MOUNT_ARGS=%DOCKER_MOUNT_ARGS% %MOUNT_ARGS%"
)

:: --- run the command ---
echo docker run -it --rm %MOUNT_ARGS% %ENV_ARGS% %DOCKER_ANSIBLE_IMAGE% %COMMAND%
docker run -it --rm %MOUNT_ARGS% %ENV_ARGS% %DOCKER_ANSIBLE_IMAGE% %COMMAND%

ENDLOCAL