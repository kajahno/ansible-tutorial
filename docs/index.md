# Ansible tutorial

This will be a crash course on learning how to set up and use Ansible by examples. 

Even though all the information will be provided here, I strongly recommend to follow the tutorial for a better experience. 

This series is divided into the following parts:

* Part 1: Prerequisites
    * Install all the required software for this tutorial
* Part 2: best practices and first playbook
    * Create a role to provision the popular nginx webserver with a sample page
    * Create a playbook to use the role
* Part 3: handling the inventory
    * Variable precedence
    * Multiple environments
    * Vault and secrets
* Part 3: getting to know the internals
    * Create a custom module
* Part 4: make custom components 1
    * Create a custom filter plugin
* Part 5: make custom components 2
    * Create a custom lookup plugin
* Part 6: make roles that never fail
    * Add tests to our role


## Install all the required software for this tutorial

### Prerequisites

In this tutorial, and the upcoming tutorials it will be assumed that Ansible is used inside a Python Virtual Environment. The advantage of this is that we can access several versions of Ansible, and install more packages on top of it.

I wrote this using Linux Ubuntu, but the steps should be transferable to any OS you use.

#### Create a virtual environment

* Ensure `pip` is installed:
    ```
    sudo apt-get install python-pip
    ```
* Ensure `virtualenv` is installed:
    ```
    pip install virtualenv
    ```
* Create a virtual environment using python3, under `~/.venv`
    ```
    virtualenv -p $( which python3 ) .venv
    ```

#### Activate a virtual environment

You will be doing this quite often, so please keep this command handy:
```
source .venv/bin/activate
```
After this you will notice how the Linux prompt has changed, adding `(.venv)` at the beginning. 

To deactivate the virtual environment simply run `deactivate`. After this you will notice how the Linux prompt returns to its original state. 

*Note*: for the purpose of this tutorial leave the virtual environment activated at all times. 


#### Install Ansible

Get the latest stable release (2.7 at the moment of this guide):
```
pip install ansible
```

Verify Ansible has been intalled:
```
ansible --version
```

#### Install Vagrant

We will use vagrant to quicly spin up virtual machines, using Virtual box as a driver (Vagrant will use it by default).

* Download the latest version from the [download page](https://releases.hashicorp.com/vagrant/):
    ```
    wget https://releases.hashicorp.com/vagrant/2.2.0/vagrant_2.2.0_linux_amd64.zip
    ```
* Unzip the downloaded file
    ```
    unzip vagrant_2.2.0_linux_amd64.zip
    ```
* Add to the user binaries path
    ```
    sudo mv vagrant /usr/local/bin/
    ```
* Verify Vagrant has been installed
    ```
    vagrant --version
    ```
    > this should return: `Vagrant 2.2.0`


## [Next up -> Part 2: best practices and first playbook](#)

### References
- [Python virtual environments](https://docs.python-guide.org/dev/virtualenvs/)
- [Vagrant](https://www.vagrantup.com/)
- [Vagrant cloud](https://app.vagrantup.com/boxes/search)
- [Learn more about Ansible](https://www.ansible.com/how-ansible-works/)
- [Ansible documentation](http://docs.ansible.com/)
