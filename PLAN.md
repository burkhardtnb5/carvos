# Plan

Reihenfolge so gewählt, dass die größten Risiken früh geprüft werden.
Erledigte Punkte abhaken.

## Oberfläche (vorgezogen)
- [x] Grundgerüst mit vier Seiten: Übersicht, Gas, Grauwasser, System (feste Beispielwerte)
- [x] Automatisches Neuladen und Screenshot-Werkzeug
- [x] Umstellung von Python auf C++, ARM-Build auf dem PC im Container
- [x] Hell-/Dunkelmodus
- [x] Bootmeldungen und Regenbogenbild ausblenden
- [ ] Später: Startzeit verkürzen (Oberfläche wartet unnötig aufs Netz, cloud-init abschalten)
- [ ] Später: eigenes Logo beim Start
- [ ] Projekt in Qt Design Studio öffnen und testen
- [x] Automatischer Start auf dem Pi mit eglfs (`provisioning/setup-kiosk.sh`)
- [x] Auf dem echten Display prüfen (Darstellung, Touch)

## Phase 0 – Einrichtung
- [x] git auf dem PC installieren, GitHub-Repo (privat) einrichten, pushen
- [x] Build-Werkzeuge auf dem PC (CMake, Qt, Podman)
- [ ] SSH-Key vom PC auf dem Pi hinterlegen

## Phase 1 – Risiken prüfen
- [ ] hostapd-AP auf `wlan0` des Pi 4 (Testnetz, WPA2)
- [ ] WPS-PBC mit einem ESP8266 testen (`hostapd_cli wps_pbc` + `WiFi.beginWPSConfig()`)
- [ ] Mehrere ESPs gleichzeitig verbinden (Grenze des AP-Modus)

## Phase 2 – Grundgerüst
- [ ] Mosquitto einrichten, Topic-Schema umsetzen
- [ ] carvosd: Zustände sammeln, Online-Status, SQLite-Verlauf
- [ ] carvos-ui: Anzeige der Gasflaschenwaage (PC im Fenster, Pi mit eglfs)
- [ ] Firmware-Build auf dem Dev-PC einrichten (ohne Abhängigkeit von diesem Rechner)
- [ ] Firmware Gasflaschenwaage auf neues Topic-Schema umstellen
- [ ] systemd-Unit für carvosd (die der Oberfläche gibt es schon)

## Phase 3 – Netzwerk und Pairing
- [ ] Erststart: UUID, SSID, Passwort erzeugen und unter `/data` ablegen
- [ ] Pairing-Ablauf in Daemon und UI (Announce, Bestätigen, Benennen)
- [ ] Grauwasserventil + Kamera-Stream in der UI

## Phase 4 – Service-Modus und Updates
- [ ] Service-Modus vollständig (WLAN-Suche, Bildschirmtastatur, Captive-Portal-Hinweis, Timeout)
- [ ] Repo öffentlich machen (vorher Historie auf Secrets prüfen)
- [x] Release-Paket auf dem Dev-PC bauen und signieren, auf GitHub veröffentlichen (`ci/release.sh`, noch ungetestet)
- [x] Selbst-Update des Hubs: Download, Signatur, Symlink-Umschaltung, Health-Check, Rollback (`carvos-update`)
- [x] minisign-Schlüssel pro Dev-PC erzeugen, `provisioning/files/minisign.d/<pc-name>.pub` einchecken (`noahs_pc`, `ubuntu-pc`)
- [ ] Erstes echtes Release mit `ci/release.sh` und Test auf dem Pi
- [x] Service-Modus-Knopf startet das Update (erste Stufe, über `eth0`), Entwicklermodus mit Systemausgabe
- [ ] Service-Modus und Entwicklermodus auf dem echten Display testen

## Phase 5 – Fahrzeugtauglich machen
- [ ] Standardbenutzer `carvos` ohne `sudo` anlegen, Dienste darunter laufen lassen
- [ ] Overlay-FS + `/data`-Partition
- [ ] RTC DS3231
- [ ] Stromversorgung 12→5 V

## Phase 6 – Zero 2W und Verteilung
- [ ] Kompletten Stack auf der Zero 2W testen (RAM, Reichweite)
- [ ] Image mit `rpi-image-gen`/`pi-gen` bauen

## Ferne Zukunft
- [ ] Node-Updates über den Hub
- [ ] Systempakete im signierten Release (siehe `docs/ARCHITEKTUR.md`)
