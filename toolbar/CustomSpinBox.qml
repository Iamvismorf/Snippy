//todo: fix this: enter `from` value -> esc -> enter value less than `from` -> esc
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Basic
import Quickshell
import qs.components
import qs.lib
import "../"

Basic.SpinBox {
    id: spinbox

    from: 0
    to: 0
    live: true
    editable: true
    locale: Qt.locale("C")
    Keys.onEscapePressed: spinbox.focus = false

    down.indicator: StyledRectangle {
        x: spinbox.mirrored ? parent.width - width : 0

        implicitWidth: spinbox.implicitHeight
        implicitHeight: implicitWidth

        topLeftRadius: spinbox.background.radius
        bottomLeftRadius: spinbox.background.radius
        color: spinbox.down.pressed ? Config.gray : Qt.rgba(1, 1, 1, 0)

        StyledRectangle {
            readonly property bool _disabled: !spinbox.wrap && spinbox.value == spinbox.from
            anchors.centerIn: parent
            width: parent.width - parent.width * 0.6
            height: 2

            animatedColor: true
            color: _disabled ? Config.gray : Config.black
        }
    }

    contentItem: TextInput {
        // text: spinbox.textFromValue(spinbox.value, spinbox.locale)
        text: spinbox.displayText

        color: Config.accent
        padding: 4
        selectionColor: Config.accent
        selectedTextColor: Lib.isDark(selectionColor) ? Config.white : Config.black
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter

        readOnly: !spinbox.editable
        validator: spinbox.validator

        // function onTextEdited() {
        //     let val = parseInt(spinbox.contentItem.text);
        //     if (val > spinbox.to || val < spinbox.from) {
        //         spinbox.contentItem.text = Qt.binding(function () {
        //             return spinbox.value;
        //         });
        //     }
        // }
    }
    background: StyledRectangle {
        implicitWidth: fm.charWidth * Math.max(spinbox.from.toString().length, spinbox.to.toString().length) + 20 + spinbox.down.implicitIndicatorWidth + spinbox.up.implicitIndicatorWidth
        color: Config.lightGray
        radius: 8
    }

    up.indicator: StyledRectangle {
        readonly property bool _disabled: !spinbox.wrap && spinbox.value == spinbox.to

        x: spinbox.mirrored ? 0 : spinbox.width - width

        implicitWidth: spinbox.implicitHeight
        implicitHeight: implicitWidth

        topRightRadius: spinbox.background.radius
        bottomRightRadius: spinbox.background.radius
        color: spinbox.up.pressed ? Config.gray : Qt.rgba(1, 1, 1, 0)

        StyledRectangle {
            anchors.centerIn: parent
            width: parent.width - parent.width * 0.6
            height: 2

            animatedColor: true
            color: parent._disabled ? Config.gray : Config.black
        }
        StyledRectangle {
            anchors.centerIn: parent
            width: 2
            height: parent.width - parent.width * 0.6

            animatedColor: true
            color: parent._disabled ? Config.gray : Config.black
        }
    }

    FontMetrics {
        id: fm
        readonly property real charWidth: advanceWidth("W")
        font.family: Config.fontFamily
        font.styleName: Config.fontFamilyStyle
    }
}
