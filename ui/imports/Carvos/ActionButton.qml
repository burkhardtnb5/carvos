import QtQuick
import QtQuick.Controls.Basic

AbstractButton {
    id: root

    property string iconPath
    property bool primary: false

    implicitWidth: 200
    implicitHeight: 64
    opacity: enabled ? 1 : 0.4

    background: Rectangle {
        radius: Theme.radius
        color: root.primary
               ? (root.pressed ? Theme.accentPressed : Theme.accent)
               : (root.pressed ? Theme.border : Theme.surfaceRaised)
    }

    contentItem: Item {
        Row {
            anchors.centerIn: parent
            spacing: 10

            Icon {
                anchors.verticalCenter: parent.verticalCenter
                path: root.iconPath
                visible: root.iconPath !== ""
                color: root.primary ? Theme.textOnAccent : Theme.text
                size: 24
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.text
                color: root.primary ? Theme.textOnAccent : Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontBody
                font.bold: true
            }
        }
    }
}
