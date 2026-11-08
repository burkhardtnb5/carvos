import QtQuick
import QtQuick.Layouts
import Carvos

// Vollbild während des Service-Modus. Im Entwicklermodus mit der Ausgabe des Systems.
Rectangle {
    id: root

    property string message: "Suche nach Updates (über eth0)"
    property bool busy: true
    property bool failed: false
    property bool showLog: false
    property string log: "== Service-Modus gestartet\n== Prüfe die Internetverbindung\nInternet über eth0\ncarvos-update: frage neuestes Release von burkhardtnb5/carvos ab"
    property alias closeButton: closeButton

    width: 1024
    height: 600
    color: Theme.background

    // Fängt Berührungen ab, damit nichts darunter bedient wird.
    MouseArea {
        anchors.fill: parent
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.margin
        spacing: Theme.spacing

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.topBarHeight - Theme.margin
            spacing: 10

            Rectangle {
                width: 6
                height: 24
                color: Theme.accent
            }

            Text {
                text: "Service-Modus"
                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontTitle
                font.bold: true
                font.letterSpacing: 2
            }
        }

        Card {
            Layout.fillWidth: true
            Layout.preferredHeight: 112

            RowLayout {
                anchors.fill: parent
                spacing: Theme.margin

                Item {
                    Layout.preferredWidth: 48
                    Layout.preferredHeight: 48

                    Icon {
                        anchors.centerIn: parent
                        visible: root.busy
                        path: Icons.update
                        color: Theme.text
                        size: 44

                        RotationAnimation on rotation {
                            running: root.busy
                            from: 0
                            to: 360
                            duration: 1600
                            loops: Animation.Infinite
                        }
                    }

                    Icon {
                        anchors.centerIn: parent
                        visible: !root.busy
                        path: root.failed ? Icons.warning : Icons.check
                        color: root.failed ? Theme.warning : Theme.success
                        size: 44
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: root.message
                    color: Theme.text
                    wrapMode: Text.WordWrap
                    maximumLineCount: 3
                    elide: Text.ElideRight
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontTitle
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: root.showLog
            color: Theme.surface
            radius: Theme.radius
            border.color: Theme.border
            border.width: 1

            Flickable {
                id: logView
                anchors.fill: parent
                anchors.margins: 12
                clip: true
                contentWidth: width
                contentHeight: logText.height
                // Folgt der neuesten Zeile, bis man selbst scrollt.
                contentY: Math.max(0, contentHeight - height)

                Text {
                    id: logText
                    width: logView.width
                    text: root.log
                    color: Theme.text
                    wrapMode: Text.WrapAnywhere
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fontSmall
                }
            }
        }

        Item {
            Layout.fillHeight: true
            visible: !root.showLog
        }

        ActionButton {
            id: closeButton
            Layout.alignment: Qt.AlignRight
            Layout.preferredWidth: 240
            visible: !root.busy
            text: "Schließen"
            primary: true
        }
    }
}
