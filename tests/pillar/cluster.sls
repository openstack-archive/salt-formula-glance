glance:
  server:
    enabled: true
    version: liberty
    workers: 8
    database:
      engine: mysql
      host: 127.0.0.1
      port: 3306
      name: glance
      user: glance
      password: password
    rabbit:
      host: 127.0.0.1
    registry:
      host: 127.0.0.1
      port: 9191
    bind:
      address: 127.0.0.1
      port: 9292
    identity:
      engine: keystone
      host: 127.0.0.1
      port: 35357
      user: glance
      password: password
      tenant: service
    message_queue:
      engine: rabbitmq
      host: 127.0.0.1
      port: 5672
      user: openstack
      password: password
      virtual_host: '/openstack'
      ha_queues: true
    storage:
      engine: file
