# Shark2MQTT Home Assistant add-on wrapper.
#
# This builds FROM the upstream shark2mqtt container, then replaces the
# entrypoint with a Home Assistant-aware run script.
#
# Home Assistant writes /data/options.json in a way that may only be
# readable by root. This wrapper intentionally starts as root so it can
# read add-on options, create /tmp/.X11-unix, and persist tokens in /data.
ARG SHARK2MQTT_VERSION=1.5.1
FROM ghcr.io/camsoper/shark2mqtt:${SHARK2MQTT_VERSION}

USER root

RUN apt-get update \
    && apt-get install -y --no-install-recommends jq curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY run.sh /run.sh
RUN chmod 755 /run.sh

ENV PYTHONUNBUFFERED=1

ENTRYPOINT ["/run.sh"]
