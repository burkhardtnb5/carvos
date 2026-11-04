# Plan

Reihenfolge so gewählt, dass die größten Risiken früh geprüft werden.
Erledigte Punkte abhaken.

## Oberfläche (vorgezogen)
- [x] Grundgerüst mit vier Seiten: Übersicht, Gas, Grauwasser, System (feste Beispielwerte)
- [x] Automatisches Neuladen und Screenshot-Werkzeug
- [ ] Projekt in Qt Design Studio öffnen und testen
- [x] Automatischer Start auf dem Pi mit eglfs (`provisioning/setup-kiosk.sh`)
- [x] Auf dem echten Display prüfen (Darstellung, Touch)

## Phase 0 – Einrichtung
- [ ] git auf dem PC installieren, GitHub-Repo (privat) anlegen, pushen
- [ ] SSH-Key vom PC auf dem Pi hinterlegen
- [ ] Claude Code auf dem Pi installieren und anmelden, Repo auf dem Pi klonen
- [ ] Qt 6 / PySide6 auf PC und Pi installieren (`provisioning/`-Skript)

## Phase 1 – Risiken prüfen
- [ ] hostapd-AP auf `wlan0` des Pi 4 (Testnetz, WPA2)
- [ ] WPS-PBC mit einem ESP8266 testen (`hostapd_cli wps_pbc` + `WiFi.beginWPSConfig()`)
- [ ] Mehrere ESPs gleichzeitig verbinden (Grenze des AP-Modus)

## Phase 2 – Grundgerüst
- [ ] Mosquitto einrichten, Topic-Schema umsetzen
- [ ] carvosd: Zustände sammeln, Online-Status, SQLite-Verlauf
- [ ] carvos-ui: Anzeige der Gasflaschenwaage (PC im Fenster, Pi mit eglfs)
- [ ] Firmware Gasflaschenwaage auf neues Topic-Schema umstellen
- [ ] systemd-Units für Daemon und UI

## Phase 3 – Netzwerk und Pairing
- [ ] Erststart: UUID, SSID, Passwort erzeugen und unter `/data` ablegen
- [ ] Pairing-Ablauf in Daemon und UI (Announce, Bestätigen, Benennen)
- [ ] Grauwasserventil + Kamera-Stream in der UI

## Phase 4 – Service-Modus und Updates
- [ ] Service-Modus (WLAN-Suche, Bildschirmtastatur, Captive-Portal-Hinweis, Timeout)
- [ ] Release-Updates mit Signatur, Symlink-Umschaltung, Health-Check, Rollback

## Phase 5 – Fahrzeugtauglich machen
- [ ] Overlay-FS + `/data`-Partition
- [ ] RTC DS3231
- [ ] Stromversorgung 12→5 V

## Phase 6 – Zero 2W und Verteilung
- [ ] Kompletten Stack auf der Zero 2W testen (RAM, Reichweite)
- [ ] Image mit `rpi-image-gen`/`pi-gen` bauen
