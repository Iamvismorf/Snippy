import QtQuick
import org.kde.kirigami.primitives as Kirigami

Item {
    id: root
    required property string sauce

    property int size
    property color fillColor

    implicitWidth: size
    implicitHeight: size

    Kirigami.Icon {
        source: root.sauce
        anchors.fill: parent
        color: root.fillColor
        isMask: true
    }

    Behavior on fillColor {
        ColorAnimation {
            duration: 250
        }
    }

    Behavior on opacity {
        InOutAnim {}
    }
}
