#!/usr/bin/with-contenv bashio
# ==============================================================================

declare CONFIG
declare authentication_required
declare username
declare password
declare download_dir
declare incomplete_dir
declare local_peer_port

if ! bashio::fs.directory_exists '/data/transmission'; then
  mkdir '/data/transmission'
fi

if ! bashio::fs.file_exists '/data/transmission/settings.json'; then
  echo "{}" > /data/transmission/settings.json
fi

CONFIG=$(</data/transmission/settings.json)

# Defaults
incomplete_dir=$(bashio::config 'incomplete_dir')
download_dir=$(bashio::config 'download_dir')
authentication_required=$(bashio::config 'authentication_required')
username=$(bashio::config '["WebUI Login"].username')
password=$(bashio::config '["WebUI Login"].password')
CONFIG=$(bashio::jq "${CONFIG}" ".\"incomplete-dir\"=\"${incomplete_dir}\"")
CONFIG=$(bashio::jq "${CONFIG}" ".\"incomplete-dir-enabled\"=true")
CONFIG=$(bashio::jq "${CONFIG}" ".\"download-dir\"=\"${download_dir}\"")
CONFIG=$(bashio::jq "${CONFIG}" ".\"rpc-whitelist-enabled\"=false")
CONFIG=$(bashio::jq "${CONFIG}" ".\"rpc-host-whitelist-enabled\"=false")
CONFIG=$(bashio::jq "${CONFIG}" ".\"bind-address-ipv4\"=\"0.0.0.0\"")
CONFIG=$(bashio::jq "${CONFIG}" ".\"port-forwarding-enabled\"=false")
CONFIG=$(bashio::jq "${CONFIG}" ".\"peer-port-random-on-start\"=false")
if bashio::config.true 'local_port_forwarding'; then
    local_peer_port=$(bashio::config '["local-port"]')
    CONFIG=$(bashio::jq "${CONFIG}" ".\"peer-port\"=${local_peer_port}")
fi
CONFIG=$(bashio::jq "${CONFIG}" ".\"rpc-authentication-required\"=${authentication_required}")
CONFIG=$(bashio::jq "${CONFIG}" ".\"rpc-username\"=\"${username}\"")
CONFIG=$(bashio::jq "${CONFIG}" ".\"rpc-password\"=\"${password}\"")

echo "${CONFIG}" > /data/transmission/settings.json
