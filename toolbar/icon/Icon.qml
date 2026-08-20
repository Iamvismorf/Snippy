import QtQuick

import qs.components
import qs.singletons

IconBackground {
    property alias source: kirigamiIcon.source
    property alias size: kirigamiIcon.size
    property alias iconColor: kirigamiIcon.color

    property alias icon: kirigamiIcon

    implicitWidth: kirigamiIcon.implicitWidth + innerPadding * 2
    implicitHeight: kirigamiIcon.implicitHeight + innerPadding * 2

    KirigamiIcon {
        id: kirigamiIcon
        readonly property color _defaultColor: Config.black

        anchors.centerIn: parent
        size: Config.toolbarIconSize
        color: _defaultColor

        Behavior on color {
            ColorAnimation {
                duration: 275
            }
        }
    }
}
