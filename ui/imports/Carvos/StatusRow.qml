import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root

    property string name
    property bool online: true

    Layout.preferredHeight: 48
    spacing: 12

    Rectangle {
        width: 12
        height: 12
        radius: 6
        color: root.online ? Theme.success : Theme.track
    }

    Text {
        Layout.fillWidth: true
        text: root.name
        color: Theme.text
        elide: Text.ElideRight
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontBody
    }

    Text {
        text: root.online ? "Online" : "Offline"
        color: Theme.textMuted
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSmall
    }
}
