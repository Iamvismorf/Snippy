qml_module(snippy-qml-plugin
   URI Snippy
   VERSION 1.0
   DEPENDENCIES QtQuick

   SOURCES
      Clipboard.cpp
      Notifier.cpp
)


target_link_libraries(snippy-qml-plugin PRIVATE
   Qt6::Core
   Qt6::DBus
   Qt6::Gui
   Qt6::Quick
)

