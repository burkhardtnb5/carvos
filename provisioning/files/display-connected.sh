#!/bin/sh
# Erfolgreich (0), wenn an einem Anschluss ein Bildschirm steckt, sonst 1.
# Dient carvos-ui.service als ExecCondition: ohne Bildschirm startet die Oberfläche nicht.
for status in /sys/class/drm/card*-*/status; do
    case "$status" in *Writeback*) continue ;; esac
    [ "$(cat "$status" 2>/dev/null)" = connected ] && exit 0
done
exit 1
