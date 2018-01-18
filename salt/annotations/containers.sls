{% if pillar.annotations.containerized %}

# variable for docker-compose
annotations-docker-compose-.env:
    file.managed:
        - name: /home/{{ pillar.elife.deploy_user.username }}/.env
        - source: salt://annotations/config/home-deployuser-.env
        - template: jinja

# variables for the containers
annotations-containers-env:
    file.managed:
        - name: /home/{{ pillar.elife.deploy_user.username }}/annotations.env
        - source: salt://annotations/config/home-deployuser-annotations.env
        - template: jinja

annotations-docker-compose-yml:
    file.managed:
        - name: /home/{{ pillar.elife.deploy_user.username }}/annotations-docker-compose.yml
        - source: salt://annotations/config/home-deployuser-annotations-docker-compose.yml
        - template: jinja

annotations-docker-containers:
    cmd.run:
        - name: /usr/local/bin/docker-compose -f /home/elife/annotations-docker-compose.yml up --force-recreate -d
        - user: {{ pillar.elife.deploy_user.username }}
        - cwd: /home/{{ pillar.elife.deploy_user.username }}
        #TODO: require

{% endif %}
