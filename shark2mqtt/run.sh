#!/usr/bin/env bash
set -Eeuo pipefail

CONFIG_PATH="/data/options.json"

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

if [ ! -f "$CONFIG_PATH" ]; then
  fatal "Home Assistant add-on options file not found at $CONFIG_PATH"
fi

log "Reading Home Assistant add-on configuration..."

SHARK_USERNAME="$(read_option shark_username)"
SHARK_PASSWORD="$(read_option shark_password)"
MQTT_HOST="$(read_option mqtt_host)"

if [ -z "$SHARK_USERNAME" ] || [ "$SHARK_USERNAME" = "null" ]; then
  fatal "shark_username is required. Set it in the add-on Configuration tab."
fi

if [ -z "$SHARK_PASSWORD" ] || [ "$SHARK_PASSWORD" = "null" ]; then
  fatal "shark_password is required. Set it in the add-on Configuration tab."
fi

if [ -z "$MQTT_HOST" ] || [ "$MQTT_HOST" = "null" ]; then
  fatal "mqtt_host is required. If you use the Mosquitto add-on, core-mosquitto is usually correct."
fi

export SHARK_USERNAME
export SHARK_PASSWORD
export MQTT_HOST

export_if_set SHARK_REGION "$(read_option shark_region)"
export_if_set SHARK_HOUSEHOLD_ID "$(read_option shark_household_id)"
export_if_set MQTT_PORT "$(read_option mqtt_port)"
export_if_set MQTT_USERNAME "$(read_option mqtt_username)"
export_if_set MQTT_PASSWORD "$(read_option mqtt_password)"
export_if_set MQTT_PREFIX "$(read_option mqtt_prefix)"
export_if_set POLL_INTERVAL "$(read_option poll_interval)"
export_if_set POLL_INTERVAL_ACTIVE "$(read_option poll_interval_active)"
export_if_set LOG_LEVEL "$(read_option log_level)"

# Persist Shark auth tokens in the add-on's persistent data volume.
export TOKEN_DIR="/data"

log "Starting shark2mqtt..."
log "MQTT broker: ${MQTT_HOST}:${MQTT_PORT:-1883}"
log "Shark region: ${SHARK_REGION:-us}"
log "Polling: ${POLL_INTERVAL:-300}s / active ${POLL_INTERVAL_ACTIVE:-20}s"
log "Token directory: ${TOKEN_DIR}"

# Upstream shark2mqtt needs a headed Chromium browser inside Xvfb for auth.
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

python -m src.main "$@" &
APP_PID="$!"

wait "$APP_PID"
EXIT_CODE="$?"

cleanup
exit "$EXIT_CODE"
