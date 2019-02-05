# What is Ansible?

From the [Ansible documentation](https://docs.ansible.com/ansible/latest/index.html#about-ansible):

```eval_rst

.. note::

   Ansible is an IT automation tool. It can configure systems, deploy software, and orchestrate more advanced IT tasks such as continuous deployments or zero downtime rolling updates.

   Ansible’s main goals are simplicity and ease-of-use. It also has a strong focus on security and reliability, featuring a minimum of moving parts, usage of OpenSSH for transport (with other transports and pull modes as alternatives), and a language that is designed around auditability by humans–even those not familiar with the program. 

```


## Agentless

Ansible, as opposite to many other tools, does not require a remote agent to be running on the remote hosts. The only real requirement is that the remote hosts are reachable via SSH, and to make the most out of the tool you'd need Python as well.

```important:: **In summary**: Ansible requires SSH and Python on the remote hosts.
```

## Expansion of the tool

Even though Ansible provides many modules out of the box that will help to perform many of the common provisioning and deployment tasks, it is very easy to extend and adapt to a custom need (developing a module, or even a plugin).

The development is done inside a Python ecosystem, making it easy to work with in many operating systems.

## Declarative vs Imperative model 

In Ansible the syntax is declarative, meaning you specify **what** things should look like on the remote hosts and Ansible will make it happen. The other common syntax is imperative, meaning you specify **how** things should be performed on the remote hosts (such as in Chef).

## Tools similar to Ansible

Including but not limited to the following:

* [Chef](https://www.chef.io/)
* [Puppet](https://puppet.com/)
* [Terraform](https://www.terraform.io/)
* [GitLab](https://about.gitlab.com/)
* [Saltstack](https://www.saltstack.com/)
* [Rudder](https://www.rudder.io/en/)
