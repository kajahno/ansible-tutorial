# Terminology

This section will provide with the minimum theory required to work with Ansible.

There are two main modes in which Ansible can be run: ad-hoc mode and playbook mode. We will make more emphasis in the playbook mode. 

### Ansible Playbook 

Drawn on a diagram the architecture of Ansible running in playbook-mode would look similar to the following:

![](diagrams/ansible-arch.png)

#### Basic directory structure
Following the provided example in the [documentation](https://docs.ansible.com/ansible/2.7/user_guide/playbooks_reuse_roles.html), the directory structure of an ansible project can be as follows:
```
site.yml
webservers.yml
fooservers.yml
roles/
   common/
     tasks/
     handlers/
     files/
     templates/
     vars/
     defaults/
     meta/
   webservers/
     tasks/
     defaults/
     meta/
```

#### Inventory

Is where the list of hosts that can be targeted lives.

#### Ansible Playbook file

It's either a `.yml` or `.yaml` file that contains one or more plays. On the list avobe the files `site.yml`, `webserver.yml`, and `fooservers.yml` are playbooks.

#### Plays

Can contain one or more tasks, and one or more roles.

#### Roles

Contain a set of tasks with enriched data that can be very useful to be reused, such as templates (for services configuration files, for example). On the list above the roles are: `common` and `webservers`.

Focusing on the `roles` directory for a moment, let's point out some things:
* The minimum set of directories that you need for any Ansible role, using the role `common` as an example, is:
    ```
    roles
    └── common
        └── tasks
            └── main.yml

    2 directories, 1 file
    ```
* The file `tasks/main.yml` will be the entry point for the role.
* I usually start filling up this `main.yml` file and then create all other files when necessary (for example, if I need a template I'd create a `common/templates/` directory and place it there).

**Why use this directory structure on the roles and not something else?**

The Ansible modules will typically find files or templates on a specific directory, therefore if the directory doesn't exist you'll get an error.


#### Tasks

Are the minimum unit of work in Ansible. Ultimately everything is broken down into a task. A task normally includes a module.

The tasks could either be within a role (in the file ROLENAME/tasks/main.yml) or directly in a play (by using the object `tasks`)
> ROLENAME is just a placeholder, making reference to the name of the role.

#### Module

Units that control certain actions available to be performed by Ansible on the target host. This is where Ansible gets its superpowers from.


### Ansible ad-hoc

Servers as a way to perform one-off tasks against a group of hosts. Examples: install a apt package on a certain group of hosts.

