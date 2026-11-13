#!/usr/bin/with-contenv bashio
# ==============================================================================
declare CONFIG
declare local_peer_port

CONFIG=$(</data/transmission/settings.json)

CONFIG=$(bashio::jq "${CONFIG}" ".\"bind-address-ipv4\"=\"${1}\"")
CONFIG=$(bashio::jq "${CONFIG}" ".\"peer-port-random-on-start\"=false")
CONFIG=$(bashio::jq "${CONFIG}" ".\"port-forwarding-enabled\"=false")
if bashio::config.true 'local_port_forwarding'; then
    local_peer_port=$(bashio::config '["local-port"]')
    CONFIG=$(bashio::jq "${CONFIG}" ".\"peer-port\"=${local_peer_port}")
fi

echo "${CONFIG}" > /data/transmission/settings.json

if pgrep -x transmission-daemon >/dev/null 2>&1; then
    bashio::log.info 'Transmission already running; not starting a duplicate process'
    exit 0
fi

/usr/bin/transmission-daemon --foreground --config-dir /data/transmission \
    >/proc/1/fd/1 2>/proc/1/fd/2 &
bashio::log.info 'Transmission started after VPN connection'
