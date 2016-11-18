glance:
  server:
    enabled: true
    version: liberty
    database:
      engine: mysql
      host: localhost
      port: 3306
      name: glance
      user: glance
      password: password
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
      region: RegionOne
      tenant: service
    message_queue:
      engine: rabbitmq
      host: 127.0.0.1
      port: 5672
      user: openstack
      password: password
      virtual_host: '/openstack'
    storage:
      engine: rbd
      user: glance
      pool: glance-images
      chunk_size: 8
      client_glance_key: AQAqcXhWk+3UARAAGmV4USB6I7wLJ/W+dVbUWw==