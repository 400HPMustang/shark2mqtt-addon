# Shark2MQTT

This add-on wraps CamSoper's `shark2mqtt` project for Home Assistant.

## Configuration

Required:

- `shark_username`: SharkNinja account email
- `shark_password`: SharkNinja account password

MQTT:

By default, `use_supervisor_mqtt_service` is enabled. This tells the add-on to ask Home Assistant Supervisor for the configured MQTT service details. This is the recommended mode when using the official Mosquitto Broker app/add-on.

If you want to use your own broker or manually configured credentials, turn off `use_supervisor_mqtt_service` and set:

- `mqtt_host`
- `mqtt_port`
- `mqtt_username`
- `mqtt_password`

Optional Shark settings:

- `shark_region`: `us` or `eu`
- `shark_household_id`: leave blank unless you need to force a household ID

Other options:

- `mqtt_prefix`: default `shark2mqtt`
- `poll_interval`: default `300`
- `poll_interval_active`: default `20`
- `log_level`: `DEBUG`, `INFO`, `WARNING`, or `ERROR`

## Notes

Shark2MQTT uses a browser-based login flow. The add-on starts Xvfb and Chromium inside the container so the upstream app can authenticate and save tokens in `/data`.
