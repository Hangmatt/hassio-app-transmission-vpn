#!/usr/bin/with-contenv bashio
set -euo pipefail

if bashio::config.true 'openvpn_enabled'; then
    ip -4 addr show tun0 >/dev/null 2>&1
    pgrep -x openvpn >/dev/null
fi
pgrep -x transmission-daemon >/dev/null
if ! host_ip=$(bashio::network.ipv4_address | sed -n '1s|/.*||p') || [[ -z "${host_ip}" ]]; then
    bashio::log.error 'Could not determine the Home Assistant host IPv4 address'
    exit 1
fi
if ! host_port=$(bashio::app.port 9091) || [[ -z "${host_port}" || "${host_port}" == 'null' ]]; then
    bashio::log.error 'Host port 9091 is not mapped'
    exit 1
fi
curl --silent --max-time 5 "http://${host_ip}:${host_port}/transmission/rpc" -o /dev/null
if bashio::config.true 'port_forwarding'; then
    [[ -s /run/proton-forwarded-port ]]
fi
