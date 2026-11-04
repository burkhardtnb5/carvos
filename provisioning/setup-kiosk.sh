#!/bin/bash
# Richtet den Pi so ein, dass die CARVOS-Oberfläche beim Start im Vollbild erscheint.
# Auf dem Pi als root ausführen, kann mehrfach laufen.
set -euo pipefail

BASE=/opt/carvos

DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    python3-pyside6.qtcore python3-pyside6.qtgui python3-pyside6.qtqml \
    python3-pyside6.qtquick python3-pyside6.qtquickcontrols2 \
    qml6-module-qtquick qml6-module-qtquick-controls qml6-module-qtquick-layouts \
    qml6-module-qtquick-window qml6-module-qtquick-templates qml6-module-qtquick-shapes \
    qml6-module-qtqml-workerscript qml6-module-qtqml-models \
    qt6-qpa-plugins libegl-mesa0 libgl1-mesa-dri libgles2 libinput10

install -m 644 "$BASE/provisioning/files/carvos-ui.service" /etc/systemd/system/carvos-ui.service
systemctl daemon-reload
systemctl enable carvos-ui.service
systemctl restart carvos-ui.service
