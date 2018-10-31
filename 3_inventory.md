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
* Part 4: getting to know the internals
    * Create a custom module
* Part 5: make custom components 1
    * Create a custom filter plugin
* Part 6: make custom components 2
    * Create a custom lookup plugin
* Part 7: make roles that never fail
    * Add tests to our role


## Part 3: handling the inventory

### Introdution

This section will cover how to work with static inventory files. [Dynamic inventory files](https://docs.ansible.com/ansible/latest/user_guide/intro_dynamic_inventory.html#intro-dynamic-inventory) are out of this scope. 

When working with inventory files, regardless of the type, there are two main abstractions to consider: hosts management and variables management.

#### Hosts management

Inside the inventory file there can be groups, groups of groups, and variables. Since the variable precedence in Ansible is quite complex, we will handle the variables separately. There are many formats for a valid inventory file (depending on the inventory plugin being used). In this case we will focus in the INI-like format, since I believe it's the easiest to work with when dealing with static inventories.

Consider the following content in the inventory file (taken from [here](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html#groups-of-groups-and-group-variables)):
```
[atlanta]
host1
host2

[raleigh]
host2
host3

[southeast:children]
atlanta
raleigh
```

In any inventory file there are two default groups: all (includes all of the hosts), and none (includes none of the hosts).

This means that when defining a playbook we can target the right hostgroup in the `hosts` section. Also we can target `all`, and then `limit` to the group of interest we want, like this:
```
ansible-playbook -i inventory/hosts any_playbook_with_all_hosts.yml --limit atlanta
``` 

In our case let's create an inventory file in the following path:
```
mkdir -p ~/ansible/inventory
touch ~/ansible/inventory/hosts
```

#### Variables management

This section covers the handling of variables within our inventory. These variables include: variables precedence handling and secrets (such as encrypted files to store passwords) 

### Variable precedence

In Ansible there is a quite extended [variable precedence](https://gist.github.com/ekreutz/301c3d38a50abbaad38e638d8361a89e). I have found that the easiest ones to work with are as shown below:
* inventory/group_vars/all/
* inventory/group_vars/group1/
* inventory/host_vars/host1
* roles/role1/defaults/
* roles/role1/vars/
* group_vars/all/
* --extra-vars (always win)

Now we will refactor the previously created inventory file to take advantage of this.


#### Clean-up the inventory file
* Make sure the following content is in the file `~/ansible/inventory/hosts`:
    ```
    [nginx_webservers]
    127.0.0.1
    ```
#### Create the variable files 
* Create the general group_vars file:
    ```
    mkdir -p group_vars/all
    touch group_vars/all/vars.yml
    ```
* Make sure the content of `group_vars/all/vars.yml` is:
    ```
    ---

    ansible_connection: ssh
    ansible_ssh_common_args: '-o StrictHostKeyChecking=no'
    ```
* Create the inventory group_vars file:
    ```
    mkdir -p inventory/group_vars/all
    touch inventory/group_vars/all/vars.yml   
    ```
* Make sure the content of `inventory/group_vars/all/vars.yml` is:
    ```
    ---

    ansible_ssh_port: 22
    ```
* Create the inventory group_vars/group file:
    ```
    mkdir -p inventory/group_vars/nginx_webservers
    touch inventory/group_vars/nginx_webservers/vars.yml
    ```
    > Te name of this directory must match a group name in the inventory file, otherwise it will be ignored by Ansible
* Make sure the content of `inventory/group_vars/nginx_webservers/vars.yml` is:
    ```
    ---

    ansible_ssh_port: 2222
    ansible_user: vagrant
    ansible_ssh_pass: vagrant
    ```
    > Notice how we are overriding the `ansible_ssh_port` specified as 22 in the more general vars file. This is to show that the precedence is maintained. 

#### Run the playbook again
Same as shown at the end of part to, run:
```
ansible-playbook -i inventory/hosts webservers.yml 
```

The output should be the same. 

### Multiple inventories

It's a common design pattern to support several environments using Ansible. The final layout of the inventory will depend on how you handle your customers, or how many products you deploy on each environment. Let's evaluate two main layouts.

#### Inventory layout 1: multiple environments

Consider the following inventory layout:

```
inventory
├── prod
│   ├── group_vars
│   │   ├── all
│   │   │   └── vars.yml
│   │   └── nginx_webservers
│   │       └── vars.yml
│   └── hosts
├── qa
│   ├── group_vars
│   │   ├── all
│   │   │   └── vars.yml
│   │   └── nginx_webservers
│   │       └── vars.yml
│   └── hosts
└── uat
    ├── group_vars
    │   ├── all
    │   │   └── vars.yml
    │   └── nginx_webservers
    │       └── vars.yml
    └── hosts
group_vars
└── all
    └── vars.yml
```

In this layout we see how we define different environments by just wrapping our single inventory into a folder. Variables that apply to all environments can be specified in the `group_vars/all/vars.yml` that is located in the same hierarchy as the `inventory` directory. We can then specify variables specific for each environment, but for all groups, in the files `inventory/[prod, qa, or uat]/group_vars/all/vars.yml` (maybe different credentials per environment). Similarly, we can define variables specifically for the hostgroups, in the files `inventory/[prod, qa, or uat]/group_vars/[hostgroup]/vars.yml`. We could also add the `hostvars` in parallel to the `group_vars`, but since that's a bit tedious, you might want to automate that task.

A variation of this layout is the following:
```
inventory
├── group_vars
│   ├── all
│   │   └── vars.yml
│   ├── nginx_webservers
│   │   └── vars.yml
│   ├── prod
│   │   └── vars.yml
│   ├── qa
│   │   └── vars.yml
│   └── uat
│       └── vars.yml
├── hosts-prod
├── hosts-qa
└── hosts-uat
group_vars
└── all
    └── vars.yml
```

At the end of the day the decision of the type of inventory will depend on the actual problem you're trying to solve. Just keep in mind that this is very flexible, and that the variable precedence levels can come very handy.

#### Inventory layout 2: multiple environments, multiple customers or deployments

Consider the following inventory layout:
```
inventory/
├── customer1
│   ├── group_vars
│   │   ├── all
│   │   │   └── vars.yml
│   │   ├── nginx_webservers
│   │   │   └── vars.yml
│   │   ├── prod
│   │   │   └── vars.yml
│   │   ├── qa
│   │   │   └── vars.yml
│   │   └── uat
│   │       └── vars.yml
│   ├── hosts-prod
│   ├── hosts-qa
│   └── hosts-uat
├── customer2
│   ├── group_vars
│   │   ├── all
│   │   │   └── vars.yml
│   │   ├── nginx_webservers
│   │   │   └── vars.yml
│   │   ├── prod
│   │   │   └── vars.yml
│   │   ├── qa
│   │   │   └── vars.yml
│   │   └── uat
│   │       └── vars.yml
│   ├── hosts-prod
│   ├── hosts-qa
│   └── hosts-uat
└── customer3
    ├── group_vars
    │   ├── all
    │   │   └── vars.yml
    │   ├── nginx_webservers
    │   │   └── vars.yml
    │   ├── prod
    │   │   └── vars.yml
    │   ├── qa
    │   │   └── vars.yml
    │   └── uat
    │       └── vars.yml
    ├── hosts-prod
    ├── hosts-qa
    └── hosts-uat
group_vars
└── all
    └── vars.yml

```

It is pretty much the same as the last example of the multiple environments section, just with another level of wrapping. 

<br/>
<br/>

For our purposes we'll keep using the simple layout: a single customer, single environment:
```
inventory
├── group_vars
│   ├── all
│   │   └── vars.yml
│   └── nginx_webservers
│       └── vars.yml
└── hosts
group_vars
└── all
    └── vars.yml
```

Let's talk about secrets now!




## [Next up -> Part 3: handling the inventory](#)

### References
- [Python virtual environments](https://docs.python-guide.org/dev/virtualenvs/)
- [Vagrant](https://www.vagrantup.com/)
- [Vagrant cloud](https://app.vagrantup.com/boxes/search)
- [Learn more about Ansible](https://www.ansible.com/how-ansible-works/)
- [Ansible documentation](http://docs.ansible.com/)
