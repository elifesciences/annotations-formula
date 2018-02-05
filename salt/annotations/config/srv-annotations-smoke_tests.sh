#!/bin/bash
set -e
. /opt/smoke.sh/smoke.sh

cd /home/{{ pillar.elife.deploy_user.username }}/annotations
docker-compose exec queue_watch ./smoke_tests_cli.sh
docker-compose exec fpm ./smoke_tests_fpm.sh

set +e
smoke_url_ok localhost/ping
smoke_report

