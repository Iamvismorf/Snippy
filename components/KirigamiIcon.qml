import QtQuick
import org.kde.kirigami.primitives as Kirigami

Item {
    id: root
    property string source

    property int size
    property color color

    implicitWidth: size
    implicitHeight: size

    Kirigami.Icon {
        id: kirigamiIcon
        source: root.source
        anchors.fill: parent
        color: root.color
        isMask: true
    }

    Behavior on color {
        ColorAnimation {
            duration: 250
        }
    }

    Behavior on opacity {
        InOutAnim {}
    }
}
