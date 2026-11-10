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
                     │ carvosd (C++): Logik, Alarme, SQLite       │
                     │ carvos-ui (Qt 6 QML + C++, eglfs)          │
                     └────────────────────────────────────────────┘
 Kamera-Node ──MJPEG über HTTP direkt an die UI (nicht über MQTT)
```

## Hardware

- Entwicklung: Raspberry Pi 4 (8 GB). Ziel für günstige Einheiten: Raspberry Pi Zero 2W (512 MB).
- Früh und regelmäßig auf der Zero 2W testen (RAM, WLAN-Reichweite).
- Stromversorgung: 12→5-V-Wandler, mind. 3 A (Pi 4 + Display).
- RTC-Modul DS3231: ohne Internet gibt es keine Uhrzeit (wichtig für Verläufe).
- Nodes: bestehende ESP8266 bleiben. Für neue Nodes ESP32-C3 erwägen.
- Display: Hamtysan HCIK101V.CC, 10,1", 1024x600 (am Pi ausgelesen), HDMI,
  Touch per USB (`wch.cn USB2IIC_CTP_CONTROL`).

## Betriebssystem und Unterbau

- Raspberry Pi OS Lite **64 Bit** (Trixie) auf Pi 4 **und** Zero 2W – eine Architektur,
  ein Image. 32 Bit nur, falls die Zero nachweislich zu wenig RAM hat.
- Pakete aus `apt` statt `pip` (Qt 6.8, mosquitto 2.0).
- Dienste als systemd-Units, kein Docker.
- Benutzer: Dienste laufen künftig unter dem Standardbenutzer `carvos` ohne `sudo`.
  Derzeit läuft die Oberfläche noch als `noah` (Testgerät, in der `sudo`-Gruppe).
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

- **Sprachen:** C++ für Programme auf dem Gerät, QML für das Aussehen. Python nur für Hilfsskripte.
- **carvosd** (C++, systemd): Gerätezustände, Pairing, Automatisierungen,
  Alarme (z. B. Gas < 20 %), Verläufe in SQLite, Service-Modus, Updates.
- **carvos-ui** (Qt 6 QML, Logik in C++): zeigt an und schickt Befehle,
  enthält keine Systemlogik. Stürzt sie ab, läuft der Daemon weiter.
  - Auf dem Pi: `QT_QPA_PLATFORM=eglfs` (Vollbild ohne Desktop).
  - Auf dem PC: normales Fenster zum Entwickeln.
  - QML und Schriften sind einkompiliert, auf dem Pi liegt nur die Binärdatei `/opt/carvos/bin/carvos-ui`.
- MQTT-Bibliothek: Paho (nicht QtMqtt – nur GPL).
- Build: am PC für das Fenster direkt, für den Pi im Podman-Container (`ci/`, Debian Trixie, Qt 6.8).
  Der Container passt zum Pi; das Qt 6.10 des PCs darf nie in die Pi-Binärdatei gelangen.
- Gestaltung grafisch mit Qt Design Studio, Community Edition (`ui/carvos.qmlproject`):
  Aussehen in `*.ui.qml`, Logik getrennt davon. Start weiter über die eigene Binärdatei, nicht über
  den Python-Export von Design Studio. Zielversion Qt 6.8, keine Studio-eigenen Komponenten.
- Bildschirmtastatur: eigene QML-Tastatur oder Qt Virtual Keyboard (GPL).
- Später: Web-Oberfläche fürs Handy über MQTT-over-WebSockets.

## Design

Angelehnt an das Wohnmobil der Familie (Marke Challenger): **Grau als Hauptfarbe,
Rot als Akzent**. Nur das Farbschema übernehmen – kein Logo und keine Markennamen
der Firma in der UI, da das System auch weitergegeben wird.

- Farben zentral als Tokens im QML-Singleton `ui/imports/Carvos/Theme.qml`,
  nie direkt im Code. Werte noch am echten Display prüfen.
- Dunkles Grau als Standard-Hintergrund: blendet nachts im Wohnmobil nicht.
- **Rot-Konflikt:** Rot ist Akzentfarbe *und* übliche Alarmfarbe. Deshalb:
  - Akzent-Rot sparsam einsetzen (aktive Elemente, Auswahl, Schriftzug).
  - Warnungen gelb/orange, kritische Alarme zusätzlich mit Symbol, Text und
    Banner – nie nur über die Farbe unterscheiden.
- Hell- und Dunkelmodus: Umschalter auf der Seite „System“. Die Wahl liegt per `Settings`
  in `~/.config/CARVOS/`; mit Overlay-FS muss das später nach `/data`.
- Boot ohne sichtbare Meldungen (`provisioning/setup-quiet-boot.sh`). Ein eigenes Logo
  soll später zuerst als Startbild in der Oberfläche kommen, Plymouth nur bei Bedarf.
- Touch: Schaltflächen mind. ca. 10 mm groß, Schrift auch aus Abstand lesbar.

## Service-Modus

Die folgenden WLAN-Schritte kommen frühestens nach 1.0.0, bis dahin laufen Updates nur über Ethernet.

1. Über die UI aktivieren → hostapd stoppen, NetworkManager übernimmt `wlan0` als Client.
2. WLAN-Liste anzeigen, Netz wählen, Passwort über Bildschirmtastatur.
3. Verbindungsprüfung von NetworkManager nutzen: Anmeldeseite (Captive Portal)
   erkennen → Hinweis „Handy-Hotspot verwenden“.
4. Updates laden (siehe unten).
5. Automatisch zurück in den AP-Modus: nach Abschluss, bei Fehler oder nach
   15 Minuten ohne Eingabe.

Nodes verlieren währenddessen die Verbindung und verbinden sich danach selbst neu
(Reconnect mit wachsender Wartezeit in der Firmware).

### Umsetzung (Stand 2026-11-08, erste Stufe)

- Derzeit nur Schritt 4: Update über die bestehende Internetverbindung (`eth0`).
  WLAN-Client, Bildschirmtastatur und Rückkehr in den AP-Modus frühestens nach 1.0.0.
- Root-Dienst `carvos-service-mode.service` (oneshot) mit dem Skript
  `provisioning/files/carvos-service-mode`. Er schreibt seinen Stand nach
  `/run/carvos/service-mode` (`phase`, `message`, `invocation`), Phasen
  `start`, `netz`, `update`, `fertig`, `fehler`, und ruft `carvos-update online` auf.
- Die Oberfläche läuft ohne root. Die polkit-Regel `50-carvos.polkit` erlaubt der Gruppe `carvos`
  genau das Starten dieses Dienstes, sonst nichts. Wichtig: polkit nimmt die Gruppen des
  anfragenden Prozesses, deshalb steht `carvos` in `SupplementaryGroups` von `carvos-ui.service`.
- In der Oberfläche: Klasse `ServiceMode` (`ui/src/servicemode.*`) startet den Dienst per
  `systemctl start --no-block` und liest die Statusdatei, Anzeige im Vollbild `ServiceOverlay`.
  Später wandert das in carvosd.
- Entwicklermodus (Schalter auf der Seite System): zeigt im Overlay die Systemausgabe dieses
  Durchlaufs live an (`journalctl -f _SYSTEMD_INVOCATION_ID=…`, also auch die Ausgabe von
  `carvos-update`). Braucht Lesezugriff aufs Journal (Gruppe `adm` oder `systemd-journal`).
- Das Update startet die Oberfläche neu. Die neue Instanz erkennt den laufenden Service-Modus
  an der Statusdatei, öffnet das Overlay wieder und liest das Journal ab Beginn des Durchlaufs.
- Oneshot-Units (Update, Service-Modus) startet `carvos-update` nie neu und prüft sie nicht.

## Build und Auslieferung

```
Dev-PCs ── bauen Binärdateien für Hub und Nodes
   └─► Release im öffentlichen GitHub-Repo
          └─► Hub lädt es im Service-Modus und aktualisiert sich selbst
