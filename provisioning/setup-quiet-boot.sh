#!/bin/bash
# Blendet Regenbogenbild, Raspberry-Logos und Bootmeldungen auf dem Display aus.
# Auf dem Pi als root ausführen, kann mehrfach laufen.
# Rückgängig: config.txt.orig und cmdline.txt.orig in /boot/firmware zurückkopieren.
set -euo pipefail

CONFIG=/boot/firmware/config.txt
CMDLINE=/boot/firmware/cmdline.txt

[ -f "$CONFIG.orig" ] || cp "$CONFIG" "$CONFIG.orig"
[ -f "$CMDLINE.orig" ] || cp "$CMDLINE" "$CMDLINE.orig"

# Firmware: kein Regenbogenbild. [all] sorgt dafür, dass es für jedes Modell gilt.
if ! grep -q '^disable_splash=1' "$CONFIG"; then
    printf '\n[all]\ndisable_splash=1\n' >> "$CONFIG"
fi

# Kernel: Die Datei besteht aus genau einer Zeile und muss das auch bleiben.
line=$(tr -d '\n' < "$CMDLINE")
line=${line/console=tty1/console=tty3}
for option in quiet loglevel=3 logo.nologo vt.global_cursor_default=0 \
    systemd.show_status=false rd.systemd.show_status=false udev.log_level=3; do
    case " $line " in
        *" $option "*) ;;
        *) line="$line $option" ;;
    esac
done
printf '%s\n' "$line" > "$CMDLINE"
