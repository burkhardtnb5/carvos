import QtQuick
import QtQuick.Layouts
import Carvos

Rectangle {
    id: root

    property int currentPage: 0
    property bool valveOpen: false
    property alias navOverview: navOverview
    property alias navGas: navGas
    property alias navWater: navWater
    property alias navSystem: navSystem
    property alias waterPage: waterPage

    width: 1024
    height: 600
    color: Theme.background

    Rectangle {
        id: topBar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: Theme.topBarHeight
        color: Theme.surface

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Theme.margin
            anchors.rightMargin: Theme.margin
            spacing: 10

            Rectangle {
                width: 6
                height: 24
                color: Theme.accent
            }

            Text {
                text: "CARVOS"
                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontTitle
                font.bold: true
                font.letterSpacing: 2
            }

            Item {
                Layout.fillWidth: true
            }

            Icon {
                path: Icons.wifi
                color: Theme.textMuted
                size: 24
            }

            Text {
                text: "3 Geräte"
                color: Theme.textMuted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontBody
            }

            Text {
                Layout.leftMargin: Theme.spacing
                text: "14:32"
                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontBody
                font.bold: true
            }
        }
    }

    Rectangle {
        id: rail
        anchors.left: parent.left
        anchors.top: topBar.bottom
        anchors.bottom: parent.bottom
        width: Theme.railWidth
        color: Theme.surface

        Column {
            anchors.fill: parent

            NavButton {
                id: navOverview
                width: parent.width
                text: "Übersicht"
                iconPath: Icons.home
                checked: root.currentPage === 0
            }
            NavButton {
                id: navGas
                width: parent.width
                text: "Gas"
                iconPath: Icons.gas
                checked: root.currentPage === 1
            }
            NavButton {
                id: navWater
                width: parent.width
                text: "Grauwasser"
                iconPath: Icons.water
                checked: root.currentPage === 2
            }
            NavButton {
                id: navSystem
                width: parent.width
                text: "System"
                iconPath: Icons.system
                checked: root.currentPage === 3
            }
        }
    }

    StackLayout {
        anchors.left: rail.right
        anchors.right: parent.right
        anchors.top: topBar.bottom
        anchors.bottom: parent.bottom
        anchors.margins: Theme.margin
        currentIndex: root.currentPage

        OverviewPage {
            valveOpen: root.valveOpen
        }
        GasPage {
        }
        WaterPage {
            id: waterPage
            valveOpen: root.valveOpen
        }
        SystemPage {
        }
    }
}
