@echo off
:: This script is executed by the remote.bat
SETLOCAL ENABLEEXTENSIONS

:: configuration options
:: =====================
::
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
:: VAGRANT_ANSIBLE_INVOKE_PREFIX (default: "sudo")
::   Prefix command for the invokation script
::   "sudo" allows for Ansible installation
:: VAGRANT_ANSIBLE_INVOKE_SCRIPT (default: "vagrant/invoke-ansible.sh")
::   Path of the invokated script relative to vagrant-ansible-remote

:: --- option defaults ---
if not defined VAGRANT_ANSIBLE_MACHINE (
  set "VAGRANT_ANSIBLE_MACHINE=default"
)
if not defined VAGRANT_PROJECT_MOUNT (
  set "VAGRANT_PROJECT_MOUNT=/vagrant"
)
if not defined VAGRANT_ANSIBLE_REMOTE (
  set "VAGRANT_ANSIBLE_REMOTE=vagrant_ansible_remote"
)
::if not defined VAGRANT_ANSIBLE_INVOKE_PREFIX (
::  set "VAGRANT_ANSIBLE_INVOKE_PREFIX=sudo"
::)
if not defined VAGRANT_ANSIBLE_INVOKE_SCRIPT (
  set "VAGRANT_ANSIBLE_INVOKE_SCRIPT=vagrant/invoke-ansible.sh"
)

:: --- derived values ---
set REMOTE_VAGRANT_ANSIBLE_REMOTE=%VAGRANT_PROJECT_MOUNT%/%VAGRANT_ANSIBLE_REMOTE%
set INVOKE_ANSIBLE=%REMOTE_VAGRANT_ANSIBLE_REMOTE%/%VAGRANT_ANSIBLE_INVOKE_SCRIPT%

:: --- build the command ---
set "COMMAND=/bin/bash %INVOKE_ANSIBLE% %*"
set "COMMAND=VAGRANT_INVOKED=true %COMMAND%"
set "COMMAND=VAGRANT_ANSIBLE_REMOTE=%REMOTE_VAGRANT_ANSIBLE_REMOTE:\=/% %COMMAND%"
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

ENDLOCAL
