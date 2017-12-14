<?php

use Psr\Log\LogLevel;

return [
    'debug' => false,
    'api_url' => '{{ pillar.annotations.api_url }}',
    'logging' => [
        'level' => LogLevel::{{ pillar.annotations.logging.level }},
    ],
    'hypothesis' => [
        'api_url' => '{{ pillar.annotations.hypothesis.api_url }}',
        // deprecated
        'client_id' => '{{ pillar.annotations.hypothesis.client_id }}',
        // deprecated
        'secret_key' => '{{ pillar.annotations.hypothesis.secret_key }}',

        'user_management' => [
            'client_id' => '{{ pillar.annotations.hypothesis.user_management.client_id }}',
            'secret_key' => '{{ pillar.annotations.hypothesis.user_management.secret_key }}',
        ],
        'jwt_signing' => [
            'client_id' => '{{ pillar.annotations.hypothesis.jwt_signing.client_id }}',
            'secret_key' => '{{ pillar.annotations.hypothesis.jwt_signing.secret_key }}',
        ],
        'authority' => '{{ pillar.annotations.hypothesis.authority }}',
        'group' => '{{ pillar.annotations.hypothesis.group }}',
    ],
    'aws' => [
        'queue_name' => 'annotations--{{ pillar.elife.env }}',
        'queue_message_default_type' => 'profile',
        'credential_file' => true,
        'region' => '{{ pillar.elife.aws.region }}',
        {% if pillar.elife.env in ['dev', 'ci'] -%}
        'endpoint' => 'http://localhost:4100',
        {%- else -%}
        'endpoint' => null,
        {%- endif %}
    ],
];
