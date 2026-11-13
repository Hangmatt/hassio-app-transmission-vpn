# Transmission Home Assistant add-on

This add-on runs [Transmission](https://transmissionbt.com/), a torrent client, inside Home Assistant.

It can run in either of these modes:

- **Normal mode:** Transmission connects directly through your Home Assistant host's network.
- **VPN mode:** Transmission starts only after an OpenVPN connection is established. You can also ask Proton VPN for a forwarded peer port.

The add-on provides:

- A Transmission web interface inside Home Assistant.
- Optional local-network access to that same web interface on port `9091`.
- Download and incomplete-download folders under `/media` or `/share`.
- Optional Proton VPN OpenVPN support.
- Optional automatic Proton VPN NAT-PMP port forwarding.
- A kill switch that stops Transmission when the VPN connection disappears.

## Quick start

[![Open your Home Assistant instance and show the add app repository dialog with a specific repository URL pre-filled.](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https://github.com/Hangmatt/hassio-addon-transmission)

1. Open **Settings → Add-ons → Add-on store** in Home Assistant.
2. Open the three-dot menu and choose **Repositories**.
3. Add this repository:

   `https://github.com/Hangmatt/hassio-addon-transmission`

4. Install **Transmission**.
5. Open the add-on's **Configuration** tab.
6. Set a Transmission username and password. Keep authentication enabled.
7. Click **Save**, start the add-on, and open **Web UI**.

For VPN setup, folder locations, configuration options, and troubleshooting, read [transmission/DOCS.md](transmission/DOCS.md).

## Important network facts

- Home Assistant ingress is the easiest and safest way to open the web interface.
- Port `9091` is the **web interface**, not the torrent peer port.
- Local access is mapped to TCP port `9091` by default: `http://HOME_ASSISTANT_HOST:9091/transmission/web/`.
- With `local_port_forwarding` enabled, the add-on uses `local-port` as Transmission's peer port. Default: `51413`.
- With Proton port forwarding enabled, Proton assigns the peer port dynamically. That assigned port is used for both TCP and UDP while VPN is active.
- Do not expose port `9091` directly to the internet.

## Support

Check the add-on log first: **Settings → Add-ons → Transmission → Log**. The full setup and troubleshooting guide is in [transmission/DOCS.md](transmission/DOCS.md).

## License

MIT License. See [LICENSE.md](LICENSE.md).

Copyright (c) 2018 Pierrick Rouxel
Copyright (c) 2026 Hangmatt
