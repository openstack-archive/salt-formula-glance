
include:
{%- if pillar.glance.server.enabled %}
- glance.server
{%- endif %}
