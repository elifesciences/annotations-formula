annotations-nginx-vhost:
    file.managed:
        - name: /etc/nginx/sites-enabled/annotations.conf
        - source: salt://annotations/config/etc-nginx-sites-enabled-annotations.conf
        - template: jinja
        - require:
            - nginx-config
        - listen_in:
            - service: nginx-server-service

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

# files and directories must be readable and writable by both elife and www-data
# they are both in the www-data group, but the g+s flag makes sure that
# new files and directories created inside have the www-data group
var-directory:
    file.directory:
        - name: /srv/annotations/var
        - user: {{ pillar.elife.webserver.username }}
        - group: {{ pillar.elife.webserver.username }}
        - dir_mode: 775
        - file_mode: 660
        - recurse:
            - user
            - group
            - mode
        - require:
            - builder: annotations-repository

    cmd.run:
        - name: |
            chmod -R g+s /srv/annotations/var
            mkdir -p /srv/annotations/var/logs
            chown elife:www-data /srv/annotations/var/logs
            chmod 775 /srv/annotations/var/logs
        - require:
            - file: var-directory

config-file:
    file.managed:
        - name: /srv/annotations/config.php
        - source: salt://annotations/config/srv-annotations-config.php
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
            - var-directory

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

cleanup-old-processes:
    cmd.run:
        - name: |
            systemctl stop annotations-queue-watch@1 || true
            systemctl disable annotations-queue-watch@1 || true
            rm -f /lib/systemd/system/annotations-queue-watch@.service
            systemctl daemon-reload
