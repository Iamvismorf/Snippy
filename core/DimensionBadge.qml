import QtQuick
import qs.components
import qs.singletons

StyledText {
    id: dimensionText
    required property Rectangle selectionRectangle

    opacity: selectionRectangle.active && selectionRectangle.implicitWidth > 0 && selectionRectangle.implicitHeight > 0
    visible: opacity

    font.pointSize: 12
    color: Config.white

    text: Math.round(selectionRectangle.width) + " × " + Math.round(selectionRectangle.height)
    Behavior on opacity {
        InOutAnim {}
    }
}
