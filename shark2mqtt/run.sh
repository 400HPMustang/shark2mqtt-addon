#!/usr/bin/env bash
set -Eeuo pipefail

CONFIG_PATH="/data/options.json"
SUPERVISOR_MQTT_URL="http://supervisor/services/mqtt"

log() {
  echo "[INFO] $*"
}

warn() {
  echo "[WARN] $*" >&2
}

fatal() {
  echo "[ERROR] $*" >&2
  exit 1
}

read_option() {
  local key="$1"
  jq -r --arg key "$key" '.[$key] // empty' "$CONFIG_PATH"
}

export_if_set() {
  local env_name="$1"
  local value="$2"

  if [ -n "$value" ] && [ "$value" != "null" ]; then
    export "$env_name=$value"
  fi
}

json_value() {
  local json="$1"
  local filter="$2"
  echo "$json" | jq -r "$filter // empty"
}

log "Starting Shark2MQTT Home Assistant add-on wrapper..."
log "Container user: $(id -u):$(id -g)"

if [ ! -f "$CONFIG_PATH" ]; then
  fatal "Home Assistant add-on options file not found at $CONFIG_PATH"
fi

if [ ! -r "$CONFIG_PATH" ]; then
  fatal "Home Assistant add-on options file exists but is not readable at $CONFIG_PATH. This wrapper must run as root."
fi

log "Reading Home Assistant add-on configuration..."

SHARK_USERNAME="$(read_option shark_username)"
SHARK_PASSWORD="$(read_option shark_password)"
SHARK_REGION="$(read_option shark_region)"
SHARK_HOUSEHOLD_ID="$(read_option shark_household_id)"
USE_SUPERVISOR_MQTT_SERVICE="$(read_option use_supervisor_mqtt_service)"

MQTT_HOST="$(read_option mqtt_host)"
MQTT_PORT="$(read_option mqtt_port)"
MQTT_USERNAME="$(read_option mqtt_username)"
MQTT_PASSWORD="$(read_option mqtt_password)"
MQTT_PREFIX="$(read_option mqtt_prefix)"

if [ -z "$SHARK_USERNAME" ] || [ "$SHARK_USERNAME" = "null" ]; then
  fatal "shark_username is required. Set it in the add-on Configuration tab."
fi

if [ -z "$SHARK_PASSWORD" ] || [ "$SHARK_PASSWORD" = "null" ]; then
  fatal "shark_password is required. Set it in the add-on Configuration tab."
fi

if [ "$USE_SUPERVISOR_MQTT_SERVICE" = "true" ]; then
  if [ -z "${SUPERVISOR_TOKEN:-}" ]; then
    warn "SUPERVISOR_TOKEN is not available; falling back to manual MQTT settings."
  else
    log "Requesting MQTT service details from Home Assistant Supervisor..."

    MQTT_SERVICE_JSON="$(curl -fsS \
      -H "Authorization: Bearer ${SUPERVISOR_TOKEN}" \
      -H "Content-Type: application/json" \
      "$SUPERVISOR_MQTT_URL" || true)"

    if [ -n "$MQTT_SERVICE_JSON" ]; then
      # Supervisor responses may either be raw service JSON or wrapped in
      # {"result":"ok","data":{...}} depending on API/client path.
      SERVICE_HOST="$(json_value "$MQTT_SERVICE_JSON" '.data.host // .host')"
      SERVICE_PORT="$(json_value "$MQTT_SERVICE_JSON" '.data.port // .port')"
      SERVICE_USERNAME="$(json_value "$MQTT_SERVICE_JSON" '.data.username // .username')"
      SERVICE_PASSWORD="$(json_value "$MQTT_SERVICE_JSON" '.data.password // .password')"

      if [ -n "$SERVICE_HOST" ]; then
        MQTT_HOST="$SERVICE_HOST"
      fi

      if [ -n "$SERVICE_PORT" ]; then
        MQTT_PORT="$SERVICE_PORT"
      fi

      if [ -n "$SERVICE_USERNAME" ]; then
        MQTT_USERNAME="$SERVICE_USERNAME"
      fi

      if [ -n "$SERVICE_PASSWORD" ]; then
        MQTT_PASSWORD="$SERVICE_PASSWORD"
      fi

      log "MQTT service details loaded from Supervisor."
    else
      warn "Could not read MQTT service details from Supervisor; falling back to manual MQTT settings."
    fi
  fi
fi

if [ -z "$MQTT_HOST" ] || [ "$MQTT_HOST" = "null" ]; then
  fatal "mqtt_host is required unless use_supervisor_mqtt_service can load the Mosquitto service details."
fi

if [ -z "$MQTT_PORT" ] || [ "$MQTT_PORT" = "null" ]; then
  MQTT_PORT="1883"
fi

export SHARK_USERNAME
export SHARK_PASSWORD
export MQTT_HOST
export MQTT_PORT

export_if_set SHARK_REGION "$SHARK_REGION"
export_if_set SHARK_HOUSEHOLD_ID "$SHARK_HOUSEHOLD_ID"
export_if_set MQTT_USERNAME "$MQTT_USERNAME"
export_if_set MQTT_PASSWORD "$MQTT_PASSWORD"
export_if_set MQTT_PREFIX "$MQTT_PREFIX"
export_if_set POLL_INTERVAL "$(read_option poll_interval)"
export_if_set POLL_INTERVAL_ACTIVE "$(read_option poll_interval_active)"
export_if_set LOG_LEVEL "$(read_option log_level)"

# Persist Shark auth tokens and auth failure screenshots in the add-on's
# persistent /data volume.
export TOKEN_DIR="/data"

# Xvfb wants this directory. Creating it as root avoids:
# _XSERVTransmkdir: ERROR: euid != 0,directory /tmp/.X11-unix will not be created.
mkdir -p /tmp/.X11-unix
chmod 1777 /tmp/.X11-unix

# Make sure token persistence can write to /data.
chmod u+rwX /data || true

log "Configuration loaded."
log "MQTT broker: ${MQTT_HOST}:${MQTT_PORT}"
if [ -n "${MQTT_USERNAME:-}" ]; then
  log "MQTT username: configured"
else
  log "MQTT username: not configured"
fi
log "Shark region: ${SHARK_REGION:-us}"
log "Polling: ${POLL_INTERVAL:-300}s / active ${POLL_INTERVAL_ACTIVE:-20}s"
log "Token directory: ${TOKEN_DIR}"

rm -f /tmp/.X99-lock
Xvfb :99 -screen 0 1024x768x16 &
XVFB_PID="$!"
export DISPLAY=":99"

cleanup() {
  if kill -0 "$XVFB_PID" 2>/dev/null; then
    kill "$XVFB_PID" 2>/dev/null || true
  fi
}

trap cleanup EXIT INT TERM

log "Starting upstream shark2mqtt..."

python -m src.main "$@" &
APP_PID="$!"

wait "$APP_PID"
EXIT_CODE="$?"

cleanup
exit "$EXIT_CODE"
