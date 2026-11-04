import QtQuick
import QtQuick.Controls.Basic

Switch {
    id: root

    implicitWidth: 76
    implicitHeight: Theme.touchMin
    padding: 0
    spacing: 0

    indicator: Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: root.width
        height: 40
        radius: height / 2
        color: root.checked ? Theme.accent : Theme.track

        Rectangle {
            x: root.checked ? parent.width - width - 4 : 4
            y: 4
            width: 32
            height: 32
            radius: height / 2
            color: "#FFFFFF"

            Behavior on x {
                NumberAnimation { duration: 120 }
            }
        }
    }

    contentItem: Item {
    }
}
