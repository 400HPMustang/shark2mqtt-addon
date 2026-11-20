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
- `ayla_merge`: default `false`. Enable only when a robot is missing due to a partially migrated Shark account.
- `map_image`: default `true`. Publish a floor-plan image entity on supported Skegox accounts.
- `map_show_scan`: default `false`. Include the robot's own floor scan behind the room outlines when the floor-plan image is enabled.
- `browser_login`: default `true`. Set `false` to stop the add-on from ever running the automated browser login. When there's no working token in `/data`, the log then shows "Shark login needed" instead of retrying the login, which avoids Cloudflare failures and account lockouts. You'll need to put a working `shark2mqtt_tokens.json` in the add-on's `/data` folder yourself and restart.
- `pause_operating_mode`: default `1`. The value sent for pause. Some robots (for example the UR2850ZEUS) ignore `1` and pause with `0`. On many other models `0` means stop, so try it before relying on it.

## Notes

Shark2MQTT uses a browser-based login flow. The add-on starts Xvfb and Chromium inside the container so the upstream app can authenticate and save tokens in `/data`.
