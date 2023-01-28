from PyQt5 import QtWidgets
from PyQt5.QtWidgets import QApplication, QMainWindow
import sys

def b1clicked():
    print("du stinkst")

def window():
    app = QApplication(sys.argv)
    win = QMainWindow()
    win.setGeometry(100, 100, 480, 320)
    win.setWindowTitle("carvos")

    b1 = QtWidgets.QPushButton(win)
    b1.setText("carvos")
    b1.clicked.connect(b1clicked)

    win.show()
    sys.exit(app.exec_())

window()

