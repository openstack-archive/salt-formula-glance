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
        audit:
          enabled: false


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


Enable auditing filter, ie: CADF

.. code-block:: yaml

    glance:
      server:
        audit:
          enabled: true
      ....
          filter_factory: 'keystonemiddleware.audit:filter_factory'
          map_file: '/etc/pycadf/glance_api_audit_map.conf'
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
          engine: rbd,http
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
