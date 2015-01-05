@echo off

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
