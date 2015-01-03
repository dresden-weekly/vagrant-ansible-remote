@echo off
SETLOCAL ENABLEEXTENSIONS

:: Where is the project mounted in the vagrant guest
if [%REMOTE_PATH%]==[] set REMOTE_PATH=/vagrant

:: Relative path of vagrant-ansible-remote to the project
if [%VAGRANT_ANSIBLE_REMOTE%]==[] set VAGRANT_ANSIBLE_REMOTE=vagrant_ansible_remote

:: path of vagrant-ansible-remote on the guest
set REMOTE_VAGRANT_ANSIBLE_REMOTE=%REMOTE_PATH%/%VAGRANT_ANSIBLE_REMOTE%

:: path of the invoking script
set INVOKE_ANSIBLE=%REMOTE_VAGRANT_ANSIBLE_REMOTE%/vagrant/invoke-ansible.sh

set "COMMAND=/bin/bash %INVOKE_ANSIBLE% %*"
set "COMMAND=VAGRANT_ANSIBLE_REMOTE=%REMOTE_VAGRANT_ANSIBLE_REMOTE:\=/% %COMMAND%"
set "COMMAND=BASE_FOLDER=%REMOTE_PATH:\=/% %COMMAND%"
if not [%SSH_ARGS%]==[] set "COMMAND=%COMMAND% -- %SSH_ARGS%"
if not [%ENV%]==[] set "COMMAND=%ENV% %COMMAND%"
set COMMAND=vagrant ssh --command "sudo %COMMAND%"

set REQUIRE_UP=0
for /F "skip=1 tokens=2,4" %%A in ('vagrant status') do (
  if not [%%B]==[] goto :up_done
  if not [%%A]==[running] set REQUIRE_UP=1
)
:up_done
if %REQUIRE_UP%==1 vagrant up

%COMMAND% 2>nul

ENDLOCAL
