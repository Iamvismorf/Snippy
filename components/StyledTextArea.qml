import QtQuick
import QtQuick.Controls
import qs.singletons

TextArea {
    id: root

    property bool _modified: false

    padding: 0
    leftPadding: padding
    verticalAlignment: TextEdit.AlignVCenter
    focusPolicy: Qt.ClickFocus
    hoverEnabled: false
    background: StyledRectangle {
        color: "transparent"
        implicitWidth: fm.charWidth
    }

    font {
        styleName: Config.fontFamilyStyle
        family: Config.fontFamily
    }

    FontMetrics {
        id: fm
        readonly property real charWidth: advanceWidth("W")
        font: root.font
    }
    Keys.onEscapePressed: {
        focus = false;
    }
    onTextEdited: {
        _modified = true;
    }
}
