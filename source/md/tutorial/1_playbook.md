## 1 - Best practices and first playbook

### Prerequisites

Create a directory somewhere in your filesystem named `ansible_1`.

```eval_rst
.. important::
   For the purposes of the tutorial I'll assume it was created on :code:`~/ansible_1`.
```

```bash
(.venv) $ mkdir ~/ansible_1
```

Change directories to the previously created directory.
```bash
(.venv) $ cd ~/ansible_1
(.venv) ~/ansible_1 $
```
```eval_rst
.. note::
   Remember to activate your Python virtual environment with: :code:`$ source ~/.venv/bin/activate`.
```


### Create a role to provision the popular nginx webserver with a sample page

The way to think about a role is as a pre-defined set of tasks that can be controlled with parameters, and included in the plays, which are included on a playbook file.

#### Role `webservers-nginx`

We will name the role to be created as `webservers-nginx`. To proceed let's create the minimum required directory structure for the role:

* Create the file `webservers-nginx/tasks/main.yml`
    ```bash
    (.venv) ~/ansible_1 $ mkdir -p roles/webservers-nginx/tasks/
    (.venv) ~/ansible_1 $ touch roles/webservers-nginx/tasks/main.yml
    ```
* Include the following content in the file `main.yml` (careful with the spaces: YAML is very sensitive with this)
    ```eval_rst
    .. literalinclude:: 1_files/roles/webservers-nginx/tasks/main.yml
       :language: yaml
       :linenos:
    ```
    ```eval_rst
    .. warning::
       Do not use tabs as YAML doesn't support them (see here_).

    .. _here: https://yaml.org/faq.html

    ```
In this example we're just installing the popular webserver nginx, starting it, and enabling the service at boot time (so if we reboot the destination host, this service will be auto-started).

### Create a playbook to use the role

Playbooks are the next level of abstraction towards the infrastructure. They include plays. A play can include tasks, and most importantly, roles.

Until now we don't have any hosts to use as target to run the playbook that will have included the role `webservers-nginx`, that's about to change.

#### Creating a virtual machine using Vagrant

With Vagrant we can spin up virtual machines easily. In this case we will spin up a particular Ubuntu Xenial image. See below:

* Initialize vagrant with an ubuntu image:
    ```bash
    (.venv) ~/ansible_1 $ vagrant init bento/ubuntu-16.04 --minimal
    ```
    ```Note:: This will create the file 'Vagrantfile'.
    ```
* Open the auto-generated `Vagrantfile`, and make sure the content looks like this:
    ```eval_rst
    .. literalinclude:: 1_files/Vagrantfile
       :language: ruby
       :linenos:
    ```
* Start the virtual machine
    ```bash
    (.venv) ~/ansible_1 $ vagrant up
    ```
    ```Note:: Time to get a cup of tea while this is done.
    ```

The steps above will help to create a local virtual machine that we can use to run our Ansible playbook against. This helps in the way that you don't (and shouldn't) need to target your important infrastructure to test a particular playbook (careful with this!).

Because Vagrant is using [VirtualBox](https://www.virtualbox.org/wiki/VirtualBox) as a default virtualizer, if you open the virtual box user interface you should see the machine we just created running.


The Vagrant box we just installed can be found [here](https://app.vagrantup.com/bento/boxes/ubuntu-16.04). This image by default has the following ssh credentials:
* Username: `vagrant`
* Password: `vagrant` (normally)

##### How to SSH into a Vagrant VM

There are at least three ways of doing this
1. Using `vagrant`
   * From the same directory the Vagrantfile is located, run:
     ```
     (.venv) ~/ansible_1 $ vagrant ssh
     ```
2. SSH to the forwarded port on localhost
   * When the machine was provisioned, an output similar to this was shown:
     ```eval_rst
     .. code-block:: bash
        :emphasize-lines: 3,6

        [...]
        ==> default: Forwarding ports...
            default: 22 (guest) => 2222 (host) (adapter 1)
        ==> default: Booting VM...
        ==> default: Waiting for machine to boot. This may take a few minutes...
            default: SSH address: 127.0.0.1:2222
        [...]
     ```
   * This means that to SSH to the vagrant VM you can simply do (using password):
     ```bash
     (.venv) ~/ansible_1 $ ssh -p 2222 vagrant@localhost
     ```
   * Or using the generated private key:
     ```bash
     (.venv) ~/ansible_1 $ ssh -p 2222 -i .vagrant/machines/default/virtualbox/private_key vagrant@localhost
     ```
3. Classic SSH to the host
   * Use the IP provided in the config (using password):
     ```bash
     (.venv) ~/ansible_1 $ ssh vagrant@10.100.0.2
     ```
   * Or using the generated private SSH key:
     ```bash
     (.venv) ~/ansible_1 $ ssh -i .vagrant/machines/default/virtualbox/private_key vagrant@10.100.0.2
     ```

#### Simple inventory file

The playbook we are going to create needs an inventory file, therefore we will create simple one for now (this will be covered better in the next chapter).

* Create the inventor file:
    ```bash
    (.venv) ~/ansible_1 $ touch inventory.ini
    ```
* Include the following content in the file:
    ```eval_rst
    .. literalinclude:: 1_files/inventory.ini
       :language: ini
       :linenos:
    ```

<br/>
After we have the inventory file, and the infrastructure ready, we are ready to create our first playbook.

* Create the file `webservers.yml`:
  ```
  (.venv) ~/ansible_1 $ touch webservers.yml
  ```
* Include the following content in the file:
  ```eval_rst
  .. literalinclude:: 1_files/webservers.yml
     :language: ini
     :linenos:
  ```
* Test the connectivity to the local VM using this ad-hoc command:
  ```bash
  (.venv) ~/ansible_1 $ ansible -i inventory.ini -m ping all
  ```
  **Output**:
  ```eval_rst
  .. literalinclude:: 1_files/ping_output.log
     :linenos:

  ```
* Run the playbook:
  ```bash
  (.venv) ~/ansible_1 $ ansible-playbook -i inventory.ini webservers.yml
  ```
  **Output**:
  ```eval_rst
  .. literalinclude:: 1_files/webservers_output.log
     :linenos:
     :emphasize-lines: 8,14
  ```
* From the following output we can conclude that:
  * The only task that changed our infrastructure was the installation of nginx
  * The installed version of Nginx is enabled by default, therefore Ansible didn't have to enable the service
  * In summary: only 1 item was changed
* If the playbook is ran repeatedly, the state on the remote server should be the same (this is called idempotence).
  ```
  (.venv) ~/ansible_1 $ ansible-playbook -i inventory.ini webservers.yml
  ```
  **Output**:
  ```eval_rst
  .. literalinclude:: 1_files/webservers_idem_output.log
     :linenos:
     :emphasize-lines: 14
  ```

To confirm everything has worked fine, if you access [http://10.100.0.2](http://10.100.0.2) this should display the popular Nginx default welcome page:

```eval_rst
.. figure:: img/2_1_nginx.png
    :width: 400px
    :align: left
    :alt: Nginx default welcome page
    :figclass: rst-figure-alignment

    **Nginx default site (welcome page)**

```
<br/>

### References
- [Python virtual environments](https://docs.python-guide.org/dev/virtualenvs/)
- [Vagrant](https://www.vagrantup.com/)
- [Vagrant cloud](https://app.vagrantup.com/boxes/search)
- [Learn more about Ansible](https://www.ansible.com/how-ansible-works/)
- [Ansible documentation](http://docs.ansible.com/)
