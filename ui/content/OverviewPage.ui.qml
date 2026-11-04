import QtQuick
import QtQuick.Layouts
import Carvos

ColumnLayout {
    id: root

    property bool valveOpen: false

    spacing: Theme.spacing

    PageTitle {
        text: "Übersicht"
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: Theme.spacing

        Card {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: 1

            ColumnLayout {
                anchors.fill: parent
                spacing: 10

                RowLayout {
                    spacing: 10

                    Icon {
                        path: Icons.gas
                        color: Theme.textMuted
                    }

                    Text {
                        text: "Gasflasche"
                        color: Theme.textMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontTitle
                    }
                }

                Item {
                    Layout.fillHeight: true
                }

                Text {
                    text: "75 %"
                    color: Theme.text
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontDisplay
                    font.bold: true
                }

                LevelBar {
                    Layout.fillWidth: true
                    value: 0.75
                }

                Text {
                    text: "ca. 8,3 kg von 11 kg"
                    color: Theme.textMuted
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontBody
                }
            }
        }

        Card {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: 1

            ColumnLayout {
                anchors.fill: parent
                spacing: 10

                RowLayout {
                    spacing: 10

                    Icon {
                        path: Icons.water
                        color: Theme.textMuted
                    }

                    Text {
                        text: "Grauwasserventil"
                        color: Theme.textMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontTitle
                    }
                }

                Item {
                    Layout.fillHeight: true
                }

                Text {
                    text: root.valveOpen ? "Geöffnet" : "Geschlossen"
                    color: root.valveOpen ? Theme.warning : Theme.text
                    font.family: Theme.fontFamily
                    font.pixelSize: 48
                    font.bold: true
                }

                Text {
                    text: "Bedienung unter „Grauwasser“"
                    color: Theme.textMuted
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontBody
                }
            }
        }
    }

    Card {
        Layout.fillWidth: true
        Layout.preferredHeight: 76

        RowLayout {
            anchors.fill: parent
            spacing: 12

            Icon {
                path: Icons.check
                color: Theme.success
            }

            Text {
                Layout.fillWidth: true
                text: "Keine Warnungen"
                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontBody
            }

            Text {
                text: "Alle Geräte online"
                color: Theme.textMuted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontBody
            }
        }
    }
}
