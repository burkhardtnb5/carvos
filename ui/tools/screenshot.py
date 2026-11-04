#!/usr/bin/env python3
"""Speichert ein Bild jeder Seite der Oberfläche, ohne ein Fenster zu öffnen.

Aufruf: tools/screenshot.py ZIELORDNER [BREITExHÖHE]
"""
import os
import sys
from pathlib import Path

os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")
os.environ.setdefault("QT_ENABLE_HIGHDPI_SCALING", "0")

from PySide6 import QtQuick  # noqa: E402,F401
from PySide6.QtCore import QTimer, QUrl  # noqa: E402
from PySide6.QtGui import QGuiApplication  # noqa: E402
from PySide6.QtQml import QQmlApplicationEngine  # noqa: E402
from PySide6.QtQuickControls2 import QQuickStyle  # noqa: E402

UI_DIR = Path(__file__).resolve().parents[1]
PAGES = ["uebersicht", "gas", "grauwasser", "system"]


def main():
    target = Path(sys.argv[1])
    target.mkdir(parents=True, exist_ok=True)
    width, height = map(int, (sys.argv[2] if len(sys.argv) > 2 else "1024x600").split("x"))

    QQuickStyle.setStyle("Basic")
    app = QGuiApplication(sys.argv[:1])
    engine = QQmlApplicationEngine()
    engine.addImportPath(str(UI_DIR / "imports"))
    engine.load(QUrl.fromLocalFile(str(UI_DIR / "content" / "App.qml")))
    if not engine.rootObjects():
        return 1
    window = engine.rootObjects()[0]
    window.setWidth(width)
    window.setHeight(height)

    pages = iter(enumerate(PAGES))

    def next_page():
        step = next(pages, None)
        if step is None:
            app.quit()
            return
        window.setProperty("currentPage", step[0])
        QTimer.singleShot(400, lambda: save(step[1]))

    def save(name):
        window.grabWindow().save(str(target / f"{name}-{width}x{height}.png"))
        next_page()

    QTimer.singleShot(400, next_page)
    return app.exec()


if __name__ == "__main__":
    sys.exit(main())
