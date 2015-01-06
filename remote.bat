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

:: --- check environment ---
if not exist "%PROJECT_FOLDER%" (
  echo PROJECT_FOLDER is not valid
  exit 20
)
if "%VAGRANT_ANSIBLE_REMOTE%." == "" (
  echo VAGRANT_ANSIBLE_REMOTE is not valid
  exit 21
)
if not exist "%PROJECT_FOLDER%/%VAGRANT_ANSIBLE_REMOTE%" (
  echo VAGRANT_ANSIBLE_REMOTE is not valid
  exit 21
)

:: Windows cannot run Ansible therefore we use Vagrant
call "%PROJECT_FOLDER%/%VAGRANT_ANSIBLE_REMOTE%/vagrant/ssh-ansible.bat" %*
