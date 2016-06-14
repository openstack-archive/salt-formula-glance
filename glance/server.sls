{%- from "glance/map.jinja" import server with context %}
{%- if server.enabled %}

glance_packages:
  pkg.installed:
  - names: {{ server.pkgs }}

{%- if not salt['user.info']('glance') %}
glance_user:
  user.present:
    - name: glance
    - home: /var/lib/glance
    - uid: 302
    - gid: 302
    - shell: /bin/false
    - system: True
    - require_in:
      - pkg: glance_packages

glance_group:
  group.present:
    - name: glance
    - gid: 302
    - system: True
    - require_in:
      - pkg: glance_packages
      - user: glance_user
{%- endif %}

/etc/glance/glance-cache.conf:
  file.managed:
  - source: salt://glance/files/{{ server.version }}/glance-cache.conf.{{ grains.os_family }}
  - template: jinja
  - require:
    - pkg: glance_packages

/etc/glance/glance-registry.conf:
  file.managed:
  - source: salt://glance/files/{{ server.version }}/glance-registry.conf.{{ grains.os_family }}
  - template: jinja
  - require:
    - pkg: glance_packages

/etc/glance/glance-scrubber.conf:
  file.managed:
  - source: salt://glance/files/{{ server.version }}/glance-scrubber.conf.{{ grains.os_family }}
  - template: jinja
  - require:
    - pkg: glance_packages

/etc/glance/glance-api.conf:
  file.managed:
  - source: salt://glance/files/{{ server.version }}/glance-api.conf.{{ grains.os_family }}
  - template: jinja
  - require:
    - pkg: glance_packages

/etc/glance/glance-api-paste.ini:
  file.managed:
  - source: salt://glance/files/{{ server.version }}/glance-api-paste.ini
  - template: jinja
  - require:
    - pkg: glance_packages

{%- if not grains.get('noservices', False) %}

glance_services:
  service.running:
  - enable: true
  - names: {{ server.services }}
  - watch:
    - file: /etc/glance/glance-api.conf
    - file: /etc/glance/glance-registry.conf
    - file: /etc/glance/glance-api-paste.ini

glance_install_database:
  cmd.run:
  - name: glance-manage db_sync
  - require:
    - service: glance_services

{%- endif %}

{%- if server.metadata is defined %}

/etc/glance/metadefs:
  file.recurse:
  - source: salt://glance/files/{{ server.version }}/metadefs
  - include_empty: True
  - require:
    - pkg: glance_packages
    - cmd: glance_install_database

load_metadefs:
  cmd.run:
    - name: 'source /root/keystonerc; glance-manage db_load_metadefs && echo -n "\nchanged=yes"'
    - stateful: True
    - require:
      - file: /etc/glance/metadefs
      - pkg: glance_packages

{%- endif %}

{%- if grains.get('virtual_subtype', None) == "Docker" %}

glance_entrypoint:
  file.managed:
  - name: /entrypoint.sh
  - template: jinja
  - source: salt://glance/files/entrypoint.sh
  - mode: 755

{%- endif %}

/var/lib/glance/images:
  file.directory:
  - mode: 755
  - user: glance
  - group: glance
  - require:
    - pkg: glance_packages

{%- for image in server.get('images', []) %}

glance_download_{{ image.name }}:
  cmd.run:
  - name: wget {{ image.source }}
  - unless: "test -e {{ image.file }}"
  - cwd: /srv/glance
  - require:
    - file: /srv/glance

glance_install_{{ image.name }}:
  cmd.wait:
  - name: source /root/keystonerc; glance image-create --name '{{ image.name }}' --is-public {{ image.public }} --container-format bare --disk-format {{ image.format }} < {{ image.file }}
  - cwd: /srv/glance
  - require:
    - service: glance_services
  - watch:
    - cmd: glance_download_{{ image.name }}

{%- endfor %}

{%- for image_name, image in server.get('image', {}).iteritems() %}

glance_download_{{ image_name }}:
  cmd.run:
  - name: wget {{ image.source }}
  - unless: "test -e {{ image.file }}"
  - cwd: /srv/glance
  - require:
    - file: /srv/glance

glance_install_image_{{ image_name }}:
  cmd.run:
  - name: source /root/keystonerc; glance image-create --name '{{ image_name }}' --is-public {{ image.public }} --container-format bare --disk-format {{ image.format }} < /srv/glance/{{ image.file }}
  - require:
    - service: glance_services
    - cmd: glance_download_{{ image_name }}
  - unless:
    - cmd: source /root/keystonerc && glance image-list | grep {{ image_name }}

{%- endfor %}

{%- if server.policy is defined %}

{%- for key, policy in server.policy.iteritems() %}

policy_{{ key }}:
  file.replace:
  - name: /etc/glance/policy.json
  - pattern: "[\"']{{ key }}[\"']:.*"
  {# unfortunatately there's no jsonify filter so we have to do magic :-( #}
  - repl: '"{{ key }}": {% if policy is iterable %}[{%- for rule in policy %}"{{ rule }}"{% if not loop.last %}, {% endif %}{%- endfor %}]{%- else %}"{{ policy }}"{%- endif %},'

{%- endfor %}

{%- endif %}

{%- endif %}
