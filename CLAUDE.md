# CARVOS – Camper and Recreational Vehicle Operating System

Hub für selbstgebaute Wohnmobil-Systeme: Raspberry Pi stellt ein eigenes WLAN für
ESP-Nodes bereit, sammelt Daten per MQTT und zeigt sie auf einem Touchdisplay an.
Projektname in Code, Paketen, Diensten und Topics: `carvos` (klein), in Texten CARVOS.

- Farbschema: Grau als Hauptfarbe, Rot als Akzent (siehe `docs/ARCHITEKTUR.md`, Abschnitt Design).

- Architektur und alle getroffenen Entscheidungen: `docs/ARCHITEKTUR.md` – vor
  größeren Änderungen lesen, bei Architekturänderungen dort nachtragen.
- Aktueller Stand und nächste Schritte: `PLAN.md` – erledigte Punkte abhaken.

## Repo-Struktur

- `hub/` – carvosd (Python): Logik, Pairing, Alarme, SQLite, Service-Modus, Updates
- `ui/` – Touch-Oberfläche (Qt 6 QML + PySide6)
- `provisioning/` – Skripte zur Einrichtung des Pi (Pakete, hostapd, mosquitto, systemd)
- `firmware/` – Arduino-Firmware der ESP-Nodes
- `docs/` – Dokumentation

## Maschinen

- **Entwicklungs-PC** (Ubuntu 26.04, x86_64): Hauptentwicklung, UI läuft im Fenster.
- **Raspberry Pi 4** (`noah@192.168.1.111`, Raspberry Pi OS Lite 64 Bit, Trixie):
  Testgerät. `eth0` = Entwicklung/Internet, `wlan0` = Access Point des Hubs.
  Beim Umkonfigurieren von `wlan0` niemals `eth0` anfassen, sonst ist der Pi weg.
- Später: Raspberry Pi Zero 2W als günstiges Zielgerät (512 MB RAM – sparsam bleiben).

## Regeln

- Einrichtungsschritte am Pi immer als Skript in `provisioning/` festhalten und von
  dort ausführen, nie nur von Hand. Die Skripte müssen mehrfach ausführbar sein
  (idempotent), denn daraus wird später das Image für weitere Hubs gebaut.
- Pakete aus `apt` statt `pip`. Kein Docker.
- UI enthält keine Systemlogik; alles Systemnahe gehört in den carvosd.
- Sprache in Doku und Commits: Deutsch.
- Vor dem Arbeiten `git pull`, danach committen und pushen – PC und Pi arbeiten
  am selben Repo.
