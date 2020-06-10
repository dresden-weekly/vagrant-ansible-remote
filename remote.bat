@echo off

:: configuration options
:: =====================
::
:: PROJECT_FOLDER (default: "%CD%")
::   Absolute path of the Project (containing the Vagrantfile)
:: VAGRANT_ANSIBLE_REMOTE (default: "vagrant_ansible_remote")
::   Relative path of vagrant-ansible-remote to the project

:: --- option defaults ---
if not defined PROJECT_FOLDER (
  set "PROJECT_FOLDER=%CD%"
)
if not defined VAGRANT_ANSIBLE_REMOTE (
  set "VAGRANT_ANSIBLE_REMOTE=vagrant_ansible_remote"
)
if not defined REMOTE_TYPE (
  set "REMOTE_TYPE=vagrant-ssh"
)

:: --- constants ---
if defined ANSICON (
  set "RED=[1;31;40m"
  set "NORMAL=[0m"
) else (
  set RED=
  set NORMAL=
)

:: --- check environment ---
if not exist "%PROJECT_FOLDER%" (
  echo %RED%PROJECT_FOLDER%NORMAL% is not valid
  exit 20
)
if "%VAGRANT_ANSIBLE_REMOTE%." == "" (
  echo %RED%VAGRANT_ANSIBLE_REMOTE%NORMAL% is not valid
  exit 21
)
if not exist "%PROJECT_FOLDER%/%VAGRANT_ANSIBLE_REMOTE%" (
  echo %RED%VAGRANT_ANSIBLE_REMOTE%NORMAL% is not valid
  exit 21
)

:: --- load customiztion ---
if exist "%PROJECT_FOLDER%/.remote.bat" (
  call "%PROJECT_FOLDER%/.remote.bat"
)

:: Windows cannot run Ansible therefore we use 
if "%REMOTE_TYPE%" == "vagrant-ssh" (
  call "%PROJECT_FOLDER%/%VAGRANT_ANSIBLE_REMOTE%/vagrant/ssh-ansible.bat" %*
) else if "%REMOTE_TYPE%" == "docker-run" (
  call "%PROJECT_FOLDER%/%VAGRANT_ANSIBLE_REMOTE%/docker/run-ansible.bat" %*
) else (
  echo "%RED%REMOTE_TYPE%NORMAL% is not valid (%REMOTE_TYPE%)"
)
