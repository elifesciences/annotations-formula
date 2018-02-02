annotations:
    api_url: http://api_dummy:8080/
    logging:
        level: DEBUG
    hypothesis:
        api_url: http://hypothesis_dummy:8080
        # deprecated
        client_id: null
        # deprecated
        secret_key: null
        user_management:
            client_id: fakeclient
            client_secret: fake
        jwt_signing:
            client_id: fakeclient
            client_secret: fake
        authority: null
        group: null

elife:
    aws:
        access_key_id: AKIAFAKE
        secret_access_key: fake
    sidecars:
        main: elifesciences/annotations_cli
        containers:
            api_dummy:
                image: elifesciences/api-dummy
                name: api-dummy
                port: 8001
                enabled: true
            hypothesis_dummy:
                image: elifesciences/hypothesis-dummy
                name: hypothesis-dummy
                port: 8003
                enabled: True
    goaws:
        host: goaws  # used only by containers
        queues:
            - annotations--{{ pillar.elife.env }}
