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
        // Lange Werte (z. B. Entwicklerversionen) in der Mitte kürzen.
        // Feste Grenze: eine Bindung an die Breite der Zeile bringt das Layout ins Schleudern.
        Layout.maximumWidth: 280
        text: root.value
        elide: Text.ElideMiddle
        color: Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontBody
    }
}
