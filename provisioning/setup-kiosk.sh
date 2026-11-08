#!/bin/bash
# Richtet den Pi so ein, dass die CARVOS-Oberfläche beim Start im Vollbild erscheint.
# Auf dem Pi als root ausführen, kann mehrfach laufen.
set -euo pipefail

BASE=/opt/carvos

DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    libqt6core6t64 libqt6gui6 libqt6qml6 libqt6quick6 libqt6quickcontrols2-6 \
    qml6-module-qtquick qml6-module-qtquick-controls qml6-module-qtquick-layouts \
    qml6-module-qtquick-window qml6-module-qtquick-templates qml6-module-qtquick-shapes \
    qml6-module-qtqml-workerscript qml6-module-qtqml-models qml6-module-qtcore \
    qt6-qpa-plugins libegl-mesa0 libgl1-mesa-dri libgles2 libinput10

# Die Oberfläche war anfangs in Python geschrieben.
DEBIAN_FRONTEND=noninteractive apt-get purge -y --autoremove 'python3-pyside6*'

install -m 644 "$BASE/provisioning/files/carvos-ui.service" /etc/systemd/system/carvos-ui.service
install -m 644 "$BASE/provisioning/files/99-carvos-display.rules" /etc/udev/rules.d/99-carvos-display.rules
udevadm control --reload
systemctl daemon-reload
systemctl enable carvos-ui.service
# Startet nur, wenn ein Bildschirm angeschlossen ist (ExecCondition).
systemctl restart carvos-ui.service
