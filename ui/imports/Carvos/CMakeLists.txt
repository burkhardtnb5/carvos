qt_add_library(carvos_components STATIC)

set_source_files_properties(Theme.qml Icons.qml PROPERTIES QT_QML_SINGLETON_TYPE TRUE)

qt_add_qml_module(carvos_components
    URI Carvos
    VERSION 1.0
    QML_FILES
        ActionButton.qml
        Card.qml
        Icon.qml
        Icons.qml
        InfoRow.qml
        LevelBar.qml
        NavButton.qml
        PageTitle.qml
        StatusRow.qml
        Theme.qml
        ToggleSwitch.qml
    RESOURCES
        fonts/NotoSans-Regular.ttf
        fonts/NotoSans-Bold.ttf
)
