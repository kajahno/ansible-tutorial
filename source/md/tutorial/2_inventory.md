## 2 - Handling the inventory

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

In any inventory file there are two default groups: `all` (includes all of the hosts), and `none` (includes none of the hosts).

When defining a playbook we can target the right hostgroup in the `hosts` section. Also, we can target the hostgroup `all`, and then `limit` to the group of interest we want when running our playbook, like this:
```bash
(.venv) $ ansible-playbook -i inventory/hosts any_playbook_with_all_hosts.yml --limit atlanta
```
```Note:: Don't actually run that. It's just to illustrate how the command would be structured.
```

In our case let's create an empty inventory file in the following path:
```
(.venv) $ mkdir -p ~/ansible_2/inventory
(.venv) $ touch ~/ansible_2/inventory/hosts
```
Let's include the following content (yes, same file from part 1):
```eval_rst
   .. literalinclude:: 1_files/inventory.ini
      :language: yaml
      :linenos:
```

Also create the role we'll use in this section (again, same role from part 1):
```
(.venv) $ mkdir -p ~/ansible_2/roles/webservers-nginx/tasks/
(.venv) $ touch ~/ansible_2/roles/webservers-nginx/tasks/main.yml
```
Content is:
```eval_rst
   .. literalinclude:: 1_files/roles/webservers-nginx/tasks/main.yml
      :language: yaml
      :linenos:
```


#### Variables management

This section covers the use of variables by our inventory (and playbooks). The areas covered are: variables precedence and secrets via the usage of ansible-vault files (encrypted files to conveniently place secrets)

### Variable precedence

