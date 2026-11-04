cmake_minimum_required(VERSION 3.22)
project(carvos VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Der Pi hat Qt 6.8, deshalb darf nichts Neueres vorausgesetzt werden.
find_package(Qt6 6.8 REQUIRED COMPONENTS Core Gui Qml Quick QuickControls2)
qt_standard_project_setup(REQUIRES 6.8)

add_subdirectory(ui)
