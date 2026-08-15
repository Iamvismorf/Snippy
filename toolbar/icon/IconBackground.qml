import QtQuick
import qs.components

StyledRectangle {
    property alias mouseArea: mouseArea
    property int innerPadding: 4

    radius: 4
    Behavior on color {
        ColorAnimation {
            duration: 275
        }
    }
    StyledMouseArea {
        id: mouseArea
        anchors.fill: parent
    }
}