In Ansible there is a quite extensive [variable precedence list](https://gist.github.com/ekreutz/301c3d38a50abbaad38e638d8361a89e). I have found that the easiest ones to work with are as shown below (the higher the number, the higher the precedence):

1. inventory/group_vars/all/
1. inventory/group_vars/group1/
1. inventory/host_vars/host1
1. roles/role1/defaults/
1. roles/role1/vars/
1. group_vars/all/
1. `--extra-vars` (always wins)

Now we will refactor the previously created inventory file to take advantage of this.


#### Cleaning-up the current inventory file
* Make sure the following content is in the file `~/ansible_2/inventory/hosts.ini`:
    ```eval_rst
    .. literalinclude:: 2_files/inventory/hosts.ini
       :language: yaml
       :linenos:
    ```
#### Create files to place variables
* Create a global group_vars file:
    ```bash
    (.venv) ansible_2 $ mkdir -p group_vars/all
    (.venv) ansible_2 $ touch group_vars/all/vars.yml
    ```
* Make sure the content of `group_vars/all/vars.yml` is:
    ```eval_rst
    .. literalinclude:: 2_files/group_vars/all/vars.yml
       :language: yaml
       :linenos:
    ```
* Create the inventory-level group_vars file:
    ```bash
    (.venv) ansible_2 $ mkdir -p inventory/group_vars/all
    (.venv) ansible_2 $ touch inventory/group_vars/all/vars.yml
    ```
* Make sure the content of `inventory/group_vars/all/vars.yml` is:
    ```eval_rst
    .. literalinclude:: 2_files/inventory/group_vars/all/vars.yml
       :language: yaml
       :linenos:
    ```
* Create the inventory group_vars/`GROUP_NAME` vars file:
    ```bash
    (.venv) ansible_2 $ mkdir -p inventory/group_vars/nginx_webservers
    (.venv) ansible_2 $ touch inventory/group_vars/nginx_webservers/vars.yml
    ```
    ```Note:: The name of this directory must match a hostgroup inside the inventory file
    ```
* Make sure the content of `inventory/group_vars/nginx_webservers/vars.yml` is:
    ```eval_rst
    .. literalinclude:: 2_files/inventory/group_vars/nginx_webservers/vars.yml
       :language: yaml
       :linenos:
    ```

#### Create the vagrant box
* Initialize vagrant with an ubuntu image:
    ```bash
    (.venv) ~/ansible_2 $ vagrant init bento/ubuntu-16.04 --minimal
    ```
    ```Note:: This will create the file 'Vagrantfile'.
    ```
* Open the auto-generated `Vagrantfile`, and make sure the content looks like this:
    ```eval_rst
    .. literalinclude:: 2_files/Vagrantfile
       :language: ruby
       :linenos:
    ```
* Start the virtual machine
    ```bash
    (.venv) ~/ansible_2 $ vagrant up
    ```
    ```Note:: Time to get a cup of tea while this is done.
    ```

#### Run the playbook
Similar to part 1, run:
```
(.venv) ~/ansible_2 $ ansible-playbook -i inventory/hosts.ini webservers.yml
```
The output should be:
```eval_rst
.. literalinclude:: 2_files/webservers_output.log
   :linenos:
   :emphasize-lines: 8,14
```

In conclusion, same desired result as in part 1, but now using a nice layout for the inventory.

### Multiple inventories

It's a common design pattern to take into consideration order of precedence of the variables in order to create a directory structure that can support several environments easily. The final layout of the inventory will depend on how you handle your customers, or how many products you deploy on each environment. Let's evaluate two common layouts.

#### Inventory layout 1: multiple environments

Consider the following inventory layout:

```bash
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

In this layout we see how different environments can be defined by just turning our single inventory file into a folder with many small inventories. Things to notice are:
* Variables that apply to all environments can be specified in the `group_vars/all/vars.yml` that is located in the same hierarchy as the `inventory` directory
* Variables that apply for all groups within an environment, can be specified in the files `inventory/[prod, qa, or uat]/group_vars/all/vars.yml`. Useful for defining endpoints attached to a specific environment, for example.
* Variables that apply to a certain hostgroup, in the files `inventory/[prod, qa, or uat]/group_vars/[hostgroup]/vars.yml`. An extension of this approach is to also add the `hostvars` in parallel to the `group_vars`, but since that's a bit tedious, you might want to automate that task.

Another variation of this layout is the following:
```bash
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

#### Inventory layout 2: multiple environments, multiple customers or deployments

Consider the following inventory layout:
```bash
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

It is pretty much the same as the last example of the multiple environments section, just adding another folder. At the end of the day the decision of the type of inventory layout will depend on the actual problem you're trying to solve. Just keep in mind that this is very flexible, and that the variable precedence levels can come very handy.


For our purposes we'll keep using the simple layout: a single environment:
```bash
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

### Vault and secrets

Ansible includes a tool that enables the encryption/decryption of files, making it very convenient to work with secrets. This tool is called [Ansible Vault](https://docs.ansible.com/ansible/2.5/user_guide/vault.html).

Normally makes more sense to just encrypt the files that contain sensitive data. However, with Ansible Vault you can encrypt any file.

The Ansible Vault has many features. In this tutorial we'll just focus on encryption and decryption of files as normally this is enough to get started.

#### Encrypt a file

```
ansible-vault encrypt path/to/file
```
```Note:: By default if there are no saved passwords, the tool will prompt for a new password to be entered.
```

#### Decrypt file

```
ansible-vault decrypt path/to/file
```

<br/>
In our case we will modify the current setup in the following way:

* We will enable simple HTTP authentication in our nginx server
* We will create a vault file to create a variable that will hold the password
* We will encrypt that vault file so it's safely stored in the repository


### Including vault into our environment

* Make sure the content of the file `~/ansible_2/roles/webservers-nginx/tasks/main.yml` is:
    ```eval_rst
    .. literalinclude:: 2_files/roles/webservers-nginx/tasks/main.yml
       :language: yaml
       :linenos:
       :emphasize-lines: 3,14,20,25,29,37
    ```
    ```Note:: The new tasks are highlighted
    ```
    Things to notice here are:

    * The check of variables at the beginning will provide a fail-fast mechanism (won't run further tasks if the vars are not provided)
    * Variables are normally rendered by enveloping them between double quotes (lines 33 and 34), and double curly braces (this is a convention from the Python templating engine [Jinja](http://jinja.pocoo.org/))
    * List of modules used: [assert](https://docs.ansible.com/ansible/latest/modules/assert_module.html), [apt](https://docs.ansible.com/ansible/latest/modules/apt_module.html), [systemd](https://docs.ansible.com/ansible/latest/modules/systemd_module.html), [pip](https://docs.ansible.com/ansible/latest/modules/pip_module.html), [htpasswd](https://docs.ansible.com/ansible/latest/modules/htpasswd_module.html), [blockinfile](https://docs.ansible.com/ansible/latest/modules/blockinfile_module.html).
* Make sure the content of the file `~/ansible_2/roles/webservers-nginx/defaults/main.yml` is:
    ```eval_rst
    .. literalinclude:: 2_files/roles/webservers-nginx/defaults/main.yml
       :language: yaml
       :linenos:
    ```
    ```Note:: We give the blank value of the variables, so the role fails fast if the vars are not provided
    ```
* Make sure the content of the file `~/ansible_2/inventory/group_vars/nginx_webservers/vars.yml` is:
    ```eval_rst
    .. literalinclude:: 2_files/inventory/group_vars/nginx_webservers/vars.yml
       :language: yaml
       :linenos:
       :emphasize-lines: 7
    ```
* Create the vault file for the host group `nginx_webservers`:
    ```bash
    (.venv) ansible_2 $ touch inventory/group_vars/nginx_webservers/vault.yml
    ```
* Make sure the content of the file `~/ansible_2/inventory/group_vars/nginx_webservers/vault.yml` is:
    ```eval_rst
    .. literalinclude:: 2_files/vault_unencrypted.log
       :language: yaml
       :linenos:
    ```
* Encrypt the vault file:
    ```bash
    (.venv) ansible_2 $ ansible-vault encrypt inventory/group_vars/nginx_webservers/vault.yml
    ```
    ```Note:: You should see 'Encryption successful' as a result of the operation. Remember this password!
    ```
* Verify the content of the now encrypted file. You should see a similar output to the following:
    ```eval_rst
    .. literalinclude:: 2_files/inventory/group_vars/nginx_webservers/vault.yml
       :language: yaml
    ```

After doing this we can run again the playbook as usual.

#### Run playbook using the usual command

Command:
```bash
(.venv) ansible_2 $ ansible-playbook -i inventory/hosts.ini webservers.yml
```

The output should be an error similar to the following:
```
PLAY [all] **************************************************************************************
ERROR! Attempting to decrypt but no vault secrets found
```

#### Run playbook asking for the vault password

Command:
```bash
(.venv) ansible_2 $ ansible-playbook -i inventory/hosts.ini webservers.yml --ask-vault-pass
```

Now Ansible will prompt for the vault password. After providing the password, now try to access the local nginx webserver [http://10.100.0.2](http://10.100.0.2). It should prompt using the basic HTTP authentication dialog box (credentials are `admin:admin`), similar to this one:
```eval_rst
.. figure:: img/2_2_nginx.png
    :width: 400px
    :align: left
    :alt: Nginx basic HTTP auth
    :figclass: rst-figure-alignment

    **Nginx basic HTTP auth**
```

##### Verify htpasswd file

If you want to verify how this .htpasswd file is looking in the server, you can do so by:
* Running a simple SSH command as follows:
  ```bash
  (.venv) ansible_2 $ ssh -i .vagrant/machines/default/virtualbox/private_key vagrant@10.100.0.2 "cat /etc/nginx/.htpasswd"
  ```
  The file should have an output similar to:
  ```
  admin:$1$SIBL4POk$MlscIbwWALKAWY.TgbC3a.
  ```
* Running an Ansible ad-hoc command to check the content of the file:
  ```bash
  (.venv) ansible_2 $ ansible -i inventory/hosts.ini -a "cat /etc/nginx/.htpasswd" all --ask-vault-pass
  ```
  The output should be similar to:
  ```
  Vault password:
  127.0.0.1 | CHANGED | rc=0 >>
  admin:$1$SIBL4POk$MlscIbwWALKAWY.TgbC3a.
  ```
  ```Note:: Notice how easy is to send ad-hoc remote commands using Ansible (taking advantage of the SSH configuration, we just need to focus on the remote action)
  ```

#### Run using a file with the vault password in it

Create a file and store the password in it:
```bash
(.venv) ansible_2 $ echo "vaultpassword" > vaultPasswordFile
```
```Note:: I'm assuming the password is 'vaultpassword'
```

Run the playbook specifying the file:
```bash
(.venv) ansible_2 $ ansible-playbook -i inventory/hosts.ini webservers.yml --vault-password-file ./vaultPasswordFile
```

The playbook should run successfully.

#### Run using the vault password file environment variable

Export the location of the password file as an environment variable:
```bash
(.venv) ansible_2 $ export ANSIBLE_VAULT_PASSWORD_FILE=$( pwd )/vaultPasswordFile
```
```Note:: The value of ANSIBLE_VAULT_PASSWORD_FILE should be the absolute path to the file (hence we're using 'pwd' to obtain it)
```

Run the playbook without specifying the vault password file:
```
(.venv) ansible_2 $ ansible-playbook -i inventory/hosts.ini webservers.yml
```

The playbook should run successfully.

##### Bonus: specify the ANSIBLE_VAULT_PASSWORD_FILE var without exporting it

Just run:
```bash
(.venv) ansible_2 $ ANSIBLE_VAULT_PASSWORD_FILE=$( pwd )/vaultPasswordFile ansible-playbook -i inventory/hosts.ini webservers.yml
```
```Note:: In modern shells (such as bash), you can pass any environment variable to a desired command
```

<br/>

Until here you have the knowledge to spin up Ansible, and configure it according to your requirements. It is true that the role we just created was very simple, however there is extended documentation regarding roles, specially using [Ansible Galaxy](https://galaxy.ansible.com/), which won't be cover in this tutorial.

Let's get to know more about Ansible in the next modules!

<br/>

### References
- [Ansible Vault](https://docs.ansible.com/ansible/latest/user_guide/vault.html)
- [Jinja](http://jinja.pocoo.org/docs/2.10/ )
- [Nginx](https://www.nginx.com/)
- [Basic HTTP authentication on Nginx](https://docs.nginx.com/nginx/admin-guide/security-controls/configuring-http-basic-authentication/#configuring-nginx-and-nginx-plus-for-http-basic-authentication)
- [Ansible environment variables](https://docs.ansible.com/ansible/latest/reference_appendices/config.html?highlight=ansible_vault_password_file#envvar-ANSIBLE_VAULT_PASSWORD_FILE)
