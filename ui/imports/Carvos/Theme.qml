pragma Singleton
import QtQuick

// Alle Farben, Größen und Schriften an einer Stelle.
QtObject {
    // Wird von App.qml aus den gespeicherten Einstellungen gesetzt.
    property bool dark: true

    // Grautöne (Hauptfarbe)
    readonly property color background: dark ? "#17191C" : "#D5D8DC"
    readonly property color surface: dark ? "#25282C" : "#F1F2F4"
    readonly property color surfaceRaised: dark ? "#32363B" : "#E1E3E6"
    readonly property color border: dark ? "#3D4248" : "#BFC3C8"
    readonly property color track: dark ? "#464B52" : "#C2C6CB"
    readonly property color text: dark ? "#F1F3F5" : "#1B1D20"
    readonly property color textMuted: dark ? "#A9AFB6" : "#555B62"

    // Rot (Akzent): sparsam einsetzen, siehe docs/ARCHITEKTUR.md
    readonly property color accent: dark ? "#D92D32" : "#C4252A"
    readonly property color accentPressed: dark ? "#AE2227" : "#9C1C20"
    readonly property color textOnAccent: "#FFFFFF"

    // Zustände
    readonly property color warning: dark ? "#F2A93B" : "#9A5B00"
    readonly property color success: dark ? "#4FB286" : "#1B7A50"

    // Maße für 1024x600 auf 10,1": 56 Pixel sind etwa 12 mm Touchfläche
    readonly property int touchMin: 56
    readonly property int spacing: 16
    readonly property int margin: 20
    readonly property int radius: 12
    readonly property int railWidth: 104
    readonly property int topBarHeight: 56

    // Schrift
    readonly property string fontFamily: fontRegular.name
    // Für Systemausgaben (Entwicklermodus). Auf dem Pi: DejaVu Sans Mono.
    readonly property string fontMono: "monospace"
    readonly property int fontSmall: 15
    readonly property int fontBody: 18
    readonly property int fontTitle: 22
    readonly property int fontHeadline: 30
    readonly property int fontDisplay: 72

    readonly property FontLoader fontRegular: FontLoader { source: "fonts/NotoSans-Regular.ttf" }
    readonly property FontLoader fontBold: FontLoader { source: "fonts/NotoSans-Bold.ttf" }
}