```

- Gebaut wird nur auf einem Dev-PC, nie auf dem Hub. Auf dem Hub liegen weder Repo noch
  Compiler. Auf dem Testgerät läuft derzeit zusätzlich Claude Code, das gehört nicht ins Image.
- Es gibt mehrere Dev-PCs (derzeit ein Windows- und ein Ubuntu-PC, siehe `CLAUDE.md`). Jeder muss allein
  bauen und veröffentlichen können, der Build darf nichts von einem bestimmten Rechner voraussetzen:
  Binärdateien entstehen im Container (`ci/`), die nötigen Pakete stehen in `CLAUDE.md`.
- Die Node-Firmware wird ebenfalls auf einem Dev-PC gebaut und bis auf Weiteres per USB geflasht.
- Binärdateien nutzen die Qt-Bibliotheken des Betriebssystems. Braucht ein Release andere
  Systempakete, kommt das als neues SD-Image, nicht über das normale Update.

## Updates des Hubs

- Hub-Updates sind nicht für unterwegs gedacht, sondern für zu Hause mit fester Verbindung.
- **Entwicklungsphase (alle Versionen vor 1.0.0):** Entwickelt und getestet wird ausschließlich
  auf dem Entwicklungs-Raspberry-Pi 4. Hub-Updates laufen in dieser Phase nur über Ethernet (`eth0`),
  ein WLAN-Client für Updates wird dafür nicht eingerichtet.

Kein `git pull` auf dem Gerät. Stattdessen:

1. Getaggte Releases mit den Binärdateien als Archiv (z. B. GitHub Release `carvos-1.4.0.tar.gz`),
   signiert mit `minisign`.
2. Hub prüft die Signatur, entpackt nach `/data/releases/<version>/`.
3. Symlink `/data/current` atomar umschalten (`rename`), Dienste neu starten.
4. Health-Check (systemd-Watchdog oder MQTT-Heartbeat) innerhalb von 60 s,
   sonst automatisch zurück zur vorigen Version.
5. Die letzten 2–3 Versionen behalten.

### Umsetzung (Stand 2026-11-08)

- Paket `carvos-hub-arm64.tar.gz` mit `VERSION`, `bin/` und `provisioning/`, daneben die Signatur
  `carvos-hub-arm64.tar.gz.minisig`. Gepackt von `ci/package-hub.sh`, veröffentlicht von `ci/release.sh`
  (Tag `vX.Y.Z`).
- Mehrere Dev-PCs: Jeder hat seinen eigenen geheimen Schlüssel (Standard `~/.minisign/carvos.key`, verlässt
  den PC nie). Die öffentlichen liegen als `provisioning/files/minisign.d/<pc-name>.pub` im Repo und auf dem
  Hub unter `/etc/carvos/minisign.d/`. Ein Release braucht eine Signatur, die zu einem davon passt.
  - Neuer PC: `minisign -G -p provisioning/files/minisign.d/<pc-name>.pub -s ~/.minisign/carvos.key`,
    einchecken, pushen. `ci/release.sh` bricht ab, solange der eigene Schlüssel dort fehlt.
  - Die Liste kommt mit jedem Release und wird nach erfolgreichem Update übernommen (nie leer).
  - PC verloren: seine `.pub` löschen und vom anderen PC ein Release machen. Hubs mit diesem Release
    nehmen den alten Schlüssel nicht mehr an. Bis dahin schützt nur, dass für ein Release auch
    Schreibzugriff aufs GitHub-Repo nötig ist.
- `/opt/carvos` → `/data/current` → `/data/releases/<version>`. Units und udev-Regeln verweisen weiter
  auf `/opt/carvos/...`, das Umschalten des Symlinks reicht.
- `carvos-update` (Shell-Skript, `/usr/local/sbin`, eingerichtet von `provisioning/setup-updater.sh`):
  - `online`: fragt die GitHub-API nach dem neuesten Release (`releases/latest`), lädt nur, wenn es
    neuer ist, prüft die Signatur, entpackt, schaltet um.
  - Installiert danach die `carvos-*.service`-Units und `*.rules` der neuen Version nach `/etc`,
    entfernt die, die nur die alte Version hatte, und startet die Dienste neu.
  - Health-Check nach 30 s: Jeder Dienst läuft ohne automatischen Neustart oder wurde per
    `ExecCondition` bewusst übersprungen (Oberfläche ohne Bildschirm). Sonst zurück zur vorigen
    Version, die neue wird als fehlerhaft markiert und nicht erneut geladen.
  - Kein Downgrade über `online`; Versionen vergleicht `dpkg --compare-versions`.
  - Stromausfall mitten im Update: `/data/state/pending` bleibt liegen, `carvos-update-boot.service`
    prüft beim nächsten Start erneut und nimmt zurück, wenn nötig.
  - Das Skript aktualisiert sich selbst aus dem Release, aber erst nach erfolgreichem Health-Check.
- Ausgelöst über `carvos-update.service` (oneshot). Der Service-Modus startet ihn später; bis dahin von Hand
  `sudo systemctl start carvos-update`. Die Schnittstelle ist nicht fest: geladen wird über die
  Standardroute. Bis 1.0.0 ist das nur `eth0`; `wlan0` als Client frühestens danach.
- Entwicklung: `provisioning/deploy-ui.sh` packt denselben Paketaufbau und spielt ihn per
  `carvos-update install --unsigned` ein. Damit wird bei jedem Deploy auch der Update-Weg getestet.
- Solange das Repo privat ist, braucht der Hub ein Token in `/etc/carvos/github-token`. Ziel bleibt
  das öffentliche Repo ohne Zugangsdaten.
- Mit Overlay-FS später: `/etc`-Dateien (Units, Regeln, Update-Programm) müssen auf `/data` oder
  über das Overlay hinaus geschrieben werden – noch offen.

Das Repo wird dafür öffentlich, sonst bräuchte jeder Hub Zugangsdaten zum Laden der Releases.

Betriebssystem-Updates (Qt, Debian) selten und als neues SD-Image.
Update der Node-Firmware über den Hub: langfristig geplant, aber erst in ferner Zukunft.
Das Release-Format soll Firmware später aufnehmen können, ohne dass sich das Verfahren ändert.

### Idee für die ferne Zukunft: Systempakete im Release

Bis dahin gilt: Neue Systempakete kommen mit einem neuen SD-Image. Später könnte das signierte
Release auch `.deb`-Pakete mitbringen:

- Der Dev-PC packt Pakete samt Abhängigkeiten ins Release. Die Signatur deckt jede Datei ab, und
  alle Hubs bekommen genau den getesteten Stand. Kein Live-`apt` auf dem Hub: Dort können getestete
  Versionen aus den Quellen verschwinden, und bei falscher Uhr kann `apt` Quellen ablehnen.
- Ein eigener Root-Dienst `carvos-updater` prüft die Signatur und installiert. Die UI stößt ihn nur an.
- Das Manifest erlaubt nur konkrete Pakete mit fester Version, keine beliebigen Befehle, kein
  `apt upgrade` und keine Downgrades.
- Die Installation muss das Overlay umgehen, sonst ist sie nach dem Neustart weg (Weg noch offen,
  z. B. eigener Wartungsstart). `apt` braucht auf dem Pi 4 bis zu 148 MB RAM, auf der Zero ungetestet.
- Risiken: Pakete führen Skripte als root aus, der Signaturschlüssel bedeutet damit root auf allen
  Hubs und gehört offline. Es gibt kein zuverlässiges Zurückrollen, und ein Stromausfall kann eine
  Neuinstallation der SD-Karte erfordern. Wirklich abgesichert wäre das erst mit A/B-Systempartitionen.
- Größere Sprünge (neues Debian, neues Qt) bleiben ein Fall für ein neues Image.

## Verteilung an Freunde

Später ein fertiges Image mit `rpi-image-gen` oder `pi-gen` bauen. Dafür müssen
alle Einrichtungsschritte des Pi als Skripte in `provisioning/` liegen, nie nur
von Hand ausgeführt werden.

## Offene Punkte / Risiken

- WPS auf dem ESP8266 im echten Test
- Maximale Anzahl Nodes im AP-Modus (Pi 4 und Zero 2W)
- WLAN-Reichweite im Fahrzeug (Gaskasten, Unterboden)
- RAM-Verbrauch des gesamten Stacks auf der Zero 2W
- Bearbeitung des Projekts in Qt Design Studio (noch nicht getestet)
