import QtQuick
import QtQuick.Controls
import qs.components
import qs.singletons

StyledRectangle {
    property alias mouseArea: mouseArea
    property int innerPadding: 4
    property alias toolTip: toolTip

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

    ToolTip {
        id: toolTip
        delay: 550
        visible: mouseArea.containsMouse && text != ""
        enter: Transition {
            InOutAnim {
                property: "opacity"
                from: 0.0
                to: 1.0
            }
        }
        exit: Transition {
            InOutAnim {
                property: "opacity"
                from: 1.0
                to: 0.0
            }
        }
        contentItem: StyledText {
            text: toolTip.text
            textFormat: Text.RichText
        }
        background: StyledRectangle {
            radius: 8
            color: Config.white
            border {
                width: 1
                color: Config.gray
            }
        }
    }
}
