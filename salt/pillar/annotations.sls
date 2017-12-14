annotations:
    api_url: http://localhost:8083/
    logging:
        level: DEBUG
    hypothesis:
        api_url: https://hypothes.is/api
        # deprecated
        client_id: null
        # deprecated
        secret_key: null
        user_management:
            client_id: fakeclient
            secret_key: fake
        jwt_signing:
            client_id: fakeclient
            secret_key: fake
        authority: null
        group: null

elife:
    aws:
        access_key_id: AKIAFAKE
        secret_access_key: fake
    php:
        processes:
            #enabled: True
            configuration: 
                queue_watch:
                    folder: /srv/annotations
                    command: /srv/annotations/bin/console queue:watch
                    number: 1
                    require: composer-install
    php_dummies:
        api_dummy:
            repository: https://github.com/elifesciences/api-dummy
            pinned_revision_file: /srv/annotations/api-dummy.sha1
            port: 8081  # 8082 for https
        hypothesis_dummy:
            repository: https://github.com/elifesciences/hypothesis-dummy
            pinned_revision_file: /srv/annotations/hypothesis-dummy.sha1
            port: 8083  # 8084 for https
