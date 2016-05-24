{%- from "glance/map.jinja" import server with context -%}
#!/bin/bash -e

cat /srv/salt/pillar/glance-server.sls | envsubst > /tmp/glance-server.sls
mv /tmp/glance-server.sls /srv/salt/pillar/glance-server.sls

salt-call --local --retcode-passthrough state.highstate

{% for service in server.services %}
service {{ service }} stop || true
{% endfor %}

if [ "$1" == "api" ]; then
    echo "starting glance-api"
    su glance --shell=/bin/sh -c '/usr/bin/glance-api --config-file=/etc/glance/glance-api.conf --log-file=/var/log/glance/glance-api.log'
elif [ "$1" == "registry" ]; then
    echo "starting glance-registry"
    su glance --shell=/bin/sh -c '/usr/bin/glance-registry --config-file=/etc/glance/glance-registry.conf --log-file=/var/log/glance/glance-registry.log'
else
    echo "No parameter submitted, don't know what to start"
fi

{#-
vim: syntax=jinja
-#}
