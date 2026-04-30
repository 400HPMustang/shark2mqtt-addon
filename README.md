# Shark2MQTT — Home Assistant Add-on Repository

[![Open your Home Assistant instance and show the add-on store.](https://my.home-assistant.io/badges/supervisor_store.svg)](https://my.home-assistant.io/redirect/supervisor_store/)

This repository hosts the **Shark2MQTT** Home Assistant add-on, which bridges
SharkNinja robot vacuums to Home Assistant via MQTT autodiscovery.

It wraps [CamSoper/shark2mqtt](https://github.com/CamSoper/shark2mqtt) in an
HA-native add-on so you get a proper UI configuration form, persistent token
storage, and integration with the Supervisor — no separate Docker setup needed.

---

## Installation

1. In Home Assistant, go to **Settings → Add-ons → Add-on Store**.
2. Click the three-dot menu (⋮) in the top-right and choose **Repositories**.
3. Add this repository URL:
   ```
   https://github.com/400HPMustang/shark2mqtt-addon
   ```
4. Find **Shark2MQTT** in the store, click **Install**, then configure and start it.

> **Prerequisites:** You need the **Mosquitto** MQTT broker add-on (or another
> MQTT broker) and the **MQTT integration** set up in Home Assistant first.

---

## Add-ons in this repository

### Shark2MQTT

Bridge SharkNinja robot vacuums to Home Assistant via MQTT autodiscovery.

See [shark2mqtt/DOCS.md](shark2mqtt/DOCS.md) for full documentation.

---

## Credits

All the hard work is by [Cam Soper](https://github.com/CamSoper) — this
repository just adds the HA add-on wrapper. See the upstream project for
support, issues, and contributing.
