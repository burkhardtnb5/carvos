#!/bin/bash
# Richtet die Updates aus GitHub-Releases ein (docs/ARCHITEKTUR.md, „Updates des Hubs“).
# Auf dem Pi als root ausführen, kann mehrfach laufen. Läuft aus dem Ordner provisioning/ heraus.
#
# Danach gilt: /opt/carvos -> /data/current -> /data/releases/<version>
# Ein bestehendes /opt/carvos (alte Einrichtung per deploy-ui.sh) wird als Version 0.0.0~lokal übernommen.
set -euo pipefail

FILES=$(cd "$(dirname "$0")" && pwd)/files
DATA=/data

DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends minisign curl jq ca-certificates

install -d -m 755 /etc/carvos "$DATA" "$DATA/releases" "$DATA/state"
install -m 644 "$FILES/update.conf" /etc/carvos/update.conf
install -d -m 755 /etc/carvos/minisign.d
if compgen -G "$FILES/minisign.d/*.pub" >/dev/null; then
    install -m 644 "$FILES"/minisign.d/*.pub /etc/carvos/minisign.d/
else
    echo "Warnung: keine Schlüssel in $FILES/minisign.d – signierte Updates gehen erst, wenn einer da ist." >&2
fi
rm -f /etc/carvos/minisign.pub   # alter Ort (nur ein Schlüssel)
install -m 755 "$FILES/carvos-update" /usr/local/sbin/carvos-update
install -m 644 "$FILES/carvos-update.service" "$FILES/carvos-update-boot.service" /etc/systemd/system/

# Bisherige Einrichtung als erste Version übernehmen.
if [ -d /opt/carvos ] && [ ! -L /opt/carvos ]; then
    VER=0.0.0~lokal
    rm -rf "${DATA:?}/releases/$VER"
    mv -T /opt/carvos "$DATA/releases/$VER"
    echo "$VER" > "$DATA/releases/$VER/VERSION"
    chown -R root:root "$DATA/releases/$VER"
    ln -sfn "releases/$VER" "$DATA/current"
    for f in /etc/systemd/system/carvos-*.service /etc/udev/rules.d/99-carvos-*.rules; do
        [ -e "$f" ] && echo "$f"
    done | grep -v carvos-update > "$DATA/state/installed-files" || true
fi
ln -sfn "$DATA/current" /opt/carvos

systemctl daemon-reload
systemctl enable carvos-update-boot.service
