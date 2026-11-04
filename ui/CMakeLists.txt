set(QT_QML_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/qml)

add_subdirectory(imports/Carvos)

qt_add_executable(carvos-ui src/main.cpp)

# QML und Schriften werden einkompiliert, der Pi braucht nur die Binärdatei.
set(CARVOS_CONTENT_FILES
    content/App.qml
    content/Shell.ui.qml
    content/OverviewPage.ui.qml
    content/GasPage.ui.qml
    content/WaterPage.ui.qml
    content/SystemPage.ui.qml
)
foreach(file ${CARVOS_CONTENT_FILES})
    get_filename_component(name ${file} NAME)
    set_source_files_properties(${file} PROPERTIES QT_RESOURCE_ALIAS ${name})
endforeach()

qt_add_qml_module(carvos-ui
    URI CarvosApp
    VERSION 1.0
    QML_FILES ${CARVOS_CONTENT_FILES}
    DEPENDENCIES Carvos
    # Eigene Module sind fest verlinkt, Qt-Plugins lädt Qt zur Laufzeit.
    NO_IMPORT_SCAN
)

target_link_libraries(carvos-ui PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
    carvos_componentsplugin
)
