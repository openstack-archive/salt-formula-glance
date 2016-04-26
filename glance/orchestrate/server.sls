{%- if grains['saltversion'] >= "2016.3.0" %}

{# Batch execution is necessary - usable after 2016.3.0 release #}
glance.server:
  salt.state:
    - tgt: 'glance.server'
    - tgt_type: pillar
    - batch: 1
    - sls: glance.server

{%- else %}

{# Workaround for cluster with up to 3 members #}
glance.server.01:
  salt.state:
    - tgt: '*01* and I@glance:server'
    - tgt_type: compound
    - sls: glance.server

glance.server.02:
  salt.state:
    - tgt: '*02* and I@glance:server'
    - tgt_type: compound
    - sls: glance.server

glance.server.03:
  salt.state:
    - tgt: '*03* and I@glance:server'
    - tgt_type: compound
    - sls: glance.server

{%- endif %}

