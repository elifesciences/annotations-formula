annotations-nginx-vhost:
    file.managed:
        - name: /etc/nginx/sites-enabled/annotations.conf
        - source: salt://annotations/config/etc-nginx-sites-enabled-annotations.conf
        - template: jinja
        - require:
            - nginx-config
        - listen_in:
            - service: nginx-server-service

annotations-folder:
    # carefully removing everything but config.php and var/logs
    # which are mounted inside the container
    # TODO: remove when all nodes are up-to-date
    cmd.run:
        - name: |
            rm -rf /srv/annotations/app/
            rm -rf /srv/annotations/curl_fpm
            rm -rf /srv/annotations/var/cache/
            rm -rf /srv/annotations/var/sessions/
            rm -rf /srv/annotations/web/app_*.php
            rm -rf /srv/annotations/web/bundles/

    file.directory:
        - name: /srv/annotations
        - user: {{ pillar.elife.deploy_user.username }}
        - group: {{ pillar.elife.deploy_user.username }}
        - recurse:
            - user
            - group
        - require:
            - cmd: annotations-folder

annotations-folder-web:
    file.managed:
        - name: /srv/annotations/web/app.php
        - contents: '# placeholder. Nginx requires this file to pass requests to a php-fpm container'
        - makedirs: True
        - require:
            - annotations-folder

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
            - annotations-folder

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
            - annotations-folder

integration-smoke-tests:
    file.managed:
        - name: /srv/annotations/smoke_tests.sh
        - source: salt://annotations/config/srv-annotations-smoke_tests.sh
        - template: jinja
        - user: {{ pillar.elife.deploy_user.username }}
        - mode: 755
        - require: 
            - config-file

syslog-ng-for-annotations-logs:
    file.managed:
        - name: /etc/syslog-ng/conf.d/annotations.conf
        - source: salt://annotations/config/etc-syslog-ng-conf.d-annotations.conf
        - template: jinja
        - require:
            - pkg: syslog-ng
        - listen_in:
            - service: syslog-ng

logrotate-for-annotations-logs:
    file.managed:
        - name: /etc/logrotate.d/annotations
        - source: salt://annotations/config/etc-logrotate.d-annotations
