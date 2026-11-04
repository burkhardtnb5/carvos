import QtQuick

Rectangle {
    id: root

    property real value: 0
    property color barColor: Theme.text

    implicitHeight: 16
    radius: height / 2
    color: Theme.track

    Rectangle {
        width: parent.width * Math.max(0, Math.min(1, root.value))
        height: parent.height
        radius: parent.radius
        color: root.barColor
    }
}
