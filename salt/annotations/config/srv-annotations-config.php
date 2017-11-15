<?php
return [
    'secret' => '{{ pillar.annotations.secret }}',
    'hypothesis_api_url' => '{{ pillar.annotations.hypothesis_api_url }}',
    'hypothesis_api_publisher' => '{{ pillar.annotations.hypothesis_api_publisher }}',
    'ttl' => {{ pillar.annotations.ttl }},
];
