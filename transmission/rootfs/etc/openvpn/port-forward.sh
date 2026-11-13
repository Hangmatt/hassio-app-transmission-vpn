#!/usr/bin/with-contenv bashio
set -u

GATEWAY="10.2.0.1"
RPC_AUTH=''
if bashio::config.true 'authentication_required'; then
    RPC_AUTH="$(bashio::config '["WebUI Login"].username'):$(bashio::config '["WebUI Login"].password')"
fi
bashio::net.wait_for 9091
while true; do
    bashio::log.info 'Requesting Proton VPN NAT-PMP port'
    output=$(timeout 10 natpmpc -a 1 0 udp 60 -g "${GATEWAY}" 2>&1) || output=''
    tcp_output=$(timeout 10 natpmpc -a 1 0 tcp 60 -g "${GATEWAY}" 2>&1) || tcp_output=''

    udp_port=$(printf '%s\n' "${output}" | sed -nE 's/.*Mapped public port ([0-9]+).*/\1/p' | tail -n 1)
    tcp_port=$(printf '%s\n' "${tcp_output}" | sed -nE 's/.*Mapped public port ([0-9]+).*/\1/p' | tail -n 1)
    if [[ -z "${udp_port}" || -z "${tcp_port}" ]]; then
        bashio::log.warning 'Proton NAT-PMP lease failed; retrying'
        sleep 5
        continue
    fi
    if [[ "${udp_port}" != "${tcp_port}" ]]; then
        bashio::log.error "Proton returned different TCP (${tcp_port}) and UDP (${udp_port}) ports"
        sleep 60
        continue
    fi
    port="${tcp_port}"
    if [[ ! -r /run/proton-forwarded-port || "$(cat /run/proton-forwarded-port)" != "${port}" ]]; then
        auth_args=()
        if [[ -n "${RPC_AUTH}" ]]; then
            auth_args=(-u "${RPC_AUTH}")
        fi
        session_id=$(curl --silent --show-error --dump-header - \
            "${auth_args[@]}" \
            http://127.0.0.1:9091/transmission/rpc \
            -o /dev/null | awk 'tolower($1) == "x-transmission-session-id:" {print $2}' | tr -d '\r')
        if [[ -n "${session_id}" ]]; then
            curl --silent --show-error --fail --max-time 5 \
                "${auth_args[@]}" \
                -H "X-Transmission-Session-Id: ${session_id}" \
                -H 'Content-Type: application/json' \
                --data "{\"method\":\"session-set\",\"arguments\":{\"peer-port\":${port}}}" \
                http://127.0.0.1:9091/transmission/rpc >/dev/null &&
            verified=$(curl --silent --show-error --fail --max-time 5 \
                "${auth_args[@]}" -H "X-Transmission-Session-Id: ${session_id}" \
                -H 'Content-Type: application/json' \
                --data '{"method":"session-get"}' \
                http://127.0.0.1:9091/transmission/rpc |
                sed -nE 's/.*"peer-port":([0-9]+).*/\1/p')
            if [[ "${verified:-}" == "${port}" ]]; then
                printf '%s\n' "${port}" > /run/proton-forwarded-port
            else
                bashio::log.warning "Transmission peer-port verification failed (expected ${port}, got ${verified:-unknown})"
            fi
        else
            bashio::log.warning 'Could not obtain Transmission RPC session ID'
        fi
        bashio::log.info "Proton VPN forwarded peer port: ${port}"
    else
        bashio::log.warning 'NAT-PMP succeeded but no public port was found in output'
    fi
    sleep 45
done
