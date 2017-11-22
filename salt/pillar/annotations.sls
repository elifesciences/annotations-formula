annotations:
    logging:
        level: DEBUG
    hypothesis:
        api_url: https://hypothes.is/api
        client_id: null
        secret_key: null
        authority: null

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
