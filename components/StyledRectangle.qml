import QtQuick

Rectangle {
    id: root

    property bool animatedSize: false
    property bool animatedColor: false

    border.width: 0

    Behavior on color {
        enabled: animatedColor
        ColorAnimation {
            duration: 250
        }
    }
    Behavior on border.color {
        enabled: animatedColor
        ColorAnimation {
            duration: 250
        }
    }
    Behavior on width {
        enabled: animatedSize
        DeccelAnim {}
    }
    Behavior on height {
        enabled: animatedSize
        DeccelAnim {}
    }
    Behavior on implicitWidth {
        enabled: animatedSize
        DeccelAnim {}
    }
    Behavior on implicitHeight {
        enabled: animatedSize
        DeccelAnim {}
    }
}
