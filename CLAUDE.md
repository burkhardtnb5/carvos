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

## Oberfläche (`ui/`)

- Starten mit automatischem Neuladen: `python3 ui/main.py --dev`
- Auf den Pi kopieren und neu starten: `provisioning/deploy-ui.sh`
- Bilder aller Seiten ohne Fenster: `ui/tools/screenshot.py ZIELORDNER [BREITExHÖHE]`
- Qt Quick (QML) mit PySide6. Der Pi hat nur Qt 6.8, der PC 6.10: keine neueren Funktionen als 6.8 nutzen.
- Das Projekt muss in Qt Design Studio bearbeitbar bleiben (`ui/carvos.qmlproject`):
  - Aussehen in `*.ui.qml`: keine Funktionen und keine `on...`-Handler. Bedienelemente per `property alias` nach außen geben.
  - Logik in `content/App.qml` bzw. später in Python.
  - Keine `QtQuick.Studio.*`-Komponenten, die gibt es auf dem Pi nicht.
- Farben, Größen und Schriften nur über `Theme`, Symbole über `Icons`. Eigenschaften nicht mit `on` + Großbuchstabe benennen (QML hält sie für Signal-Handler).
- Referenzgröße ist das echte Display: 1024x600. Änderungen zusätzlich mit 1280x800 prüfen.
