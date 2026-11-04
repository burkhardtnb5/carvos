import QtQuick
import QtQuick.Controls.Basic

AbstractButton {
    id: root

    property string iconPath

    implicitWidth: Theme.railWidth
    implicitHeight: 92

    background: Rectangle {
        color: root.pressed || root.checked ? Theme.surfaceRaised : "transparent"

        Rectangle {
            width: 4
            height: parent.height
            color: Theme.accent
            visible: root.checked
        }
    }

    contentItem: Column {
        spacing: 6
        topPadding: 16

        Icon {
            anchors.horizontalCenter: parent.horizontalCenter
            path: root.iconPath
            color: root.checked ? Theme.text : Theme.textMuted
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.text
            color: root.checked ? Theme.text : Theme.textMuted
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSmall
        }
    }
}
