# CARVOS – Architektur

CARVOS = **C**amper **a**nd **R**ecreational **V**ehicle **O**perating **S**ystem.
Projektname in Code, Paketen, Diensten und Topics: `carvos`.

Stand: 2026-11-02. Dieses Dokument hält die getroffenen Entscheidungen fest.
Änderungen an der Architektur hier nachtragen, nicht nur im Chat.

## Ziel

Ein zentraler Hub für selbstgebaute Wohnmobil-Systeme (Nodes). Der Hub stellt ein
eigenes WLAN bereit, in das sich die Nodes einhängen, sammelt ihre Daten per MQTT
und bietet eine Touch-Oberfläche (10,1" Display). Das System soll später an Freunde
und Familie weitergegeben werden, also mehrere Hubs nebeneinander auf einem
Campingplatz problemlos funktionieren.

Bestehende Nodes:
- Gasflaschenwaage (Füllstand)
- Fernsteuerbares Grauwasserventil mit Kamera

## Übersicht

```
 ESP-Nodes ──WLAN (WPA2, eigenes Netz pro Hub)──┐
                                                ▼
                     ┌──────────── Hub (Raspberry Pi) ────────────┐
                     │ hostapd (AP)   mosquitto (MQTT-Broker)     │
                     │ carvosd (Python): Logik, Alarme, SQLite    │
                     │ carvos-ui (Qt 6 QML + PySide6, eglfs)      │
                     └────────────────────────────────────────────┘
 Kamera-Node ──MJPEG über HTTP direkt an die UI (nicht über MQTT)
```

## Hardware

- Entwicklung: Raspberry Pi 4 (8 GB). Ziel für günstige Einheiten: Raspberry Pi Zero 2W (512 MB).
- Früh und regelmäßig auf der Zero 2W testen (RAM, WLAN-Reichweite).
- Stromversorgung: 12→5-V-Wandler, mind. 3 A (Pi 4 + Display).
- RTC-Modul DS3231: ohne Internet gibt es keine Uhrzeit (wichtig für Verläufe).
- Nodes: bestehende ESP8266 bleiben. Für neue Nodes ESP32-C3 erwägen.

## Betriebssystem und Unterbau

- Raspberry Pi OS Lite **64 Bit** (Trixie) auf Pi 4 **und** Zero 2W – eine Architektur,
  ein Image. 32 Bit nur, falls die Zero nachweislich zu wenig RAM hat.
- Pakete aus `apt` statt `pip` (Qt 6.8, PySide6 6.8, mosquitto 2.0, python3-paho-mqtt 2.1).
- Dienste als systemd-Units, kein Docker.
- Root-Dateisystem schreibgeschützt (Overlay-FS). Schreibbare Daten unter `/data`
  (eigene Partition): Konfiguration, SQLite, Releases.
- Netzwerk-Schnittstellen:
  - `wlan0`: Access Point des Hubs (hostapd).
  - `eth0`: nur Entwicklung/Wartung (Internet, SSH). Im Fahrzeug nicht nötig.

## Netzwerk der Nodes

- Access Point mit **hostapd** (nicht NetworkManager-Hotspot – der kann kein WPS).
- 2,4 GHz, fester Kanal (1/6/11), in der UI änderbar.
- WPA2-PSK. **Kein** WPA3/Mixed-Mode (ESP8266 kann das nicht zuverlässig).
- SSID sichtbar (hostapd deaktiviert WPS bei versteckter SSID).
- Beim ersten Start erzeugt der Hub:
  - eine UUID,
  - die SSID `CARVOS-<erste 8 Hex-Zeichen der UUID>` (max. 32 Zeichen erlaubt),
  - ein zufälliges WPA2-Passwort (32 Zeichen), das nie angezeigt werden muss.
  Alles wird unter `/data` gespeichert.
- Kein Internet im Normalbetrieb.
- Erwartung: 5–10 Nodes. Der Onboard-Chip schafft im AP-Modus erfahrungsgemäß
  nur ca. 8–10 Clients → früh mit allen Nodes testen. Plan B: externer Reiserouter.

## Node-Pairing (WPS-PBC)

1. Am Hub „Gerät hinzufügen“ → `hostapd_cli wps_pbc` (WPS 2 Minuten offen,
   bestehende Nodes bleiben verbunden).
2. Knopf an der Node → `WiFi.beginWPSConfig()` (ESP8266-Arduino-Core).
3. Node erhält SSID + Passwort, speichert sie im Flash.
4. Broker-Adresse = Gateway aus DHCP (der Hub) – keine feste IP in der Firmware.
5. Node meldet sich: `carvos/pairing/announce` mit `{"id":"<chip-id>","type":"<typ>"}`.
6. Hub fragt am Display nach Bestätigung und Name. Erst dann ist die Node aktiv.

- Nur Tastendruck-Methode, **WPS-PIN deaktiviert**.
- Zwei Hubs gleichzeitig im Pairing → WPS-Overlap-Erkennung bricht ab, erneut versuchen.
- WPA2-Netz ist die Sicherheitsgrenze. Optional später: Mosquitto Dynamic Security
  mit eigenen Zugangsdaten pro Node.
- Risiko: WPS im ESP8266-Core ist wenig gepflegt → als Erstes testen.
- Fallback, falls WPS unzuverlässig: temporäres Pairing-Netz `CARVOS-PAIR` mit festem
  Passwort, Node holt echte Zugangsdaten per HTTP vom Hub.
- Folge: Firmware bleibt eigene Arduino-Firmware (ESPHome kann kein WPS).

## MQTT

- Mosquitto 2, MQTT 5.
- Topics:
  - `carvos/<node-id>/state` – Zustand (retained)
  - `carvos/<node-id>/set` – Befehle an die Node
  - `carvos/<node-id>/status` – `online`/`offline` (Last Will, retained)
  - `carvos/pairing/announce` – Anmeldung neuer Nodes
- Discovery-Payloads im Home-Assistant-MQTT-Discovery-Format, damit Nodes später
  auch mit Home Assistant funktionieren.
- Kamerabilder nicht über MQTT, sondern MJPEG per HTTP direkt von der Kamera-Node.

## Software

- **carvosd** (Python, systemd): Gerätezustände, Pairing, Automatisierungen,
  Alarme (z. B. Gas < 20 %), Verläufe in SQLite, Service-Modus, Updates.
- **carvos-ui** (Qt 6 QML, Logik in Python/PySide6): zeigt an und schickt Befehle,
  enthält keine Systemlogik. Stürzt sie ab, läuft der Daemon weiter.
  - Auf dem Pi: `QT_QPA_PLATFORM=eglfs` (Vollbild ohne Desktop).
  - Auf dem PC: normales Fenster zum Entwickeln.
  - Falls die Zero zu langsam ist: Logik nach C++ verschieben, QML bleibt.
- MQTT-Bibliothek: paho-mqtt (nicht QtMqtt – nur GPL).
- Bildschirmtastatur: eigene QML-Tastatur oder Qt Virtual Keyboard (GPL).
- Später: Web-Oberfläche fürs Handy über MQTT-over-WebSockets.

## Design

Angelehnt an das Wohnmobil der Familie (Marke Challenger): **Grau als Hauptfarbe,
Rot als Akzent**. Nur das Farbschema übernehmen – kein Logo und keine Markennamen
der Firma in der UI, da das System auch weitergegeben wird.

- Farben zentral als Tokens in einem QML-Singleton (`Theme.qml`) definieren,
  nie direkt im Code. Konkrete Werte beim Bau der UI am echten Display festlegen.
- Dunkles Grau als Standard-Hintergrund: blendet nachts im Wohnmobil nicht.
- **Rot-Konflikt:** Rot ist Akzentfarbe *und* übliche Alarmfarbe. Deshalb:
  - Akzent-Rot sparsam einsetzen (aktive Elemente, Auswahl, Schriftzug).
  - Warnungen gelb/orange, kritische Alarme zusätzlich mit Symbol, Text und
    Banner – nie nur über die Farbe unterscheiden.
- Touch: Schaltflächen mind. ca. 10 mm groß, Schrift auch aus Abstand lesbar.

## Service-Modus

1. Über die UI aktivieren → hostapd stoppen, NetworkManager übernimmt `wlan0` als Client.
2. WLAN-Liste anzeigen, Netz wählen, Passwort über Bildschirmtastatur.
3. Verbindungsprüfung von NetworkManager nutzen: Anmeldeseite (Captive Portal)
   erkennen → Hinweis „Handy-Hotspot verwenden“.
4. Updates laden (siehe unten).
5. Automatisch zurück in den AP-Modus: nach Abschluss, bei Fehler oder nach
   15 Minuten ohne Eingabe.

Nodes verlieren währenddessen die Verbindung und verbinden sich danach selbst neu
(Reconnect mit wachsender Wartezeit in der Firmware).

## Updates des Hubs

Kein `git pull` auf dem Gerät. Stattdessen:

1. Getaggte Releases als Archiv (z. B. GitHub Release `carvos-1.4.0.tar.gz`),
   signiert mit `minisign`.
2. Hub prüft die Signatur, entpackt nach `/data/releases/<version>/`.
3. Symlink `/data/current` atomar umschalten (`rename`), Dienste neu starten.
4. Health-Check (systemd-Watchdog oder MQTT-Heartbeat) innerhalb von 60 s,
   sonst automatisch zurück zur vorigen Version.
5. Die letzten 2–3 Versionen behalten.

Betriebssystem-Updates (Qt, Debian) selten und als neues SD-Image.
Update der Node-Firmware über den Hub: **vorerst nicht geplant**.

## Verteilung an Freunde

Später ein fertiges Image mit `rpi-image-gen` oder `pi-gen` bauen. Dafür müssen
alle Einrichtungsschritte des Pi als Skripte in `provisioning/` liegen, nie nur
von Hand ausgeführt werden.

## Offene Punkte / Risiken

- WPS auf dem ESP8266 im echten Test
- Maximale Anzahl Nodes im AP-Modus (Pi 4 und Zero 2W)
- WLAN-Reichweite im Fahrzeug (Gaskasten, Unterboden)
- RAM-Verbrauch des gesamten Stacks auf der Zero 2W
- Display-Modell und Touch-Ausrichtung unter eglfs
