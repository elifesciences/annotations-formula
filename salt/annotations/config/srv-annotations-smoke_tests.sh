#!/bin/bash
. /opt/smoke.sh/smoke.sh

smoke_url_ok localhost/ping
smoke_report

