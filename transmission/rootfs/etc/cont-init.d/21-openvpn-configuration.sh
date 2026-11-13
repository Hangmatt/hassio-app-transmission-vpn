#!/usr/bin/with-contenv bashio
# ==============================================================================

declare openvpn_config
declare openvpn_username
declare openvpn_password
declare config_name
declare ovpn_file

if bashio::config.true 'openvpn_enabled'; then

  openvpn_config=$(bashio::config 'openvpn_config')
  config_name="${openvpn_config%.ovpn}"

  ovpn_file=""
  for candidate in \
      "/config/${config_name}.ovpn" \
      "/config/openvpn/${config_name}.ovpn" \
      "/data/openvpn/${config_name}.ovpn"; do
      if bashio::fs.file_exists "${candidate}"; then
          ovpn_file="${candidate}"
          break
      fi
  done

  if [[ -z "${ovpn_file}" ]]; then
      bashio::exit.nok "OpenVPN configuration file not found. Checked: /config/${config_name}.ovpn, /config/openvpn/${config_name}.ovpn, and /data/openvpn/${config_name}.ovpn"
  fi

  bashio::log.info "Using OpenVPN configuration file: ${ovpn_file}"
  sed -E '/^[[:space:]]*(up|down|route-pre-down)[[:space:]]/d' "${ovpn_file}" > /etc/openvpn/config.ovpn
  cat >> /etc/openvpn/config.ovpn <<'EOF'
up /etc/openvpn/up.sh
down-pre
route-pre-down /etc/openvpn/route-pre-down.sh
down /etc/openvpn/down.sh
EOF

  openvpn_username=$(bashio::config 'openvpn_username')
  echo "${openvpn_username}" > /etc/openvpn/credentials
  openvpn_password=$(bashio::config 'openvpn_password')
  echo "${openvpn_password}" >> /etc/openvpn/credentials
  chmod 600 /etc/openvpn/credentials

  sed -i 's/auth-user-pass.*/auth-user-pass \/etc\/openvpn\/credentials/g' /etc/openvpn/config.ovpn

fi
