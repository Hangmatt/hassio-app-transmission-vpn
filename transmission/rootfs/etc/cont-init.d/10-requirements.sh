#!/usr/bin/with-contenv bashio
# ==============================================================================
# This files check if all user configuration requirements are met
# ==============================================================================

# Check authentication requirements, if enabled
if bashio::config.true 'authentication_required'; then
    if ! bashio::config.has_value '["WebUI Login"].username'; then
        bashio::exit.nok 'Transmission authentication is enabled, but no username was specified'
    fi

    if ! bashio::config.has_value '["WebUI Login"].password'; then
        bashio::exit.nok 'Transmission authentication is enabled, but no password was specified'
    fi
fi

if bashio::config.true 'port_forwarding' && ! bashio::config.true 'openvpn_enabled'; then
    bashio::exit.nok 'Port forwarding requires OpenVPN to be enabled'
fi

# Check OpenVPN requirements, if enabled
if bashio::config.true 'openvpn_enabled'; then
    declare openvpn_username
    openvpn_username=$(bashio::config '["openvpn credentials"].openvpn_username')
    if ! bashio::config.has_value '["openvpn credentials"].openvpn_username'; then
        bashio::exit.nok 'OpenVPN is enabled, but no username was specified'
    fi

    if ! bashio::config.has_value '["openvpn credentials"].openvpn_password'; then
        bashio::exit.nok 'OpenVPN is enabled, but no password was specified'
    fi

    if ! bashio::config.has_value 'openvpn_config'; then
        bashio::exit.nok 'OpenVPN is enabled, but no openvpn_config was specified'
    fi

    openvpn_config=$(bashio::config 'openvpn_config')
    if [[ "${openvpn_config}" =~ \.\. ]]; then
        bashio::exit.nok "Invalid openvpn_config: path traversal ('..') is not allowed"
    fi

    config_name="${openvpn_config%.ovpn}"
    found=false
    for candidate in \
        "/config/${config_name}.ovpn" \
        "/config/openvpn/${config_name}.ovpn" \
        "/data/openvpn/${config_name}.ovpn"; do
        if bashio::fs.file_exists "${candidate}"; then
            found=true
            break
        fi
    done

    if [[ "${found}" = false ]]; then
        bashio::exit.nok "OpenVPN configuration file not found. Checked: /config/${config_name}.ovpn, /config/openvpn/${config_name}.ovpn, and /data/openvpn/${config_name}.ovpn"
    fi

    if bashio::config.true 'port_forwarding' && [[ "${openvpn_username}" != *+pmp* ]]; then
        bashio::log.warning 'Port forwarding enabled, but OpenVPN username does not contain +pmp; Proton will reject NAT-PMP access'
    fi
fi
