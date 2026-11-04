#!/bin/bash
# Baut CARVOS im Container für den Pi. Ergebnis: build/arm64/ui/carvos-ui
set -euo pipefail

REPO=$(cd "$(dirname "$0")/.." && pwd)
IMAGE=carvos-build-arm64

podman build -q -t "$IMAGE" -f "$REPO/ci/arm64.Containerfile" "$REPO/ci"
podman run --rm --userns=keep-id -v "$REPO:/src:Z" -w /src "$IMAGE" bash -c '
    cmake -S . -B build/arm64 -G Ninja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_TOOLCHAIN_FILE=ci/toolchain-arm64.cmake
    cmake --build build/arm64
'
