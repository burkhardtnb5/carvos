pragma Singleton
import QtQuick

// Alle Farben, Größen und Schriften an einer Stelle.
QtObject {
    // Grautöne (Hauptfarbe)
    readonly property color background: "#17191C"
    readonly property color surface: "#25282C"
    readonly property color surfaceRaised: "#32363B"
    readonly property color border: "#3D4248"
    readonly property color track: "#464B52"
    readonly property color text: "#F1F3F5"
    readonly property color textMuted: "#A9AFB6"

    // Rot (Akzent): sparsam einsetzen, siehe docs/ARCHITEKTUR.md
    readonly property color accent: "#D92D32"
    readonly property color accentPressed: "#AE2227"
    readonly property color textOnAccent: "#FFFFFF"

    // Zustände
    readonly property color warning: "#F2A93B"
    readonly property color success: "#4FB286"

    // Maße für 1024x600 auf 10,1": 56 Pixel sind etwa 12 mm Touchfläche
    readonly property int touchMin: 56
    readonly property int spacing: 16
    readonly property int margin: 20
    readonly property int radius: 12
    readonly property int railWidth: 104
    readonly property int topBarHeight: 56

    // Schrift
    readonly property string fontFamily: fontRegular.name
    readonly property int fontSmall: 15
    readonly property int fontBody: 18
    readonly property int fontTitle: 22
    readonly property int fontHeadline: 30
    readonly property int fontDisplay: 72

    readonly property FontLoader fontRegular: FontLoader { source: "fonts/NotoSans-Regular.ttf" }
    readonly property FontLoader fontBold: FontLoader { source: "fonts/NotoSans-Bold.ttf" }
}
