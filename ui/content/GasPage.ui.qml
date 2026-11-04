import QtQuick
import QtQuick.Layouts
import Carvos

ColumnLayout {
    id: root

    spacing: Theme.spacing

    PageTitle {
        text: "Gas"
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: Theme.spacing

        Card {
            Layout.preferredWidth: 300
            Layout.fillHeight: true

            ColumnLayout {
                anchors.fill: parent
                spacing: 12

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "75 %"
                    color: Theme.text
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontDisplay
                    font.bold: true
                }

                // Flasche mit Füllstand
                Item {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.fillHeight: true
                    Layout.preferredWidth: 130

                    Rectangle {
                        id: bottleNeck
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 44
                        height: 16
                        radius: 4
                        color: Theme.track
                    }

                    Rectangle {
                        id: bottleBody
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: bottleNeck.bottom
                        anchors.topMargin: 4
                        anchors.bottom: parent.bottom
                        radius: 28
                        color: Theme.track

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            height: parent.height * 0.75
                            bottomLeftRadius: 28
                            bottomRightRadius: 28
                            color: Theme.textMuted
                        }
                    }
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "ca. 8,3 kg von 11 kg"
                    color: Theme.textMuted
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontBody
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Theme.spacing

            Card {
                Layout.fillWidth: true
                Layout.preferredHeight: 164

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0

                    InfoRow {
                        Layout.fillWidth: true
                        label: "Flasche"
                        value: "11 kg Propan"
                    }
                    InfoRow {
                        Layout.fillWidth: true
                        label: "Letzte Messung"
                        value: "vor 2 Minuten"
                    }
                    InfoRow {
                        Layout.fillWidth: true
                        label: "Waage"
                        value: "Online"
                    }
                }
            }

            Card {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 10

                    Text {
                        text: "Letzte 7 Tage"
                        color: Theme.textMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontBody
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 12

                        Repeater {
                            model: ListModel {
                                ListElement { day: "Mi"; level: 0.90 }
                                ListElement { day: "Do"; level: 0.87 }
                                ListElement { day: "Fr"; level: 0.85 }
                                ListElement { day: "Sa"; level: 0.83 }
                                ListElement { day: "So"; level: 0.80 }
                                ListElement { day: "Mo"; level: 0.78 }
                                ListElement { day: "Di"; level: 0.75 }
                            }

                            delegate: ColumnLayout {
                                id: barColumn

                                required property string day
                                required property real level
                                required property int index

                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                Layout.preferredWidth: 1
                                spacing: 4

                                Item {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true

                                    Rectangle {
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        anchors.bottom: parent.bottom
                                        height: parent.height * barColumn.level
                                        radius: 4
                                        color: barColumn.index === 6 ? Theme.accent : Theme.track
                                    }
                                }

                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: barColumn.day
                                    color: Theme.textMuted
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSmall
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
