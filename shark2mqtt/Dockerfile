# Shark2MQTT Home Assistant add-on wrapper.
#
# This intentionally builds FROM the upstream shark2mqtt container,
# then replaces the entrypoint with a Home Assistant-aware run script.
#
# Upstream currently publishes amd64 and arm64 images.
ARG SHARK2MQTT_VERSION=1.5.1
FROM ghcr.io/camsoper/shark2mqtt:${SHARK2MQTT_VERSION}

USER root

# jq is used to read /data/options.json, which Home Assistant writes
# from the add-on configuration UI.
RUN apt-get update \
    && apt-get install -y --no-install-recommends jq \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /tmp/.X11-unix /data \
    && chmod 1777 /tmp/.X11-unix \
    && chown -R shark:shark /data

COPY run.sh /run.sh
RUN chmod 755 /run.sh

USER shark

ENTRYPOINT ["/run.sh"]
