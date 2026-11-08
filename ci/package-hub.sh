#!/bin/bash
# Packt alles für den Hub zu einem Paket: VERSION, bin/, provisioning/
# Aufruf: ci/package-hub.sh AUSGABE.tar.gz [VERSION]
# Ohne VERSION entsteht ein Entwicklungsstand, z. B. 0.1.0+dev.20261108153000.2e4eddd
# Vorher bauen: ci/build-arm64.sh
set -euo pipefail

REPO=$(cd "$(dirname "$0")/.." && pwd)
OUT=$(realpath -m "$1")
VERSION=${2:-}
BINARY=${CARVOS_UI_BINARY:-$REPO/build/arm64/ui/carvos-ui}

if [ -z "$VERSION" ]; then
    BASE=$(git -C "$REPO" describe --tags --abbrev=0 --match 'v*' 2>/dev/null || echo v0.0.0)
    VERSION=${BASE#v}+dev.$(date -u +%Y%m%d%H%M%S).$(git -C "$REPO" rev-parse --short HEAD)
fi

[ -f "$BINARY" ] || { echo "Binärdatei fehlt: $BINARY (ci/build-arm64.sh)" >&2; exit 1; }
# ELF-Maschinentyp 0xb7 = aarch64: verhindert, dass der PC-Build ins Paket gerät.
[ "$(od -An -tx1 -j18 -N2 "$BINARY" | tr -d ' \n')" = b700 ] \
    || { echo "$BINARY ist keine arm64-Binärdatei" >&2; exit 1; }

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
install -D -m 755 "$BINARY" "$STAGE/bin/carvos-ui"
cp -a "$REPO/provisioning" "$STAGE/provisioning"
echo "$VERSION" > "$STAGE/VERSION"

mkdir -p "$(dirname "$OUT")"
tar --sort=name --owner=0 --group=0 --numeric-owner -czf "$OUT" -C "$STAGE" .
echo "$OUT ($VERSION)"
