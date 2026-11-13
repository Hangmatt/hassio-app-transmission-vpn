# Transmission Add-on VPN Implementation

This plan is living documentation for the VPN-backed Transmission add-on. It follows the repository's `~/.codex/PLANS.md` guidance.

## Purpose / Big Picture

After this change, users can install the repository as a Home Assistant add-on, provide a Proton VPN OpenVPN profile and credentials, and run Transmission only while the VPN is up. Optional kill-switch behavior stops Transmission when the tunnel disappears. Proton's NAT-PMP port forwarding can assign a forwarded peer port and update Transmission automatically.

## Progress

- [x] (2026-11-01) Audited repository layout and found missing OpenVPN lifecycle hooks, kill-switch configuration, and port-forwarding implementation.
- [x] (2026-11-01) Implemented supervised OpenVPN and Transmission lifecycle, including tunnel up/down hooks.
- [x] (2026-11-01) Implemented optional Proton NAT-PMP port forwarding and dynamic Transmission peer-port updates.
- [x] (2026-11-01) Added configuration validation, documentation, and add-on package dependency.
- [x] (2026-11-01) Ran JSON, Bash syntax, and whitespace checks.
- [x] (2026-11-01) Built `transmission-addon:1.3.0` successfully and ran disposable image smoke test for required binaries and executable hooks.
- [x] (2026-11-01) Ran disposable Transmission runtime smoke test; web UI returned HTTP 200 through published host port 9091.
- [x] (2026-11-01) Ran disposable Transmission RPC smoke test; `session-set` changed and `session-get` confirmed peer port 49123.
- [x] (2026-11-01) Made OpenVPN reconnect startup idempotent and rebuilt image successfully.
- [x] (2026-11-01) Hardened NAT-PMP renewal and RPC verification, normalized provider hooks, removed misleading peer-port mappings, and enabled secure RPC defaults.

## Surprises & Discoveries

- `transmission/rootfs/etc/cont-init.d/21-openvpn-configuration.sh` edits `/etc/openvpn/up.sh`, but that file is not present in the repository. The current VPN-enabled path therefore cannot start reliably.
- Existing `up-transmission.sh` starts Transmission only after VPN up, but no down hook stops it; this cannot provide a kill switch.
- Proton manual OpenVPN port forwarding uses a P2P profile, username suffix `+pmp`, and NAT-PMP (`natpmpc`); the forwarded port can change after reconnect.
- New OpenVPN hook files needed explicit executable repository modes; Docker chmod remains a defensive build step.
- Live Home Assistant logs showed `s6-overlay-suexec: fatal: can only run as pid 1`; add-on metadata now sets `init: false` and version 1.3.1.

## Decision Log

- Decision: Keep OpenVPN configuration-file input and add optional NAT-PMP rather than hard-code Proton endpoints. Rationale: Proton selects the server and credentials through the supplied profile; the add-on should not embed secrets or server assumptions. Date/Author: 2026-11-01, Codex.
- Decision: Gate Transmission startup on successful VPN connection and stop it on tunnel loss. Rationale: This gives observable fail-closed behavior without routing Home Assistant's local ingress through the VPN. Date/Author: 2026-11-01, Codex.

## Outcomes & Retrospective

Implementation is complete for static behavior, image packaging, local Transmission web access, and RPC peer-port updates. VPN connect/reconnect, kill-switch, NAT-PMP lease acquisition, and Home Assistant ingress still require a real Proton P2P profile, paid plan, and Home Assistant host with `/dev/net/tun`.

## Context and Orientation

`transmission/config.json` defines Home Assistant options and exposed ports. `transmission/rootfs/etc/cont-init.d/` prepares configuration before services start. `transmission/rootfs/etc/services.d/` contains supervised long-running services. OpenVPN's `up` and `down` callbacks are shell scripts invoked when the tunnel changes state. NAT-PMP is the protocol Proton uses to request a temporary incoming port from a compatible VPN server.

## Plan of Work

Add explicit VPN and Transmission service scripts, with OpenVPN callbacks that start or stop Transmission and refresh its peer port. Add the `kill_switch` and `port_forwarding` options, install the NAT-PMP client, validate Proton-compatible settings, and preserve ingress plus local port 9091. Rewrite `transmission/DOCS.md` to document installation, profile preparation, credentials, port forwarding, kill-switch semantics, and troubleshooting.

## Concrete Steps

Run from the repository root:

    jq empty transmission/config.json
    shellcheck transmission/rootfs/etc/cont-init.d/*.sh transmission/rootfs/etc/services.d/*/run transmission/rootfs/etc/openvpn/*.sh
    docker build -t transmission-addon transmission/

Expected result: JSON parses, shellcheck reports no errors, and Docker completes successfully for the selected architecture.

## Validation and Acceptance

With a real Proton P2P OpenVPN profile, starting the add-on must show OpenVPN connected before Transmission starts. The web client must remain available through Home Assistant ingress and port 9091. With kill switch enabled, stopping or losing OpenVPN must stop Transmission; with it disabled, behavior must be documented and explicit. With port forwarding enabled, logs must show a leased port and Transmission's configured peer port must match it.

## Idempotence and Recovery

Configuration generation must preserve user settings while updating managed fields. Re-running initialization must not duplicate OpenVPN directives or credentials. If a live VPN test is unavailable, static checks and Docker build remain valid partial evidence; do not claim end-to-end verification.

## Artifacts and Notes

Current evidence is the repository audit recorded above. Runtime proof requires a Proton paid plan, P2P profile, and Home Assistant host with `/dev/net/tun` access.

## Follow-up

- [ ] Make `log_level` effective by mapping its named values to Bashio's numeric `LOG_LEVEL`, or remove the unused option and migrate existing settings.

## Interfaces and Dependencies

The image uses the Home Assistant add-on base image, `bashio`, `openvpn`, `transmission-daemon`, `nginx`, and Alpine's NAT-PMP client. Managed files include `/data/transmission/settings.json`, `/etc/openvpn/config.ovpn`, and `/etc/openvpn/credentials`; secrets stay in add-on options or mounted configuration, never in Git.
