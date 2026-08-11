qt_add_qml_module(clipboard
   URI Snippy
   VERSION 1.0
   DEPENDENCIES QtQuick
   SOURCES
   Clipboard.cpp
   Notifier.cpp
)


target_link_libraries(clipboard PRIVATE
   Qt6::Core
   Qt6::DBus
   Qt6::Gui
   Qt6::Quick
)

