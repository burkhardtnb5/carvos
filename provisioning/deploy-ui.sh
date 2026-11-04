#!/bin/bash
# Kopiert die fertige Binärdatei und die Einrichtung auf den Pi und startet die Oberfläche neu.
# Vorher bauen: ci/build-arm64.sh
# Aufruf: provisioning/deploy-ui.sh [BENUTZER@PI]
set -euo pipefail

PI=${1:-noah@192.168.1.111}
REPO=$(cd "$(dirname "$0")/.." && pwd)
BINARY=$REPO/build/arm64/ui/carvos-ui

ssh -t "$PI" 'sudo install -d -o "$USER" -g "$USER" /opt/carvos /opt/carvos/bin'
rsync -a --delete "$REPO/provisioning" "$PI:/opt/carvos/"
rsync -a "$BINARY" "$PI:/opt/carvos/bin/carvos-ui"
ssh -t "$PI" 'if systemctl list-unit-files carvos-ui.service | grep -q carvos-ui; then sudo systemctl restart carvos-ui.service; fi'
