# Ansible tutorial

The tutorial itself will be a crash course on learning how to set up and use Ansible by examples. This readme, however, will be focused on how is the setup of this documentation done.

You can find the tutorial in https://kajahno.me/ansible-tutorial

## Prerequisites

* Python3 > 3.6.8
* Python-pip
* Python virtual environment
* Linux (I did it under Ubuntu 16.10)

## Create a virtual environment and install dependencies on it

* Ensure `pip` is installed:
    ```
    $ sudo apt-get install python-pip
    ```
* Ensure `virtualenv` is installed:
    ```
    $ sudo pip install virtualenv
    ```
* Create a virtual environment using python3, under `~/.venv`
    ```
    $ virtualenv -p $( which python3 ) .venv
* Activate virtual environment
    ```
    $ source .venv/activate
    (.venv) $
    ```
* Install dependencies
    ```
    (.venv) $ pip install -r requirements.txt
    ```

## Command cheatsheet

| Command       | Descripton    |
| :------------- |:-------------|
| `source .venv/bin/activate`      | activates the python virtual environment |
| `dactivate`      | deactivates the python virtual environment (if activated)      |
| `make build` | build the project (in this case renders the corresponding HTML of the tutorial)      |
| `make serve` | spins up a local webserver so you can see how the docs look like locally     |
| `make clean` | removes auto-generated files

