==================
Glance Image Store
==================

The Glance project provides services for discovering, registering, and
retrieving virtual machine images. Glance has a RESTful API that allows
querying of VM image metadata as well as retrieval of the actual image.

Usage
=====

Import new public image

.. code-block:: yaml

    glance image-create --name 'Windows 7 x86_64' --is-public true --container-format bare --disk-format qcow2  < ./win7.qcow2

Change new image's disk properties

.. code-block:: yaml

    glance image-update "Windows 7 x86_64" --property hw_disk_bus=ide

Change new image's NIC properties

.. code-block:: yaml

    glance image-update "Windows 7 x86_64" --property hw_vif_model=rtl8139

Sample pillar
=============

.. code-block:: yaml

    glance:
      server:
        enabled: true
        version: juno
        workers: 8
        policy:
          publicize_image:
            - "role:admin"
            - "role:image_manager"
        database:
          engine: mysql
          host: 127.0.0.1
          port: 3306
          name: glance
          user: glance
          password: pwd
        identity:
          engine: keystone
          host: 127.0.0.1
          port: 35357
          tenant: service
          user: glance
          password: pwd
        message_queue:
          engine: rabbitmq
          host: 127.0.0.1
          port: 5672
          user: openstack
          password: pwd
          virtual_host: '/openstack'
        storage:
          engine: file
        images:
        - name: "CirrOS 0.3.1"
          format: qcow2
          file: cirros-0.3.1-x86_64-disk.img
          source: http://cdn.download.cirros-cloud.net/0.3.1/cirros-0.3.1-x86_64-disk.img
          public: true


Client-side RabbitMQ HA setup

.. code-block:: yaml

    glance:
      server:
        ....
        message_queue:
          engine: rabbitmq
          members:
            - host: 10.0.16.1
            - host: 10.0.16.2
            - host: 10.0.16.3
          user: openstack
          password: pwd
          virtual_host: '/openstack'
        ....


Keystone and cinder region
============================

.. code-block:: yaml

    glance:
      server:
        enabled: true
        version: kilo
        ...
        identity:
          engine: keystone
          host: 127.0.0.1
          region: RegionTwo
        ...


Ceph integration glance
=======================

.. code-block:: yaml

    glance:
      server:
        enabled: true
        version: juno
        storage:
          engine: rbd
          user: glance
          pool: images
          chunk_size: 8
          client_glance_key: AQDOavlU6BsSJhAAnpFR906mvdgdfRqLHwu0Uw==

* http://ceph.com/docs/master/rbd/rbd-openstack/

Documentation and Bugs
============================

To learn how to deploy OpenStack Salt, consult the documentation available
online at:

    https://wiki.openstack.org/wiki/OpenStackSalt

In the unfortunate event that bugs are discovered, they should be reported to
the appropriate bug tracker. If you obtained the software from a 3rd party
operating system vendor, it is often wise to use their own bug tracker for
reporting problems. In all other cases use the master OpenStack bug tracker,
available at:

    http://bugs.launchpad.net/openstack-salt

Developers wishing to work on the OpenStack Salt project should always base
their work on the latest formulas code, available from the master GIT
repository at:

    https://git.openstack.org/cgit/openstack/salt-formula-glance

Developers should also join the discussion on the IRC list, at:

    https://wiki.openstack.org/wiki/Meetings/openstack-salt

Development and testing
=======================

Development and test workflow with `Test Kitchen <http://kitchen.ci>`_ and
`kitchen-salt <https://github.com/simonmcc/kitchen-salt>`_ provisioner plugin.

Test Kitchen is a test harness tool to execute your configured code on one or more platforms in isolation.
There is a ``.kitchen.yml`` in main directory that defines *platforms* to be tested and *suites* to execute on them.

Kitchen CI can spin instances locally or remote, based on used *driver*.
For local development ``.kitchen.yml`` defines a `vagrant <https://github.com/test-kitchen/kitchen-vagrant>`_ or
`docker  <https://github.com/test-kitchen/kitchen-docker>`_ driver.

To use backend drivers or implement your CI follow the section `INTEGRATION.rst#Continuous Integration`__.

A listing of scenarios to be executed:

.. code-block:: shell

  $ kitchen list

  Instance                    Driver   Provisioner  Verifier  Transport  Last Action

  cluster-ubuntu-1404      Vagrant  SaltSolo     Inspec    Ssh        <Not Created>
  cluster-ubuntu-1604      Vagrant  SaltSolo     Inspec    Ssh        <Not Created>
  cluster-centos-71        Vagrant  SaltSolo     Inspec    Ssh        <Not Created>
  single-ceph-ubuntu-1404  Vagrant  SaltSolo     Inspec    Ssh        <Not Created>
  single-ceph-ubuntu-1604  Vagrant  SaltSolo     Inspec    Ssh        <Not Created>
  single-ceph-centos-71    Vagrant  SaltSolo     Inspec    Ssh        <Not Created>
  single-ubuntu-1404       Vagrant  SaltSolo     Inspec    Ssh        <Not Created>
  single-ubuntu-1604       Vagrant  SaltSolo     Inspec    Ssh        <Not Created>
  single-centos-71         Vagrant  SaltSolo     Inspec    Ssh        <Not Created>

The `Busser <https://github.com/test-kitchen/busser>`_ *Verifier* is used to setup and run tests
implementated in `<repo>/test/integration`. It installs the particular driver to tested instance
(`Serverspec <https://github.com/neillturner/kitchen-verifier-serverspec>`_,
`InSpec <https://github.com/chef/kitchen-inspec>`_, Shell, Bats, ...) prior the verification is executed.


Usage:

.. code-block:: shell

 # list instances and status
 kitchen list

 # manually execute integration tests
 kitchen [test || [create|converge|verify|exec|login|destroy|...]] [instance] -t tests/integration

 # use with provided Makefile (ie: within CI pipeline)
 make kitchen

