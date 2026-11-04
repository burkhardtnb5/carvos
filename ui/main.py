#!/usr/bin/env python3
"""Startet die CARVOS-Oberfläche.

--dev lädt die Oberfläche neu, sobald eine QML-Datei gespeichert wird.
"""
import argparse
import os
import sys
from pathlib import Path

# Registriert QQuickWindow für PySide6, sonst fehlen dem Fenster Methoden.
from PySide6 import QtQuick  # noqa: F401
from PySide6.QtCore import QFileSystemWatcher, QTimer, QUrl
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtQuickControls2 import QQuickStyle

UI_DIR = Path(__file__).resolve().parent
APP_QML = UI_DIR / "content" / "App.qml"
WATCHED_DIRS = [UI_DIR / "content", UI_DIR / "imports" / "Carvos"]


def create_engine():
    engine = QQmlApplicationEngine()
    engine.addImportPath(str(UI_DIR / "imports"))
    engine.load(QUrl.fromLocalFile(str(APP_QML)))
    return engine


class LiveReloader:
    """Baut die Engine neu auf, wenn sich eine QML-Datei ändert."""

    def __init__(self):
        self.engine = create_engine()
        self.watcher = QFileSystemWatcher()
        self.watcher.directoryChanged.connect(self.schedule)
        self.watcher.fileChanged.connect(self.schedule)
        # Editoren speichern in mehreren Schritten, daher kurz abwarten.
        self.timer = QTimer(singleShot=True, interval=200)
        self.timer.timeout.connect(self.reload)
        self.watch()

    def watch(self):
        files = [str(path) for folder in WATCHED_DIRS for path in folder.glob("*.qml")]
        self.watcher.addPaths([str(folder) for folder in WATCHED_DIRS] + files)

    def schedule(self):
        self.timer.start()

    def reload(self):
        old_engine = self.engine
        for window in old_engine.rootObjects():
            window.close()
        old_engine.deleteLater()
        self.engine = create_engine()
        self.watch()
        print("Oberfläche neu geladen", flush=True)


def main():
    parser = argparse.ArgumentParser(description="CARVOS-Oberfläche")
    parser.add_argument("--dev", action="store_true", help="bei Änderungen automatisch neu laden")
    args, qt_args = parser.parse_known_args()

    # Das Display hat feste 1024x600 Pixel, Desktop-Skalierung würde das verfälschen.
    os.environ.setdefault("QT_ENABLE_HIGHDPI_SCALING", "0")
    QQuickStyle.setStyle("Basic")
    app = QGuiApplication([sys.argv[0], *qt_args])
    # Alle Fenster dürfen im --dev-Modus beim Neuladen kurz geschlossen sein.
    app.setQuitOnLastWindowClosed(not args.dev)

    if args.dev:
        reloader = LiveReloader()  # noqa: F841
    else:
        engine = create_engine()
        if not engine.rootObjects():
            return 1
    return app.exec()


if __name__ == "__main__":
    sys.exit(main())
