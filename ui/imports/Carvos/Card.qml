import QtQuick

Rectangle {
    id: root

    default property alias content: body.data

    color: Theme.surface
    radius: Theme.radius
    border.color: Theme.border
    border.width: 1

    Item {
        id: body
        anchors.fill: parent
        anchors.margins: Theme.margin
    }
}
