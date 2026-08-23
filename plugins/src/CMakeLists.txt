qml_module(snippy-qml-plugin
   URI Snippy
   VERSION 1.0
   DEPENDENCIES QtQuick

   SOURCES
      Clipboard.hpp
      Clipboard.cpp

      Notifier.hpp
      Notifier.cpp

      Filesystem.hpp
      Filesystem.cpp
)


target_link_libraries(snippy-qml-plugin PRIVATE
   Qt6::Core
   Qt6::DBus
   Qt6::Gui
   Qt6::Quick
)

