# Shark2MQTT

This add-on wraps CamSoper's `shark2mqtt` project for Home Assistant.

## Configuration

Required:

- `shark_username`: SharkNinja account email
- `shark_password`: SharkNinja account password
- `mqtt_host`: MQTT broker host. If you use the Mosquitto add-on, `core-mosquitto` is usually correct.

Optional:

- `shark_region`: `us` or `eu`
- `shark_household_id`: leave blank unless you need to force a household ID
- `mqtt_port`: default `1883`
- `mqtt_username` / `mqtt_password`: your MQTT credentials, if required
- `mqtt_prefix`: default `shark2mqtt`
- `poll_interval`: default `300`
- `poll_interval_active`: default `20`
- `log_level`: `DEBUG`, `INFO`, `WARNING`, or `ERROR`

## Notes

Shark2MQTT uses a browser-based login flow. The add-on starts Xvfb and Chromium inside the container so the upstream app can authenticate and save tokens in `/data`.
