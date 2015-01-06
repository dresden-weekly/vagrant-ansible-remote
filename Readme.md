# Vagrant Ansible Remote

A collection of common scripts used to run Ansible everywhere

## Mission statement

* Should work for Windows, Mac and Linux systems.
  * Windows cannot run Ansible nativly.
* Tie the Ansible version/installation method to the project
* Make Testing with Vagrant easy

## Solution

This project contains a set of generic and very configurable scripts that help with all these steps.

Your project simply contains a "remote"-script. This script is very will install the right version of Ansible where you want it. It will also launch Vagrant virtual machines if necessary.

## Prerequisites

1. Vagrant
1. Vagrant HostManager-Plugin
    ```bash
    vagrant plugin install vagrant-hostmanager
    ```

## Project Creation

1. Copy the contents of template/ into a new folder
    ```bash
    cp -R $vagrant-ansible-remote/template .
    ```

1. Add this repository as git-submodule
    ```bash
    git submodule add https://github.com/dresden-weekly/vagrant-ansible-remote
    ```

1. Test your project setup with vagrant
    ```bash
    # bash
    ./remote.sh
    ```
    ```cmd
    :: cmd
    remote
    ```

1. Have fun!

## Using Remote script

argument schema:

@remote [-h|--help] [-v|--vagrant] [hosts] [playbook] [extra args]@

Simply calling
```cmd
remote
```
equals:
```cmd
remote default provision
```

More examples:
```cmd
:: provision staging server
remote staging provision

:: deploying release to staging server
remote staging deploy

:: import dump from an archive
remote staging import_dump dumps/archive.tar.gz
```
