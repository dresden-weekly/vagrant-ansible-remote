@echo off

:: configuration options
:: =====================
::
:: PROJECT_FOLDER (default: "$(pwd)")
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

:: Windows cannot run Ansible therefore we use Vagrant
call "%PROJECT_FOLDER%/%VAGRANT_ANSIBLE_REMOTE%/vagrant/ssh-ansible.bat" %*
