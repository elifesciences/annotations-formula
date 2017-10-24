annotations-nginx-vhost:
    file.managed:
        - name: /etc/nginx/sites-enabled/annotations.conf
        - source: salt://annotations/config/etc-nginx-sites-enabled-annotations.conf
        - template: jinja
        - require:
            - nginx-config
        - watch-in:
            - nginx-service

annotations-repository:
    builder.git_latest:
        - name: git@github.com:elifesciences/annotations.git
        - identity: {{ pillar.elife.projects_builder.key or '' }}
        - rev: {{ salt['elife.rev']() }}
        - branch: {{ salt['elife.branch']() }}
        - target: /srv/annotations/
        - force_fetch: True
        - force_checkout: True
        - force_reset: True
        - fetch_pull_requests: True
        - require:
            - cmd: composer

    file.directory:
        - name: /srv/annotations
        - user: {{ pillar.elife.deploy_user.username }}
        - group: {{ pillar.elife.deploy_user.username }}
        - recurse:
            - user
            - group
        - require:
            - builder: annotations-repository

config-file:
    file.managed:
        - name: /srv/annotations/app/config/parameters.yml
        - source: salt://annotations/config/srv-annotations-app-config-parameters.yml
        - template: jinja
        - user: {{ pillar.elife.deploy_user.username }}
        - group: {{ pillar.elife.deploy_user.username }}
        - require:
            - file: annotations-repository

composer-install:
    cmd.run:
        {% if pillar.elife.env in ['prod', 'demo', 'end2end', 'continuumtest'] %}
        - name: composer --no-interaction install --no-suggest --classmap-authoritative --no-dev
        {% elif pillar.elife.env != 'dev' %}
        - name: composer --no-interaction install --no-suggest --classmap-authoritative
        {% else %}
        - name: composer --no-interaction install --no-suggest
        {% endif %}
        - cwd: /srv/annotations/
        - user: {{ pillar.elife.deploy_user.username }}
        # to correctly write into var/
        - umask: 002
        - env:
            - SYMFONY_ENV: {{ pillar.elife.env }}
            - COMPOSER_DISCARD_CHANGES: 'true'
        - require:
            - file: config-file
            - php

{% for title, user in pillar.annotations.web_users.items() %}
annotations-nginx-authentication-{{ title }}:
    webutil.user_exists:
        - name: {{ user.username }}
        - password: {{ user.password }}
        - htpasswd_file: /etc/nginx/annotations.htpasswd
        - force: True
        - require:
            - annotations-nginx-vhost
{% endfor %}


syslog-ng-for-annotations-logs:
    file.managed:
        - name: /etc/syslog-ng/conf.d/annotations.conf
        - source: salt://annotations/config/etc-syslog-ng-conf.d-annotations.conf
        - template: jinja
        - require:
            - pkg: syslog-ng
            - composer-install
        - listen_in:
            - service: syslog-ng

logrotate-for-annotations-logs:
    file.managed:
        - name: /etc/logrotate.d/annotations
        - source: salt://annotations/config/etc-logrotate.d-annotations
