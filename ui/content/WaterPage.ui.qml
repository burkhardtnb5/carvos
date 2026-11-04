import QtQuick
import QtQuick.Layouts
import Carvos

ColumnLayout {
    id: root

    property bool valveOpen: false
    property alias openButton: openButton
    property alias closeButton: closeButton

    spacing: Theme.spacing

    PageTitle {
        text: "Grauwasser"
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: Theme.spacing

        Card {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Rectangle {
                anchors.fill: parent
                radius: 8
                color: Theme.background

                Column {
                    anchors.centerIn: parent
                    spacing: 10

                    Icon {
                        anchors.horizontalCenter: parent.horizontalCenter
                        path: Icons.camera
                        color: Theme.textMuted
                        size: 48
                    }

                    Text {
                        text: "Kamerabild erscheint hier"
                        color: Theme.textMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontBody
                    }
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: false
            Layout.preferredWidth: 260
            Layout.fillHeight: true
            spacing: Theme.spacing

            Card {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 6

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Ventil"
                        color: Theme.textMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontBody
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: root.valveOpen ? "Geöffnet" : "Geschlossen"
                        color: root.valveOpen ? Theme.warning : Theme.text
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontHeadline
                        font.bold: true
                    }
                }
            }

            ActionButton {
                id: openButton
                Layout.fillWidth: true
                Layout.preferredHeight: 80
                text: "Öffnen"
                primary: true
                enabled: !root.valveOpen
            }

            ActionButton {
                id: closeButton
                Layout.fillWidth: true
                Layout.preferredHeight: 80
                text: "Schließen"
                enabled: root.valveOpen
            }
        }
    }
}
