#!/bin/sh
# Wird von udev bei Änderungen am Grafikanschluss aufgerufen (99-carvos-display.rules).
# Bildschirm eingesteckt -> Oberfläche starten, abgezogen -> stoppen.
# Nach erneutem Einstecken startet die Oberfläche damit immer frisch.
if /opt/carvos/provisioning/files/display-connected.sh; then
    systemctl start --no-block carvos-ui.service
else
    systemctl stop --no-block carvos-ui.service
fi
