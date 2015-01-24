@echo off
:: This script is executed by the remote.bat
SETLOCAL ENABLEEXTENSIONS

:: configuration options
:: =====================
::
:: PROJECT_FOLDER (default: "%CD%")
::   Absolute path of the Project (containing the Vagrantfile)
:: VAGRANT_ANSIBLE_MACHINE (default: "default")
::   Vagrant name of the machine with Ansible
:: ANSIBLE_ENV
::   Environment variables for the ansible invoke script
::   ENV_NAME=env_value NAME2=Value2
:: VAGRANT_SSH_ARGS
::   Extra SSH arguments for vagrant
:: VAGRANT_UP_ARGS
::   Extra Options for vagrant up
:: VAGRANT_PROJECT_MOUNT (default: "/vagrant")
::   Where is the project mounted in the Vagrant guest
:: VAGRANT_ANSIBLE_REMOTE (default: "vagrant_ansible_remote")
::   Relative path of vagrant-ansible-remote to the project
:: VAGRANT_ANSIBLE_INVOKE_PREFIX (default: "")
::   Prefix command for the invokation script
:: VAGRANT_ANSIBLE_INVOKE_SCRIPT (default: "remote.sh")
::   Path of the invokated script relative to vagrant-ansible-remote

:: --- option defaults ---
if not defined PROJECT_FOLDER (
  set "PROJECT_FOLDER=%CD%"
)
if not defined VAGRANT_ANSIBLE_MACHINE (
  set "VAGRANT_ANSIBLE_MACHINE=default"
)
if not defined VAGRANT_PROJECT_MOUNT (
  set "VAGRANT_PROJECT_MOUNT=/vagrant"
)
if not defined VAGRANT_ANSIBLE_REMOTE (
  set "VAGRANT_ANSIBLE_REMOTE=vagrant_ansible_remote"
)
if not defined VAGRANT_ANSIBLE_INVOKE_PREFIX (
  set "VAGRANT_ANSIBLE_INVOKE_PREFIX="
)
if not defined VAGRANT_ANSIBLE_INVOKE_SCRIPT (
  set "VAGRANT_ANSIBLE_INVOKE_SCRIPT=remote.sh"
)

:: --- build the command ---
set "COMMAND=/bin/bash %VAGRANT_PROJECT_MOUNT%/%VAGRANT_ANSIBLE_INVOKE_SCRIPT% %*"
set "COMMAND=VAGRANT_INVOKED=true %COMMAND%"
set "COMMAND=VAGRANT_ANSIBLE_REMOTE=%VAGRANT_ANSIBLE_REMOTE:\=/% %COMMAND%"
set "COMMAND=PROJECT_FOLDER=%VAGRANT_PROJECT_MOUNT:\=/% %COMMAND%"
if defined ANSIBLE_ENV (
  set "COMMAND=%ANSIBLE_ENV% %COMMAND%"
)
if defined VAGRANT_ANSIBLE_INVOKE_PREFIX (
  set "COMMAND=%VAGRANT_ANSIBLE_INVOKE_PREFIX% %COMMAND%"
)
if defined VAGRANT_SSH_ARGS (
  set "VAGRANT_SSH_ARGS= -- %VAGRANT_SSH_ARGS%"
)

:: --- vagrant requires to be in the folder ---
pushd %PROJECT_FOLDER%

:: --- check that all vagrant machines are up ---
for /F "skip=1 tokens=2,5" %%A in ('vagrant status') do (
  if not "%%B."=="." goto :vagrant_up_done
  if not "%%A"=="running" (
    vagrant up %VAGRANT_UP_ARGS%
    goto :vagrant_up_done
  )
)
:vagrant_up_done

:: --- run the command ---
vagrant ssh %VAGRANT_ANSIBLE_MACHINE% --command "%COMMAND%"%VAGRANT_SSH_ARGS% 2>nul

popd
ENDLOCAL
