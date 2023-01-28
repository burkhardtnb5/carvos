/*
This is a UI file (.ui.qml) that is intended to be edited in Qt Design Studio only.
It is supposed to be strictly declarative and only uses a subset of QML. If you edit
this file manually, you might introduce QML code that is not supported by Qt Design Studio.
Check out https://doc.qt.io/qtcreator/creator-quick-ui-forms.html for details on .ui.qml files.
*/

import QtQuick 2.15
import QtQuick.Controls 2.15
import Carvos 1.0

Rectangle {
    id: rectangle
    width: Constants.width
    height: Constants.height

    color: Constants.backgroundColor

    SwipeView {
        id: swipeView
        x: 0
        y: 0
        width: 480
        height: 320

        Button {
            id: button1
            width: 480
            height: 320
            text: qsTr("")

            Image {
                id: image
                x: 158
                y: 0
                width: 165
                height: 320
                source: "../../resources/magnetventil.png"
                fillMode: Image.PreserveAspectFit
            }
        }

        Button {
            id: button2
            width: 480
            height: 320
            text: qsTr("")

            Image {
                id: image1
                x: 160
                y: 0
                width: 161
                height: 320
                source: "../../resources/wagenheber.png"
                fillMode: Image.PreserveAspectFit
            }
        }

        Button {
            id: button
            width: 480
            height: 320
            text: qsTr("")

            Image {
                id: image2
                x: 156
                y: 0
                width: 168
                height: 320
                source: "../../resources/propan.png"
                fillMode: Image.PreserveAspectFit
            }
        }
    }
    states: [
        State {
            name: "clicked"
            when: button.checked
        }
    ]
}
