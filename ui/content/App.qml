import QtCore
import QtQuick
import QtQuick.Controls.Basic
import Carvos

// Enthält die Logik der Oberfläche. Das Aussehen steckt in den .ui.qml-Dateien.
ApplicationWindow {
    id: window

    property alias currentPage: shell.currentPage
    property alias darkMode: settings.darkMode

    width: 1024
    height: 600
    visible: true
    title: "CARVOS"
    color: Theme.background

    Settings {
        id: settings
        category: "ui"
        property bool darkMode: true
    }

    Binding {
        target: Theme
        property: "dark"
        value: settings.darkMode
    }

    Shell {
        id: shell
        anchors.fill: parent
    }

    Connections {
        target: shell.navOverview
        function onClicked() { shell.currentPage = 0 }
    }
    Connections {
        target: shell.navGas
        function onClicked() { shell.currentPage = 1 }
    }
    Connections {
        target: shell.navWater
        function onClicked() { shell.currentPage = 2 }
    }
    Connections {
        target: shell.navSystem
        function onClicked() { shell.currentPage = 3 }
    }
    Connections {
        target: shell.systemPage.darkModeSwitch
        function onToggled() { settings.darkMode = shell.systemPage.darkModeSwitch.checked }
    }
    Connections {
        target: shell.waterPage.openButton
        function onClicked() { shell.valveOpen = true }
    }
    Connections {
        target: shell.waterPage.closeButton
        function onClicked() { shell.valveOpen = false }
    }
}
