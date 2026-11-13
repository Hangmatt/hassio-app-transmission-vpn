# Transmission Home Assistant add-on guide

This guide explains how to install, configure, and use the Transmission add-on. It assumes that you would prefer instructions that say what to click, what to type, and what will happen next. Sensible preference.

## What this add-on does

Transmission is a BitTorrent client. It downloads and uploads torrent data.

The add-on gives Transmission two web-interface entry points:

1. **Home Assistant ingress**: open the add-on and click **Open Web UI**. This is the recommended option because Home Assistant handles the connection for you.
2. **Local port 9091**: open `http://HOME_ASSISTANT_HOST:9091/transmission/web/`, replacing `HOME_ASSISTANT_HOST` with the hostname or IP address of your Home Assistant machine.

Port `9091` is for the web interface only. It is not the port that torrent peers use to connect to Transmission.

## Install the add-on

1. In Home Assistant, open **Settings → Add-ons → Add-on store**.
2. Click the three-dot menu in the top-right corner.
3. Choose **Repositories**.
4. Add:

   `https://github.com/Hangmatt/hassio-addon-transmission`

5. Close the repository dialog.
6. Find **Transmission** in the store and open it.
7. Click **Install** and wait for the installation to finish.

Do not start configuring VPN settings before the add-on is installed. There is nowhere useful to put them yet.

## Basic configuration

Open the add-on's **Configuration** tab and set at least these values:

```yaml
authentication_required: true
username: transmission
password: choose-a-long-unique-password
download_dir: /media/downloads
incomplete_dir: /media/incomplete
openvpn_enabled: false
```

Then:

1. Click **Save**.
2. Open the **Info** tab.
3. Click **Start**.
4. Open **Web UI**.

If authentication is enabled, Transmission asks for the username and password you configured. Authentication is enabled by default. Keep it enabled, especially if you use port `9091`.

## Where downloaded files go

The default folders are:

- Finished downloads: `/media/downloads`
- Incomplete downloads: `/media/incomplete`

You may use paths beginning with `/media` or `/share`. Examples:

```yaml
download_dir: /media/downloads
incomplete_dir: /share/transmission/incomplete
```

The add-on has access to the Home Assistant `media` and `share` folders. It does not accept arbitrary paths such as `/home`, `/root`, or `/tmp` for downloads.

After changing these paths, save the configuration and restart the add-on. Existing torrents are not automatically moved; changing the setting only changes where Transmission stores downloads going forward.

## Optional: use Proton VPN

VPN mode is optional. If you do not need it, leave `openvpn_enabled: false` and skip this section.

### What you need

- A Proton VPN plan that supports P2P.
- A Proton VPN P2P server.
- An OpenVPN `.ovpn` configuration file downloaded from Proton VPN.
- The **OpenVPN/IKEv2 username and password** from Proton VPN.

Your normal Proton account email and password are not necessarily the credentials required by OpenVPN. Using the wrong credentials is a very efficient way to make the VPN fail.

### Put the OpenVPN file in the right place

Copy the `.ovpn` file to the add-on configuration directory. You can use either of these locations:

- `/config/your-profile.ovpn`
- `/config/openvpn/your-profile.ovpn`

The add-on also checks `/data/openvpn/your-profile.ovpn`, but using `/config` or `/config/openvpn` is easier to understand and manage.

If the file is named `nl-free-123.protonvpn.udp.ovpn`, set `openvpn_config` to either:

```yaml
openvpn_config: nl-free-123.protonvpn.udp.ovpn
```

or:

```yaml
openvpn_config: nl-free-123.protonvpn.udp
```

The `.ovpn` suffix is optional in this setting.

### Enable VPN mode

Use configuration like this:

```yaml
openvpn_enabled: true
openvpn_config: nl-free-123.protonvpn.udp.ovpn
openvpn_username: your_openvpn_username
openvpn_password: your_openvpn_password
kill_switch: true
port_forwarding: false
```

When you start or restart the add-on with VPN mode enabled:

1. The add-on starts OpenVPN.
2. It waits for the VPN tunnel to connect.
3. It starts Transmission through that tunnel.
4. If the tunnel disconnects, it stops Transmission.
5. When the tunnel reconnects, it starts Transmission again.

This behavior prevents Transmission from quietly using the normal network connection after a VPN failure.

### Enable Proton port forwarding

Proton port forwarding requires a paid Proton VPN plan and a P2P server that supports port forwarding.

Set `port_forwarding: true` and add `+pmp` to the Proton OpenVPN username:

```yaml
openvpn_enabled: true
openvpn_config: nl-free-123.protonvpn.udp.ovpn
openvpn_username: your_openvpn_username+pmp
openvpn_password: your_openvpn_password
port_forwarding: true
kill_switch: true
```

The add-on requests a Proton NAT-PMP port for TCP and UDP, checks that both are the same, and updates Transmission automatically. Proton may assign a different port after reconnecting, so the number can change.

Important:

- Proton's assigned port is the authoritative torrent peer port.
- When `local_port_forwarding` is enabled, `51413` is used as the local fallback peer port; Proton's assigned port takes over while port forwarding is active.
- Disable Transmission's own router UPnP/NAT-PMP port mapping. The add-on already disables it so that it cannot fight with Proton's mapping.
- `port_forwarding: true` without a suitable Proton plan, P2P server, and `+pmp` username will fail. This is expected, not mysterious.

