FROM ghcr.io/hassio-addons/base:21.0.10 AS base
# hadolint ignore=DL3006

# Copy root filesystem
COPY rootfs /

FROM base AS setup
# Setup base
RUN apk add --no-cache \
    coreutils \
    curl \
    libnatpmp \
    nginx \
    transmission-cli \
    transmission-daemon \
    transmission-remote \
    openvpn \
    && chmod -R +x /etc/cont-init.d /etc/services.d /etc/openvpn/*.sh /etc/healthcheck.sh

FROM setup AS runtime
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 CMD ["/etc/healthcheck.sh"]

# Build arugments
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_REF
ARG BUILD_VERSION


# Labels
LABEL \
    io.hass.version=${BUILD_VERSION} \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="app" \
    io.hass.name="Transmission" \
    io.hass.description="The torrent client for Hass.io with OpenVPN support" \
    maintainer="Hangmatt <matthijs.pet@gmail.com>" \
    org.label-schema.description="The torrent client for Hass.io" \
    org.label-schema.build-date=${BUILD_DATE} \
    org.label-schema.name="Transmission" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.url="https://github.com/Hangmatt/hassio-addon-transmission" \
    org.label-schema.usage="https://github.com/Hangmatt/hassio-addon-transmission/tree/master/README.md" \
    org.label-schema.vcs-ref=${BUILD_REF} \
    org.label-schema.vcs-url="https://github.com/Hangmatt/hassio-addon-transmission" \
    org.label-schema.vendor="Community Hass.io Addons"
