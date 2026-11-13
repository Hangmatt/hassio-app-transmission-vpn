#!/usr/bin/with-contenv bashio
set -euo pipefail

if bashio::config.true 'openvpn_enabled'; then
    ip -4 addr show tun0 >/dev/null 2>&1
    pgrep -x openvpn >/dev/null
fi
pgrep -x transmission-daemon >/dev/null
curl --silent --max-time 5 http://127.0.0.1:9091/transmission/rpc -o /dev/null
if bashio::config.true 'port_forwarding'; then
    [[ -s /run/proton-forwarded-port ]]
fi
