import QtQuick
import QtQuick.Layouts
import QtQuick.Controls 2.15
import Quickshell
import qs.components
import qs.lib
import "../"

SpinBox {
    id: spinbox
    readonly property real _fontSize: 12

    implicitWidth: fm.charWidth * Math.max(from.toString().length, to.toString().length)

    editable: true
    live: true
    wrap: true
    locale: Qt.locale("C")
    padding: 8
    valueFromText: function (t, _) {
        let parsed = parseInt(t);
        return isNaN(parsed) ? value : parsed;
    }
    Keys.onEscapePressed: spinbox.focus = false
    font {
        styleName: Config.fontFamilyStyle
        family: Config.fontFamily
        pointSize: spinbox._fontSize
    }

    contentItem: TextInput {
        text: spinbox.textFromValue(spinbox.value, spinbox.locale)

        font: spinbox.font
        color: Config.black
        selectionColor: Config.accent
        selectedTextColor: Lib.isDark(selectionColor) ? Config.white : Config.black
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter

        readOnly: !spinbox.editable
        validator: spinbox.validator
        // anchors.fill: parent
    }
    up.onPressedChanged: {
        if (up.pressed) {
            increase();
        }
    }
    background: Rectangle {
        color: Config.white
    }

    // function increase() {
    //     if (value + stepSize > to) {
    //         value = wrap ? from : to;
    //         valueModified();
    //     } else {
    //         value += stepSize;
    //         valueModified();
    //     }
    // }

    // function decrease() {
    //     if (value - stepSize < from) {
    //         value = wrap ? to : from;
    //         valueModified();
    //     } else {
    //         value -= stepSize;
    //         valueModified();
    //     }
    // }
    FontMetrics {
        id: fm
        readonly property real charWidth: advanceWidth("W")
        font: spinbox.contentItem.font
    }
    component Btn: Item {
        implicitWidth: Math.min(spinbox.implicitWidth, spinbox.implicitHeight)
        implicitHeight: implicitWidth
        property alias text: displayText.text
        property alias mouseArea: mouseArea
        StyledText {
            id: displayText
            color: Config.white
            anchors.centerIn: parent
            font.pointSize: spinbox._fontSize
        }
        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
        }
    }
}
