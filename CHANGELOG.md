# Changelog

## [1.3.1] - 2026-11-01

### Fixed

- Disable the add-on base image init wrapper to avoid `s6-overlay-suexec: fatal: can only run as pid 1` on Home Assistant.

## [1.3.0] - 2026-11-01

### Added

- Proton VPN OpenVPN lifecycle with optional kill switch.
- Optional Proton NAT-PMP port forwarding with automatic Transmission peer-port updates.
- Documentation for Home Assistant ingress, local port 9091, VPN setup, and security.

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Hardened Proton NAT-PMP renewal, RPC verification, VPN hook ownership, kill-switch recovery, and health checks.
<<<<<<< HEAD
- Rewritten the README and add-on guide with step-by-step setup, option explanations, and troubleshooting.
=======
>>>>>>> 263d72c (feat: productionize VPN lifecycle)

### Changed

- Removed fixed 51413 host mappings; Proton's assigned peer port is authoritative.
- Enabled Transmission RPC authentication by default.
<<<<<<< HEAD
- Disabled Transmission's built-in port forwarding so Proton NAT-PMP forwarding remains authoritative.
=======
>>>>>>> 263d72c (feat: productionize VPN lifecycle)
- Disabled Transmission's built-in port forwarding so Proton NAT-PMP forwarding remains authoritative.
- Documented the requirement to update this changelog with every version, commit, and push.
- Maintained multi-path OpenVPN configuration support.
- Maintained restrictive permissions for generated VPN credentials.
- Updated repository and add-on metadata for the Hangmatt fork.

## [1.4.0] - 2026-11-01

### Added

- Production VPN healthcheck and CI validation workflow.

### Changed

- Made Proton's assigned NAT-PMP port authoritative and hardened reconnect handling.

## [1.2.0] - 2018-08-24

### Added

- Parameters requirements

### Changed

- Refactoring

## [1.1.0] - 2018-08-24

### Added

- OpenVPN support

## [1.0.0] - 2018-08-23

### Added

- Working transmission client
