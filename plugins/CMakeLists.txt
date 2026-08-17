cmake_minimum_required(VERSION 3.16)
project(snippy-qml-plugin LANGUAGES CXX)

find_package(Qt6 REQUIRED COMPONENTS
   Core
   DBus
   Qml
   Quick
   Svg
)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED on)
set(CMAKE_AUTOMOC ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS on)


set(QT_QML_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/qml")
set(INSTALL_QMLDIR "lib/qt-6/qml" CACHE STRING "QML install dir")

include(cmake/qml-module.cmake)
add_subdirectory(src)

