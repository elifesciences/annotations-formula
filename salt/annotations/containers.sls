annotations-docker-compose-folder:
    file.directory:
        - name: /home/{{ pillar.elife.deploy_user.username }}/annotations/
        - user: {{ pillar.elife.deploy_user.username }}
        - require:
            - deploy-user

# variable for docker-compose
annotations-docker-compose-.env:
    file.managed:
        - name: /home/{{ pillar.elife.deploy_user.username }}/annotations/.env
        - source: salt://annotations/config/home-deployuser-annotations-.env
        - makedirs: True
        - template: jinja
        - require:
            - annotations-docker-compose-folder

# variables for the containers
annotations-containers-env:
    file.managed:
        - name: /home/{{ pillar.elife.deploy_user.username }}/annotations/containers.env
        - source: salt://annotations/config/home-deployuser-annotations-containers.env
        - template: jinja
        - require:
            - annotations-docker-compose-folder

annotations-docker-compose-yml:
    file.managed:
        - name: /home/{{ pillar.elife.deploy_user.username }}/annotations/docker-compose.yml
        - source: salt://annotations/config/home-deployuser-annotations-docker-compose.yml
        - template: jinja
        - require:
            - annotations-docker-compose-folder

annotations-docker-containers:
    cmd.run:
        - name: |
            /usr/local/bin/docker-compose up --force-recreate -d
        - runas: {{ pillar.elife.deploy_user.username }}
        - cwd: /home/{{ pillar.elife.deploy_user.username }}/annotations
        - require:
            - annotations-docker-compose-.env
            - annotations-containers-env
            - annotations-docker-compose-yml
