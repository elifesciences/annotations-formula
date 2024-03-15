#!/bin/bash
set -e
. /opt/smoke.sh/smoke.sh

cd /home/{{ pillar.elife.deploy_user.username }}/annotations
docker-compose exec queue_watch ./smoke_tests_cli.sh
docker-compose exec fpm ./smoke_tests_fpm.sh

# annotations doesn't have a healthcheck right now but the slight pause helps
timeout=5 # seconds
docker-wait-healthy annotations_fpm_1 $timeout || true

set +e
smoke_url_ok localhost/ping
smoke_report