### Use local peer port forwarding

Set `local_port_forwarding: true` to make Transmission use the fixed peer port `51413` when OpenVPN is disabled:

```yaml
openvpn_enabled: false
local_port_forwarding: true
port_forwarding: false
```

On startup, the add-on writes `peer-port: 51413` to Transmission's `settings.json`, replacing any previously saved peer port.

The add-on maps TCP and UDP `51413` to the Home Assistant host. To accept peers from outside your home network, also forward both protocols on your router to that host. This setting configures Transmission's listening port; it does not configure your router.

When OpenVPN and Proton port forwarding are enabled, Proton's assigned peer port overrides `51413` while its forwarding lease is active. The fixed port remains the local fallback.

## All configuration options

| Option                    | What it does                                                                           | Default             |
| ------------------------- | -------------------------------------------------------------------------------------- | ------------------- |
| `log_level`               | Controls how much detail appears in the add-on log. Use `debug` when troubleshooting.  | `info`              |
| `authentication_required` | Requires a username and password for the Transmission web interface and RPC API.       | `true`              |
| `username`                | Transmission web-interface/RPC username.                                               | Empty               |
| `password`                | Transmission web-interface/RPC password.                                               | Empty               |
| `download_dir`            | Folder for completed downloads. Must begin with `/media` or `/share`.                  | `/media/downloads`  |
| `incomplete_dir`          | Folder for downloads that are not finished yet. Must begin with `/media` or `/share`.  | `/media/incomplete` |
| `local_port_forwarding`   | Uses the fixed peer port `51413` as the local fallback when enabled.                   | `false`             |
| `openvpn_enabled`         | Enables OpenVPN mode. Transmission starts after the tunnel is ready.                   | `false`             |
| `kill_switch`             | Keeps Transmission stopped after a VPN disconnect until the VPN reconnects.            | `true`              |
| `port_forwarding`         | Requests and renews a Proton NAT-PMP torrent peer port.                                | `false`             |
| `openvpn_config`          | Name of the `.ovpn` file. The file must exist in one of the locations described above. | Empty               |
| `openvpn_username`        | Proton OpenVPN username. Add `+pmp` when using Proton port forwarding.                 | Empty               |
| `openvpn_password`        | Proton OpenVPN password.                                                               | Empty               |

After changing any option, click **Save** and restart the add-on. Most configuration changes are applied during startup, not instantly.

## Access from the local network

To use the optional host port:

1. Open the add-on **Configuration** tab.
2. Make sure the add-on's port `9091` is mapped to a free host port. The default mapping is usually `9091` to `9091`.
3. Start or restart the add-on.
4. Visit:

   `http://HOME_ASSISTANT_HOST:9091/transmission/web/`

Replace `HOME_ASSISTANT_HOST` with the IP address or hostname of Home Assistant.

If port `9091` is already used by another service, choose another host port and keep the add-on's internal port as `9091`. Then use the host port you selected in the URL.

Do not forward this port from your router to the public internet. Use a VPN or another authenticated, deliberately configured remote-access solution if you need access away from home.

## Troubleshooting

### The add-on will not start

Open **Settings → Add-ons → Transmission → Log** and read the first error, not just the final line saying that the service stopped.

Common causes:

- A download path does not begin with `/media` or `/share`.
- `openvpn_enabled` is `true`, but `openvpn_config` is empty.
- The `.ovpn` file is missing or has a different filename.
- The OpenVPN username or password is wrong.

### VPN mode is enabled but Transmission is not running

This usually means OpenVPN has not connected yet. Check that:

- The `.ovpn` file is for a Proton P2P server.
- The credentials are Proton OpenVPN credentials.
- The profile is in `/config/` or `/config/openvpn/`.
- The add-on log says that OpenVPN connected and shows a tunnel address.

With `kill_switch: true`, Transmission intentionally remains stopped while the VPN is down. That is the safety feature doing its job.

### Port forwarding does not work

Check all of the following:

- Your Proton plan supports port forwarding.
- You selected a Proton P2P server that supports it.
- `port_forwarding` is `true`.
- The OpenVPN username ends in `+pmp`.
- The add-on log reports a forwarded peer port.

The forwarded port may change after a reconnect. Do not hard-code an old port in Transmission or your router.

### The web UI does not open through ingress

Check that the add-on is running and that Transmission is running. In VPN mode, wait until the VPN tunnel is connected. Then try the add-on's **Web UI** button again.

### The web UI does not open on port 9091

Check that:

- The host port is mapped and is not already used.
- You are using `/transmission/web/` at the end of the URL.
- Home Assistant's firewall allows the connection from your local network.
- The add-on is running.

## Security and privacy

- Keep `authentication_required` enabled.
- Use a long, unique Transmission password.
- Do not publish port `9091` to the internet.
- Do not commit the `.ovpn` file or VPN credentials to Git.
- Treat the Proton forwarded peer port as publicly reachable. It is for torrent peer traffic, not for the Transmission control panel.
- The add-on requires network administration privileges and access to `/dev/net/tun` for OpenVPN. These permissions are necessary for the VPN mode.

## License

MIT License. See [LICENSE.md](../LICENSE.md).
