#!/bin/bash
# Baut, packt, signiert und veröffentlicht ein Release auf GitHub. Nur auf dem Dev-PC.
# Aufruf: ci/release.sh VERSION      (z. B. 0.1.0, ohne „v“)
# Braucht: podman, minisign, gh (angemeldet), den geheimen Schlüssel (Standard ~/.minisign/carvos.key)
set -euo pipefail

REPO=$(cd "$(dirname "$0")/.." && pwd)
VERSION=${1:?Aufruf: ci/release.sh VERSION}
KEY=${CARVOS_MINISIGN_KEY:-$HOME/.minisign/carvos.key}
KEY_DIR=$REPO/provisioning/files/minisign.d
OUT=$REPO/build/release/carvos-hub-arm64.tar.gz

[[ $VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || { echo "Version im Format 1.2.3" >&2; exit 1; }
cd "$REPO"
[ -z "$(git status --porcelain)" ] || { echo "Arbeitsstand nicht sauber" >&2; exit 1; }
[ "$(git branch --show-current)" = main ] || { echo "nicht auf main" >&2; exit 1; }
git fetch -q --tags origin
[ "$(git rev-parse HEAD)" = "$(git rev-parse origin/main)" ] || { echo "main ist nicht gepusht/aktuell" >&2; exit 1; }
! git rev-parse -q --verify "refs/tags/v$VERSION" >/dev/null || { echo "Tag v$VERSION gibt es schon" >&2; exit 1; }
[ -f "$KEY" ] || { echo "Schlüssel fehlt: $KEY" >&2; exit 1; }

ci/build-arm64.sh
ci/package-hub.sh "$OUT" "$VERSION"
rm -f "$OUT.minisig"
minisign -S -s "$KEY" -m "$OUT" -t "carvos-hub $VERSION"
# Kennen die Hubs diesen Schlüssel? Sonst würden sie das Release ablehnen.
SIGNER=""
for pub in "$KEY_DIR"/*.pub; do
    [ -f "$pub" ] && minisign -Vq -p "$pub" -m "$OUT" 2>/dev/null && { SIGNER=$(basename "$pub" .pub); break; }
done
[ -n "$SIGNER" ] || { echo "Dein Schlüssel fehlt in $KEY_DIR (erst einchecken und pushen)" >&2; exit 1; }
echo "signiert mit Schlüssel $SIGNER"

git tag -a "v$VERSION" -m "CARVOS $VERSION"
git push -q origin "v$VERSION"
gh release create "v$VERSION" "$OUT" "$OUT.minisig" --title "CARVOS $VERSION" --generate-notes
