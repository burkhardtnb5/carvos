# Baut CARVOS für den Raspberry Pi (arm64). Debian Trixie ist die Basis von Raspberry Pi OS,
# damit passen Qt-Version und Bibliotheken zum Pi.
FROM docker.io/library/debian:trixie-slim

RUN dpkg --add-architecture arm64 \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        crossbuild-essential-arm64 cmake ninja-build pkgconf \
        qt6-base-dev qt6-base-dev-tools qt6-declarative-dev qt6-declarative-dev-tools \
        qt6-base-dev:arm64 qt6-declarative-dev:arm64 \
    && rm -rf /var/lib/apt/lists/*
