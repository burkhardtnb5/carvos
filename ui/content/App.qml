import QtCore
import QtQuick
import QtQuick.Controls.Basic
import Carvos

// Enthält die Logik der Oberfläche. Das Aussehen steckt in den .ui.qml-Dateien.
ApplicationWindow {
    id: window

    property alias currentPage: shell.currentPage
    property alias darkMode: settings.darkMode
    // Kommt aus main.cpp (C++). Fehlt im Screenshot-Werkzeug und in Design Studio.
    property QtObject serviceMode: null
    // Das Ergebnis bleibt stehen, bis man es schließt.
    property bool serviceDismissed: true
    readonly property bool serviceVisible: serviceMode !== null && (serviceMode.active || !serviceDismissed)

    width: 1024
    height: 600
    visible: true
    title: "CARVOS"
    color: Theme.background

    Settings {
        id: settings
        category: "ui"
        property bool darkMode: true
        property bool developerMode: false
    }

    Binding {
        target: Theme
        property: "dark"
        value: settings.darkMode
    }

    Binding {
        target: shell.systemPage
        property: "developerMode"
        value: settings.developerMode
    }
    Binding {
        target: shell.systemPage
        property: "version"
        value: window.serviceMode !== null ? window.serviceMode.version : "–"
    }
    // Systemausgabe nur lesen, wenn sie angezeigt wird.
    Binding {
        when: window.serviceMode !== null
        target: window.serviceMode
        property: "logEnabled"
        value: settings.developerMode && window.serviceVisible
    }

    Shell {
        id: shell
        anchors.fill: parent
    }

    ServiceOverlay {
        id: serviceOverlay
        anchors.fill: parent
        visible: window.serviceVisible
        busy: window.serviceMode !== null && window.serviceMode.active
        failed: window.serviceMode !== null && window.serviceMode.phase === "fehler"
        message: window.serviceMode !== null ? window.serviceMode.message : ""
        showLog: settings.developerMode
        log: window.serviceMode !== null ? window.serviceMode.log : ""
    }

    // Startet die Oberfläche mitten im Service-Modus neu (das Update tauscht sie aus),
    // soll das Ergebnis danach trotzdem sichtbar bleiben.
    Component.onCompleted: {
        if (serviceMode !== null && serviceMode.active)
            serviceDismissed = false
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
        target: shell.systemPage.developerModeSwitch
        function onToggled() { settings.developerMode = shell.systemPage.developerModeSwitch.checked }
    }
    Connections {
        target: shell.systemPage.serviceButton
        function onClicked() {
            if (window.serviceMode === null)
                return
            window.serviceDismissed = false
            window.serviceMode.start()
        }
    }
    Connections {
        target: serviceOverlay.closeButton
        function onClicked() { window.serviceDismissed = true }
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
