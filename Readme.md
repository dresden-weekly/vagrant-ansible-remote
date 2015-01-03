Vagrant Ansible Remote
======================

A collection of common scripts used to run Ansible everywhere

Mission statement
-----------------

Should work for Windows, Mac and Linux systems.
Install and use a specific version of Ansible.

Simple use cases
----------------

  remote
equals:
  remote vagrant provision

provision other server
  remote staging provision
  remote staging deploy

execute other tasks
  remote staging fixture_export
  remote staging fixture_import system-20150101.tgz

Challenges
----------

Windows cannot run Ansible nativly.
