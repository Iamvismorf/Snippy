
qt_add_qml_module(svgicon
   URI Snippy
   VERSION 1.0
   DEPENDENCIES QtQuick
   SOURCES
   SvgIcon.cpp
)


target_link_libraries(svgicon PRIVATE
   Qt6::Core
   Qt6::Qml
   Qt6::Quick
   Qt6::Svg
)

