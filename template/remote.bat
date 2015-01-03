@echo off
:: This script should be placed in the root of your project
SETLOCAL ENABLEEXTENSIONS
set OLD_CD=%CD%
cd /D "%~dp0"

set VAGRANT_ANSIBLE_REMOTE=../vagrant-ansible-remote
call "%VAGRANT_ANSIBLE_REMOTE%/vagrant/ssh-ansible.bat" %*

cd /D "%OLD_CD%"
ENDLOCAL
