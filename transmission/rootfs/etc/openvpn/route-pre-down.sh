#!/usr/bin/with-contenv bashio

if bashio::config.true 'kill_switch'; then
    auth_args=()
    if bashio::config.true 'authentication_required'; then
        auth_args=(-n "$(bashio::config '["WebUI Login"].username'):$(bashio::config '["WebUI Login"].password')")
    fi
    session_id=$(curl --silent --show-error --max-time 5 --dump-header - \
        "${auth_args[@]}" http://127.0.0.1:9091/transmission/rpc -o /dev/null |
        awk 'tolower($1) == "x-transmission-session-id:" {print $2}' | tr -d '\r')
    if [[ -n "${session_id}" ]]; then
        curl --silent --show-error --max-time 5 "${auth_args[@]}" \
            -H "X-Transmission-Session-Id: ${session_id}" \
            -H 'Content-Type: application/json' \
            --data '{"method":"torrent-stop","arguments":{"ids":[-1]}}' \
            http://127.0.0.1:9091/transmission/rpc >/dev/null || true
    fi
    bashio::log.warning 'OpenVPN route is going down; Transmission stopped by kill switch'
fi
