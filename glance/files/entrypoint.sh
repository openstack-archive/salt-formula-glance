{%- from "glance/map.jinja" import server with context -%}
#!/bin/bash -e

salt-call --local --retcode-passthrough state.highstate
service {{ server.services }} stop || true

su glance --shell=/bin/sh -c 'glance-manage db_sync'

su glance --shell=/bin/sh -c '/usr/bin/python /usr/bin/glance-api --config-file=/etc/glance/glance-api.conf --log-file=/var/log/glance/glance-api.log'

{#-
vim: syntax=jinja
-#}