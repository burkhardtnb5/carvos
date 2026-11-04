import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root

    property string label
    property string value

    Layout.preferredHeight: 41
    spacing: Theme.spacing

    Text {
        Layout.fillWidth: true
        text: root.label
        color: Theme.textMuted
        elide: Text.ElideRight
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontBody
    }

    Text {
        text: root.value
        color: Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontBody
    }
}
