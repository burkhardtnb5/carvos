import QtQuick
import QtQuick.Layouts
import Carvos

ColumnLayout {
    id: root

    property alias addDeviceButton: addDeviceButton
    property alias serviceButton: serviceButton
    property alias darkModeSwitch: darkModeSwitch

    spacing: Theme.spacing

    PageTitle {
        text: "System"
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
                spacing: 4

                Text {
                    Layout.bottomMargin: 6
                    text: "Geräte"
                    color: Theme.textMuted
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontTitle
                }

                StatusRow {
                    Layout.fillWidth: true
                    name: "Gasflaschenwaage"
                }
                StatusRow {
                    Layout.fillWidth: true
                    name: "Grauwasserventil"
                }
                StatusRow {
                    Layout.fillWidth: true
                    name: "Kamera"
                }

                Item {
                    Layout.fillHeight: true
                }

                ActionButton {
                    id: addDeviceButton
                    Layout.fillWidth: true
                    text: "Gerät hinzufügen"
                    iconPath: Icons.plus
                    primary: true
                }
            }
        }

        Card {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: 1

            ColumnLayout {
                anchors.fill: parent
                spacing: 4

                Text {
                    Layout.bottomMargin: 6
                    text: "Hub"
                    color: Theme.textMuted
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontTitle
                }

                InfoRow {
                    Layout.fillWidth: true
                    label: "Netzwerk"
                    value: "CARVOS-3f9a1c2e"
                }
                InfoRow {
                    Layout.fillWidth: true
                    label: "Kanal"
                    value: "6"
                }
                InfoRow {
                    Layout.fillWidth: true
                    label: "Version"
                    value: "0.1.0"
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacing

                    Text {
                        Layout.fillWidth: true
                        text: "Dunkler Modus"
                        color: Theme.textMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontBody
                    }

                    ToggleSwitch {
                        id: darkModeSwitch
                        checked: Theme.dark
                    }
                }

                Item {
                    Layout.fillHeight: true
                }

                ActionButton {
                    id: serviceButton
                    Layout.fillWidth: true
                    text: "Service-Modus"
                    iconPath: Icons.update
                }
            }
        }
    }
}
