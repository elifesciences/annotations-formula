<?php

use Psr\Log\LogLevel;

return [
    'debug' => false,
    'logging' => [
        'level' => LogLevel::{{ pillar.annotations.logging.level }},
    ],
    'hypothesis' => [
        'api_url' => '{{ pillar.annotations.hypothesis.api_url }}',
        'client_id' => '{{ pillar.annotations.hypothesis.client_id }}',
        'secret_key' => '{{ pillar.annotations.hypothesis.secret_key }}',
        'authority' => '{{ pillar.annotations.hypothesis.authority }}',
    ],
    'aws' => [
        'queue_name' => 'annotations--{{ pillar.elife.env }}',
        'queue_message_default_type' => 'profiles',
        'credential_file' => true,
        'region' => '{{ pillar.elife.aws.region }}',
        {% if pillar.elife.env in ['dev', 'ci'] -%}
        'endpoint' => 'http://localhost:4100',
        {%- else -%}
        'endpoint' => null,
        {%- endif %}
    ],
];
