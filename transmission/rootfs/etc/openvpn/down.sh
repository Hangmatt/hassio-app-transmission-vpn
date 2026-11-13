#!/usr/bin/with-contenv bashio

pkill -TERM -x transmission-daemon || true
pkill -TERM -f '/etc/openvpn/port-forward.sh' || true

if bashio::config.true 'kill_switch'; then
    bashio::log.warning 'Kill switch enabled: Transmission remains stopped until VPN reconnects'
else
    bashio::log.warning 'Kill switch disabled: Transmission stopped after VPN disconnect'
fi
