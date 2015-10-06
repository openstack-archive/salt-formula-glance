==================
Glance Image Store
==================

The Glance project provides services for discovering, registering, and retrieving virtual machine images. Glance has a RESTful API that allows querying of VM image metadata as well as retrieval of the actual image.

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

Read more
=========

* http://docs.openstack.org/image-guide/content/ch_obtaining_images.html
* http://cloud-images.ubuntu.com/precise/current/
* http://fedoraproject.org/en/get-fedora#clouds
* http://www.cloudbase.it/ws2012r2/
* http://docs.openstack.org/cli-reference/content/glanceclient_commands.html
