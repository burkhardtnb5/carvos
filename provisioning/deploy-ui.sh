#!/bin/bash
# Spielt den aktuellen Entwicklungsstand auf den Pi – über denselben Weg wie ein Release-Update.
# Vorher bauen: ci/build-arm64.sh
# Aufruf: provisioning/deploy-ui.sh [BENUTZER@PI]
# Einmalig vorher auf dem Pi: provisioning/setup-updater.sh (siehe unten).
set -euo pipefail

PI=${1:-noah@raspberrypi.local}
REPO=$(cd "$(dirname "$0")/.." && pwd)
PKG=$REPO/build/dev/carvos-hub-arm64.tar.gz

"$REPO/ci/package-hub.sh" "$PKG"

# /usr/local/sbin steht für normale Benutzer nicht im PATH, deshalb direkt prüfen.
if ! ssh "$PI" 'test -x /usr/local/sbin/carvos-update'; then
    echo "Auf dem Pi fehlt carvos-update, richte es ein ..."
    rsync -a --delete "$REPO/provisioning/" "$PI:/tmp/carvos-provisioning/"
    ssh -t "$PI" 'sudo /tmp/carvos-provisioning/setup-updater.sh && rm -rf /tmp/carvos-provisioning'
fi

scp -q "$PKG" "$PI:/tmp/carvos-dev.tar.gz"
ssh -t "$PI" 'sudo carvos-update install --unsigned /tmp/carvos-dev.tar.gz; rm -f /tmp/carvos-dev.tar.gz'
