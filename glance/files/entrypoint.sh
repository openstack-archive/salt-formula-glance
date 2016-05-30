{%- from "glance/map.jinja" import server with context -%}
#!/bin/bash -e

cat /srv/salt/pillar/glance-server.sls | envsubst > /tmp/glance-server.sls
mv /tmp/glance-server.sls /srv/salt/pillar/glance-server.sls

salt-call --local --retcode-passthrough state.highstate

{% for service in server.services %}
service {{ service }} stop || true
{% endfor %}

#Fix ownership for api.log file
chown glance:glance /var/log/glance/*

if [ "$1" == "api" ]; then
    echo "starting glance-api"
    su glance --shell=/bin/sh -c '/usr/bin/glance-api --config-file=/etc/glance/glance-api.conf'
elif [ "$1" == "registry" ]; then
    echo "starting glance-registry"
    su glance --shell=/bin/sh -c '/usr/bin/glance-registry --config-file=/etc/glance/glance-registry.conf'
else
    echo "No parameter submitted, don't know what to start" 1>&2
fi

{#-
vim: syntax=jinja
-#}
