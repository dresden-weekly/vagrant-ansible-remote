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

    ```
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
```
remote [options]* [hosts]? [playbook]* [extra args]*
```

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

## License

The MIT License (MIT)

Copyright (c) 2015 dresden-weekly

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
