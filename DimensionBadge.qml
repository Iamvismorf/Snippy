import QtQuick
import qs.components

StyledText {
    id: dimensionText
    required property Rectangle selectionRectangle

    opacity: selectionRectangle.active && selectionRectangle.implicitWidth > 0 && selectionRectangle.implicitHeight > 0
    visible: opacity

    font.pixelSize: 17
    color: Config.white

    text: Math.round(selectionRectangle.width) + " × " + Math.round(selectionRectangle.height)
    Behavior on opacity {
        InOutAnim {}
    }
}
