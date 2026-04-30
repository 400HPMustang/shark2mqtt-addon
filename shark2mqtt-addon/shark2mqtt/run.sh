#!/usr/bin/with-contenv bashio

# ---------------------------------------------------------------------------
# shark2mqtt HA add-on entry point
# Reads options from the HA Supervisor config and exports them as the env
# vars that shark2mqtt expects, then hands off to the upstream entrypoint.
# ---------------------------------------------------------------------------

bashio::log.info "Reading configuration..."

# Required
export SHARK_USERNAME="$(bashio::config 'shark_username')"
export SHARK_PASSWORD="$(bashio::config 'shark_password')"
export MQTT_HOST="$(bashio::config 'mqtt_host')"

# Validate required fields
if bashio::var.is_empty "${SHARK_USERNAME}"; then
    bashio::exit.nok "shark_username is required — set it in the add-on configuration."
fi
if bashio::var.is_empty "${SHARK_PASSWORD}"; then
    bashio::exit.nok "shark_password is required — set it in the add-on configuration."
fi
if bashio::var.is_empty "${MQTT_HOST}"; then
    bashio::exit.nok "mqtt_host is required — set it in the add-on configuration."
fi

# Optional with defaults
export SHARK_REGION="$(bashio::config 'shark_region')"
export MQTT_PORT="$(bashio::config 'mqtt_port')"
export MQTT_PREFIX="$(bashio::config 'mqtt_prefix')"
export POLL_INTERVAL="$(bashio::config 'poll_interval')"
export POLL_INTERVAL_ACTIVE="$(bashio::config 'poll_interval_active')"
export LOG_LEVEL="$(bashio::config 'log_level')"

# Token directory — use the add-on's persistent /data volume
export TOKEN_DIR="/data"

# Optional MQTT credentials (only set if non-empty to avoid passing empty strings)
if bashio::config.has_value 'mqtt_username'; then
    export MQTT_USERNAME="$(bashio::config 'mqtt_username')"
fi
if bashio::config.has_value 'mqtt_password'; then
    export MQTT_PASSWORD="$(bashio::config 'mqtt_password')"
fi

# Optional: pre-supplied household ID
if bashio::config.has_value 'shark_household_id'; then
    export SHARK_HOUSEHOLD_ID="$(bashio::config 'shark_household_id')"
fi

bashio::log.info "Starting shark2mqtt..."
bashio::log.info "  MQTT broker : ${MQTT_HOST}:${MQTT_PORT}"
bashio::log.info "  Region      : ${SHARK_REGION}"
bashio::log.info "  Poll interval: ${POLL_INTERVAL}s (active: ${POLL_INTERVAL_ACTIVE}s)"
bashio::log.info "  Log level   : ${LOG_LEVEL}"

# Hand off to the upstream image's entrypoint.
# The upstream image (ghcr.io/camsoper/shark2mqtt) expects to be launched
# directly as a Python module; exec it so signals are forwarded cleanly.
exec python -m shark2mqtt "$@"
