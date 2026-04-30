# ---------------------------------------------------------------------------
# shark2mqtt Home Assistant Add-on
#
# We layer the HA add-on scaffolding on top of the upstream shark2mqtt image
# so we don't have to re-bundle Chromium / xvfb ourselves.
# ---------------------------------------------------------------------------
ARG BUILD_FROM=ghcr.io/camsoper/shark2mqtt:latest
FROM ${BUILD_FROM}

# Install bashio so run.sh can use HA's config/logging helpers.
# bashio is a tiny shell library; curl + tar is all we need to pull it in.
RUN apk add --no-cache curl bash \
    && curl -fsSL \
       https://github.com/hassio-addons/bashio/archive/refs/tags/v0.16.2.tar.gz \
       | tar -xz -C /tmp \
    && mv /tmp/bashio-0.16.2/lib /usr/lib/bashio \
    && ln -s /usr/lib/bashio/bashio.sh /usr/bin/bashio

# Copy our add-on entry point
COPY run.sh /
RUN chmod a+x /run.sh

CMD ["/run.sh"]
