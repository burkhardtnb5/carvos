#!/bin/bash
# Kopiert Oberfläche und Einrichtung vom PC auf den Pi und startet die Oberfläche neu.
# Aufruf: provisioning/deploy-ui.sh [BENUTZER@PI]
set -euo pipefail

PI=${1:-noah@192.168.1.111}
REPO=$(cd "$(dirname "$0")/.." && pwd)

ssh -t "$PI" 'sudo install -d -o "$USER" -g "$USER" /opt/carvos'
rsync -a --delete --exclude __pycache__ "$REPO/ui" "$REPO/provisioning" "$PI:/opt/carvos/"
ssh -t "$PI" 'if systemctl list-unit-files carvos-ui.service | grep -q carvos-ui; then sudo systemctl restart carvos-ui.service; fi'
