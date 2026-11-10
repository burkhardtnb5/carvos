# CARVOS – Camper and Recreational Vehicle Operating System

Hub für selbstgebaute Wohnmobil-Systeme: Raspberry Pi stellt ein eigenes WLAN für
ESP-Nodes bereit, sammelt Daten per MQTT und zeigt sie auf einem Touchdisplay an.
Projektname in Code, Paketen, Diensten und Topics: `carvos` (klein), in Texten CARVOS.

- Farbschema: Grau als Hauptfarbe, Rot als Akzent (siehe `docs/ARCHITEKTUR.md`, Abschnitt Design).

- Architektur und alle getroffenen Entscheidungen: `docs/ARCHITEKTUR.md` – vor
  größeren Änderungen lesen, bei Architekturänderungen dort nachtragen.
- Aktueller Stand und nächste Schritte: `PLAN.md` – erledigte Punkte abhaken.

## Repo-Struktur

- `hub/` – carvosd (C++): Logik, Pairing, Alarme, SQLite, Service-Modus, Updates
- `ui/` – Touch-Oberfläche (Qt 6 QML + C++)
- `ci/` – Build für den Pi im Podman-Container
- `provisioning/` – Skripte zur Einrichtung des Pi (Pakete, hostapd, mosquitto, systemd)
- `firmware/` – Arduino-Firmware der ESP-Nodes
- `docs/` – Dokumentation

## Maschinen

- **Dev-PCs**: Nur hier wird gebaut, für Hub und Nodes. Jeder Dev-PC muss alles allein bauen
  und veröffentlichen können, nichts darf von einem bestimmten Rechner abhängen.
  - Haupt-PC: Windows, im Tailscale-Netz `noahs-pc`, Signaturschlüssel `noahs_pc.pub`.
    Wie dort gebaut wird (z. B. WSL), ist hier noch nicht festgehalten.
  - Zweit-PC: Ubuntu 26.04, x86_64, Hostname `ubuntu`, Signaturschlüssel `ubuntu-pc.pub`.

  Nötige Pakete auf einem Dev-PC (Namen für Ubuntu/Debian):
  - Bauen: `build-essential cmake ninja-build qt6-base-dev qt6-declarative-dev qt6-declarative-dev-tools`
  - Oberfläche am PC starten: `qml6-module-qtcore qml6-module-qtquick qml6-module-qtquick-controls
    qml6-module-qtquick-layouts qml6-module-qtquick-window qml6-module-qtquick-templates
    qml6-module-qtquick-shapes qml6-module-qtqml-workerscript qml6-module-qtqml-models`
  - Build für den Pi: `podman`
  - Releases und Deploy: `git gh minisign openssh-client rsync`
  - Screenshot-Werkzeug: `python3-pyside6.qtcore python3-pyside6.qtgui python3-pyside6.qtqml
    python3-pyside6.qtquick python3-pyside6.qtquickcontrols2`
  Für Releases: eigener geheimer Schlüssel `~/.minisign/carvos.key`, dazu passend
  `provisioning/files/minisign.d/<pc-name>.pub` im Repo (siehe `docs/ARCHITEKTUR.md`).
- **Raspberry Pi 4** (`noah@raspberrypi.local`, Raspberry Pi OS Lite 64 Bit, Trixie):
  Testgerät, die IP-Adresse wechselt je nach Netz. `eth0` = Entwicklung/Internet, `wlan0` = Access Point des Hubs.
  Beim Umkonfigurieren von `wlan0` niemals `eth0` anfassen, sonst ist der Pi weg.
  - `/opt/carvos` ist ein Symlink auf die aktive Version unter `/data/releases/` (`carvos-update status`).
  - Oberfläche: Binärdatei `/opt/carvos/bin/carvos-ui`, gestartet von `carvos-ui.service`
    mit eglfs, ohne Desktop (`provisioning/setup-kiosk.sh`).
    Ohne Bildschirm startet sie nicht (`ExecCondition`); beim Einstecken startet udev sie,
    beim Abziehen stoppt sie (`provisioning/files/99-carvos-display.rules`).
  - Boot ohne Regenbogenbild und Meldungen (`provisioning/setup-quiet-boot.sh`, Originale
    als `.orig` in `/boot/firmware`). Fehler stehen nicht auf dem Display, sondern in `journalctl -b`.
  - Der Pi hat kein Repo: In der Entwicklung bekommt er ein Paket per SSH vom Dev-PC
    (`provisioning/deploy-ui.sh`), sonst aktualisiert er sich mit `carvos-update` aus den GitHub-Releases.
- Später: Raspberry Pi Zero 2W als günstiges Zielgerät (512 MB RAM – sparsam bleiben).

## Regeln

- Einrichtungsschritte am Pi immer als Skript in `provisioning/` festhalten und von
  dort ausführen, nie nur von Hand. Die Skripte müssen mehrfach ausführbar sein
  (idempotent), denn daraus wird später das Image für weitere Hubs gebaut.
- Auf dem Gerät: Pakete aus `apt` statt `pip`, kein Docker. Gebaut wird am PC mit Podman.
- UI enthält keine Systemlogik; alles Systemnahe gehört in den carvosd.
- Sprache in Doku und Commits: Deutsch.
- Vor dem Arbeiten `git pull`. Committen und pushen erst nach Freigabe durch den Nutzer,
  meist nachdem er den Stand auf dem echten Display getestet hat.

## Oberfläche (`ui/`)

- Am PC bauen: `cmake -S . -B build/pc -G Ninja && cmake --build build/pc`
- Starten mit automatischem Neuladen: `build/pc/ui/carvos-ui --dev ui`
- Für den Pi bauen (kompiliert immer auf dem PC, nie auf dem Pi): `ci/build-arm64.sh`
- Auf den Pi spielen (als Paket, wie ein Update): `provisioning/deploy-ui.sh [noah@HOST]`
- Release veröffentlichen: `ci/release.sh 1.2.3` (baut, packt, signiert, `gh release create`)
- Bilder aller Seiten ohne Fenster: `ui/tools/screenshot.py ZIELORDNER [BREITExHÖHE]`
- Qt Quick (QML) mit C++. Neue QML-Dateien auch in der passenden `CMakeLists.txt` eintragen (und in `imports/Carvos/qmldir`). Der Pi hat nur Qt 6.8, der PC 6.10: keine neueren Funktionen als 6.8 nutzen.
- Das Projekt muss in Qt Design Studio bearbeitbar bleiben (`ui/carvos.qmlproject`):
  - Aussehen in `*.ui.qml`: keine Funktionen und keine `on...`-Handler. Bedienelemente per `property alias` nach außen geben.
  - Logik in `content/App.qml` bzw. später in C++.
  - Keine `QtQuick.Studio.*`-Komponenten, die gibt es auf dem Pi nicht.
- Farben, Größen und Schriften nur über `Theme`, Symbole über `Icons`. Eigenschaften nicht mit `on` + Großbuchstabe benennen (QML hält sie für Signal-Handler).
- Referenzgröße ist das echte Display: 1024x600. Änderungen zusätzlich mit 1280x800 prüfen.
