pragma Singleton
import QtQuick

// Symbole als SVG-Pfade auf einem 24x24-Raster, Darstellung über Icon.qml.
QtObject {
    readonly property string home: "M3 11 L12 3 L21 11 M5 9.5 V21 H19 V9.5"
    readonly property string gas: "M9 3 H15 M12 3 V6 M8 9 A4 3 0 0 1 16 9 V20 A1 1 0 0 1 15 21 H9 A1 1 0 0 1 8 20 Z"
    readonly property string water: "M12 3 C12 3 5 10.5 5 15 A7 7 0 0 0 19 15 C19 10.5 12 3 12 3 Z"
    readonly property string system: "M4 7 H14 M18 7 H20 M16 5 V9 M4 17 H6 M10 17 H20 M8 15 V19"
    readonly property string wifi: "M3 9 A14 14 0 0 1 21 9 M6.5 13 A9 9 0 0 1 17.5 13 M10 16.5 A3.5 3.5 0 0 1 14 16.5 M12 20 L12 20.01"
    readonly property string check: "M5 12 L10 17 L19 7"
    readonly property string plus: "M12 5 V19 M5 12 H19"
    readonly property string update: "M20 6 V11 H15 M4 18 V13 H9 M19 11 A8 8 0 0 0 5.5 7.5 M5 13 A8 8 0 0 0 18.5 16.5"
    readonly property string camera: "M3 8 H7 L9 5 H15 L17 8 H21 V19 H3 Z M12 16 A3 3 0 1 0 12 10 A3 3 0 0 0 12 16 Z"
}
