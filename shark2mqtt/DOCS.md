# Shark2MQTT

Bridge SharkNinja robot vacuums to Home Assistant via MQTT autodiscovery — no
separate Docker setup required.

> Tested with US-region accounts and these models:
> - Shark AI Ultra Robot Vacuum with Self-Empty Base (UR250BEXUS)
> - Shark Matrix Plus Robot Vacuum and Mop with Self-Empty HEPA Base (UR2360EEUS)
>
> Other models may work. EU region support is included but untested.

---

## Prerequisites

1. **Mosquitto (or any MQTT broker)** — Install the Mosquitto add-on from the
   official add-on store if you don't already have one.
2. **MQTT integration** — Configure the MQTT integration in Home Assistant
   (Settings → Devices & Services → Add Integration → MQTT).

---

## Configuration

| Option | Required | Default | Description |
|---|---|---|---|
| `shark_username` | ✅ | — | Shark account email |
| `shark_password` | ✅ | — | Shark account password |
| `mqtt_host` | ✅ | — | MQTT broker hostname (`core-mosquitto` for the built-in Mosquitto add-on) |
| `shark_region` | | `us` | `us` or `eu` |
| `shark_household_id` | | auto | Leave blank; only set if auto-discovery fails |
| `mqtt_port` | | `1883` | MQTT broker port |
| `mqtt_username` | | — | MQTT username (if your broker requires auth) |
| `mqtt_password` | | — | MQTT password (if your broker requires auth) |
| `mqtt_prefix` | | `shark2mqtt` | MQTT topic prefix |
| `poll_interval` | | `300` | Seconds between polls while idle |
| `poll_interval_active` | | `20` | Seconds between polls while cleaning |
| `log_level` | | `INFO` | `DEBUG`, `INFO`, `WARNING`, or `ERROR` |

---

## First Run & Authentication

shark2mqtt authenticates to SharkNinja's cloud using an Auth0 browser flow.
On first start, it launches a headless Chromium browser to complete the login
automatically. **This can take 1–2 minutes** — check the add-on log for progress.

Auth tokens are saved to the add-on's persistent data volume, so the browser
flow only runs again when tokens expire.

---

## Home Assistant Entities

Each vacuum is auto-discovered by Home Assistant with these entities:

| Entity | Type | Description |
|---|---|---|
| `vacuum.<name>` | Vacuum | Start / stop / pause / return / locate / fan speed |
| `sensor.<name>_battery` | Sensor | Battery level (%) |
| `sensor.<name>_rssi` | Sensor | WiFi signal strength (dBm) |
| `sensor.<name>_error_text` | Sensor | Current error description |
| `binary_sensor.<name>_charging` | Binary Sensor | Charging state |
| `binary_sensor.<name>_error` | Binary Sensor | Error state |

### Fan Speeds

`eco`, `normal`, `max`

### Room Cleaning (via `vacuum.send_command`)

```yaml
service: vacuum.send_command
target:
  entity_id: vacuum.shark_robot
data:
  command: clean_room
  params:
    room: "Kitchen"
```

For more commands (multi-room, Matrix Clean), see the
[shark2mqtt README](https://github.com/CamSoper/shark2mqtt#commands).

---

## Troubleshooting

- Set `log_level` to `DEBUG` and check the add-on log.
- If authentication keeps failing, try restarting the add-on — the browser
  session sometimes needs a fresh attempt.
- Make sure your MQTT broker is reachable from the add-on
  (ping `core-mosquitto` or your broker IP from a terminal add-on).
