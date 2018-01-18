{% if pillar.annotations.containerized %}

# variable for docker-compose
annotations-docker-compose-.env:
    file.managed:
        - name: /home/{{ pillar.elife.deploy_user.username }}/.env
        - source: salt://annotations/config/home-deployuser-.env
        - template: jinja
        - require:
            - deploy-user

# variables for the containers
annotations-containers-env:
    file.managed:
        - name: /home/{{ pillar.elife.deploy_user.username }}/annotations.env
        - source: salt://annotations/config/home-deployuser-annotations.env
        - template: jinja
        - require:
            - deploy-user

annotations-docker-compose-yml:
    file.managed:
        - name: /home/{{ pillar.elife.deploy_user.username }}/annotations-docker-compose.yml
        - source: salt://annotations/config/home-deployuser-annotations-docker-compose.yml
        - template: jinja
        - require:
            - deploy-user

annotations-docker-containers:
    cmd.run:
        - name: /usr/local/bin/docker-compose -f /home/elife/annotations-docker-compose.yml up --force-recreate -d
        - user: {{ pillar.elife.deploy_user.username }}
        - cwd: /home/{{ pillar.elife.deploy_user.username }}
        - require:
            - annotations-docker-compose-.env
            - annotations-containers-env
            - annotations-docker-compose-yml

{% endif %}
