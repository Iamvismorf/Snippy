pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.synchronizer
import Quickshell
import qs.components
import qs.annotation
import qs.singletons
import "./icon"

Rectangle {
    id: root

    required property Rectangle selectionRectangle

    signal action(action: int/*Enums.Actions*/)

    implicitWidth: rowLayout.implicitWidth + Config.horizontalPading
    implicitHeight: rowLayout.implicitHeight + Config._popupPadding * 3

    radius: 10
    color: Config.white
    // clip: true
    opacity: !selectionRectangle.active && selectionRectangle.state == "created"
    visible: opacity

    RowLayout {
        id: rowLayout
        anchors.centerIn: parent

        spacing: 16

        // the placement of this is pretty much hardcoded. The Icon is manually left aligned with inkscape but whatever, it looks good
        RowGroup {
            spacing: 0
            Icon {
                source: Quickshell.iconPath(Quickshell.shellPath("assets/dragIndicator.svg"))
                color: "transparent"

                mouseArea.enabled: false
                icon.color: hoverhandler.hovered ? Config.accent : icon._defaultColor
                DragHandler {
                    id: dragHandler
                    target: root
                    cursorShape: Qt.DragMoveCursor
                }
                HoverHandler {
                    id: hoverhandler
                    cursorShape: Qt.OpenHandCursor
                }
            }
            StyledText {
                id: dimensionText

                color: Config.black
                text: Math.round(root.selectionRectangle.width) + " × " + Math.round(root.selectionRectangle.height)
            }
        }
        Seperator {}

        RowGroup {
            Repeater {
                model: [
                    {
                        icon: "mouse",
                        type: Enums.Tools.Select
                    },
                    {
                        icon: "drawing",
                        type: Enums.Tools.Draw
                    },
                    {
                        icon: "eraser",
                        type: Enums.Tools.Erase
                    },
                    {
                        icon: "filled",
                        icons: ["squareFilled", "square"],
                        defaultTo: Config.rectangleDefaultToFilled,
                        types: [Enums.Tools.FilledRectangle, Enums.Tools.Rectangle]
                    },
                    {
                        icon: "line",
                        type: Enums.Tools.Line
                    },
                    {
                        icon: "arrow",
                        type: Enums.Tools.Arrow
                    },
                    {
                        icon: "filled",
                        icons: ["circleFilled", "circle"],
                        defaultTo: Config.ellipseDefaultToFilled,
                        types: [Enums.Tools.FilledEllipse, Enums.Tools.Ellipse]
                    },
                    {
                        icon: "highlighter",
                        types: [Enums.Tools.HighlightRectangle, Enums.Tools.HighlightDraw]
                    },
                    {
                        icon: "steps",
                        type: Enums.Tools.Steps
                    },
                    {
                        icon: "pixelate",
                        type: Enums.Tools.Pixelate
                    },
                    {
                        icon: "textAlt",
                        type: Enums.Tools.Text
                    }
                ]
                DelegateChooser {
                    role: "icon"
                    DelegateChoice {
                        roleValue: "filled"
                        delegate: IconBackground {
                            id: filledComp

                            required property var modelData
                            property Item _current: modelData.defaultTo ? filled : notFilled
                            toolTip.text: Enums.toolsToString(_current.type)
                            implicitWidth: _current.implicitWidth
                            implicitHeight: _current.implicitHeight
                            innerPadding: 0

                            color: {
                                if (Globals.selectedTool == _current.type) {
                                    return Config.accent;
                                }
                                if (mouseArea.containsMouse) {
                                    return Config.lightGray;
                                }
                                return Qt.rgba(1, 1, 1, 0);
                            }

                            Icon {
                                id: filled

                                readonly property int type: modelData.types[0]
                                source: Quickshell.iconPath(Quickshell.shellPath(`assets/${modelData.icons[0]}.svg`))
                                color: "transparent"

                                icon.color: {
                                    if (Globals.selectedTool == type) {
                                        return Config.white;
                                    }
                                    return icon._defaultColor;
                                }

                                opacity: parent._current == this
                                visible: opacity

                                Behavior on opacity {
                                    InOutAnim {}
                                }

                                mouseArea.enabled: false
                            }
                            Icon {
                                id: notFilled

                                readonly property int type: modelData.types[1]
                                source: Quickshell.iconPath(Quickshell.shellPath(`assets/${modelData.icons[1]}.svg`))
                                color: "transparent"

                                icon.color: {
                                    if (Globals.selectedTool == type) {
                                        return Config.white;
                                    }
                                    return icon._defaultColor;
                                }

                                opacity: parent._current == this
                                visible: opacity

                                Behavior on opacity {
                                    InOutAnim {}
                                }

                                mouseArea.enabled: false
                            }
                            mouseArea {
                                acceptedButtons: Qt.LeftButton | Qt.RightButton
                                onClicked: m => {
                                    if (m.button == Qt.LeftButton) {
                                        if (Globals.selectedTool == filledComp._current.type) {
                                            Globals.selectedTool = Enums.Tools.None;
                                        } else {
                                            Globals.selectedTool = Qt.binding(function () {
                                                return filledComp._current.type;
                                            });
                                        }
                                    } else {
                                        filledComp._current = filledComp._current == filled ? notFilled : filled;
                                    }
                                }
                            }
                        }
                    }
                    DelegateChoice {
                        roleValue: "highlighter"
                        delegate: Icon {
                            id: highlighter
                            required property var modelData
                            property int _current: Config.highlightDefaultToRectangle ? modelData.types[0] : modelData.types[1]
                            property bool _selected: Globals.selectedTool == _current

                            source: Quickshell.iconPath(Quickshell.shellPath(`assets/${modelData.icon}.svg`))
                            toolTip.text: Enums.toolsToString(_current)

                            color: {
                                if (Globals.selectedTool == _current) {
                                    return Config.accent;
                                }
                                if (mouseArea.containsMouse) {
                                    return Config.lightGray;
                                }
                                return Qt.rgba(1, 1, 1, 0);
                            }
                            icon.color: {
                                if (Globals.selectedTool == _current) {
                                    return Config.white;
                                }
                                return icon._defaultColor;
                            }

                            mouseArea {
                                acceptedButtons: Qt.LeftButton | Qt.RightButton
                                onClicked: m => {
                                    if (m.button == Qt.LeftButton) {
                                        if (highlighter._selected) {
                                            Globals.selectedTool = Enums.Tools.None;
                                        } else {
                                            Globals.selectedTool = Qt.binding(function () {
                                                return highlighter._current;
                                            });
                                        }
                                    } else {
                                        highlighter._current = highlighter._current == modelData.types[0] ? modelData.types[1] : modelData.types[0];
                                    }
                                }
                            }

                            StyledRectangle {
                                anchors.horizontalCenter: parent.left
                                // anchors.bottom: parent.bottom
                                implicitWidth: highlighter._current == highlighter.modelData.types[0] ? 12 : height
                                height: highlighter._current == highlighter.modelData.types[0] ? 8 : 10

                                animatedColor: true
                                animatedSize: true
                                radius: highlighter._current == highlighter.modelData.types[0] ? 0 : height
                                color: highlighter._selected ? Config.white : highlighter.icon._defaultColor

                                border {
                                    width: highlighter._selected ? 1 : 0
                                    color: Config.accent
                                }
                            }
                        }
                    }
                    DelegateChoice {
                        delegate: Icon {
                            required property var modelData
                            readonly property bool _available: {
                                if (modelData.type == Enums.Tools.Select || modelData.type == Enums.Tools.Erase)
                                    return Globals.history.length > 0;
                                else
                                    return true;
                            }

                            source: Quickshell.iconPath(Quickshell.shellPath(`assets/${modelData.icon}.svg`))
                            toolTip.text: Enums.toolsToString(modelData.type)

                            color: {
                                if (Globals.selectedTool == modelData.type) {
                                    return Config.accent;
                                }
                                if (mouseArea.containsMouse) {
                                    return Config.lightGray;
                                }
                                return Qt.rgba(1, 1, 1, 0);
                            }
                            icon.color: {
                                if (!_available) {
                                    return Config.gray;
                                }
                                if (Globals.selectedTool == modelData.type) {
                                    return Config.white;
                                }
                                return icon._defaultColor;
                            }

                            mouseArea.cursorShape: _available ? Qt.PointingHandCursor : Qt.ForbiddenCursor
                            mouseArea.onClicked: {
                                if (_available) {
                                    if (Globals.selectedTool == modelData.type) { // deselect tool
                                        Globals.selectedTool = Enums.Tools.None;
                                    } else { // select tool
                                        Globals.selectedTool = modelData.type;
                                        // console.log(root.mapFromItem(parent, x, y));//send
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        Seperator {}

        ColorPalette {}
        Seperator {}

        Thickness {}
        Seperator {}

        RowGroup {
            Repeater {
                model: [
                    {
                        icon: "undo",
                        action: Enums.Actions.Undo,
                        shortcut: "Ctrl+z"
                    },
                    {
                        icon: "redo",
                        action: Enums.Actions.Redo,
                        shortcut: "Ctrl+y"
                    },
                    {
                        icon: "clear",
                        action: Enums.Actions.Clear
                    }
                ]
                DelegateChooser {
                    role: "icon"
                    DelegateChoice {
                        roleValue: "clear"
                        delegate: Icon {
                            required property var modelData
                            readonly property bool _available: Globals.consumedHistory.length > 0

                            source: Quickshell.iconPath(Quickshell.shellPath(`assets/${modelData.icon}.svg`))

                            icon.color: _available ? Config.red : Config.gray
                            mouseArea.cursorShape: _available ? Qt.PointingHandCursor : Qt.ForbiddenCursor
                            mouseArea.onClicked: {
                                if (_available) {
                                    root.action(modelData.action);
                                }
                            }

                            color: {
                                if (mouseArea.containsMouse) {
                                    if (_available) {
                                        return Qt.lighter(Config.red, 1.65);
                                    } else {
                                        return Config.lightGray;
                                    }
                                } else {
                                    return Qt.rgba(1, 1, 1, 0);
                                }
                            }
                            toolTip.text: `${Enums.actionsToString(modelData.action)}`
                        }
                    }

                    DelegateChoice {
                        delegate: Icon {
                            required property var modelData
                            readonly property bool _available: {
                                if (modelData.action == Enums.Actions.Undo)
                                    return Globals.cstep > -1;
                                return Globals.cstep != Globals.history.length - 1;
                            }

                            source: Quickshell.iconPath(Quickshell.shellPath(`assets/${modelData.icon}.svg`))
                            innerPadding: 2

                            icon.color: _available ? icon._defaultColor : Config.gray
                            mouseArea.cursorShape: _available ? Qt.PointingHandCursor : Qt.ForbiddenCursor
                            mouseArea.onClicked: {
                                if (_available) {
                                    root.action(modelData.action);
                                }
                            }

                            radius: 100
                            color: mouseArea.containsMouse ? Config.lightGray : Qt.rgba(1, 1, 1, 0)
                            toolTip.text: `${Enums.actionsToString(modelData.action)} <span style=\"color:${Config.accent};\">${modelData.shortcut}</span>`
                        }
                    }
                }
            }
        }
        RowGroup {
            spacing: 6
            StyledText {
                text: Globals.cstep + 1
                color: Config.accent
                font.features: {
                    "tnum": 1
                }
            }
            StyledText {
                text: "of"
            }
            StyledText {
                text: Globals.history.length
                font.features: {
                    "tnum": 1
                }
            }
        }
        Seperator {}

        RowGroup {
            Repeater {
                model: [
                    {
                        icon: "copy",
                        action: Enums.Actions.Copy,
                        shortcut: "Ctrl+c"
                    },
                    {
                        icon: "save",
                        action: Enums.Actions.Save,
                        shortcut: "Ctrl+s"
                    },
                    {
                        icon: "close",
                        action: Enums.Actions.Abort,
                        shortcut: "Esc"
                    }
                ]
                delegate: Icon {
                    required property var modelData

                    readonly property bool _isCloseIcon: modelData.action == Enums.Actions.Abort

                    source: Quickshell.iconPath(Quickshell.shellPath(`assets/${modelData.icon}.svg`))
                    color: {
                        if (mouseArea.containsMouse) {
                            if (_isCloseIcon) {
                                return Qt.lighter(Config.red, 1.65);
                            } else {
                                return Config.lightGray;
                            }
                        }
                        return Qt.rgba(1, 1, 1, 0);
                    }

                    icon.color: _isCloseIcon ? Config.red : icon._defaultColor
                    mouseArea.onClicked: root.action(modelData.action)
                    toolTip.text: `${Enums.actionsToString(modelData.action)} <span style=\"color:${Config.accent};\">${modelData.shortcut}</span>`
                }
            }
        }
    }
    // CustomSpinBox {
    //     id: spinbox
    //
    //     from: -99
    //     to: 99
    //     wrap: true
    //     radius: 12
    //     padding: 6
    //     color: Config.white
    //
    //     Connections {
    //         target: Globals
    //         function onStepChanged() {
    //             if (Globals.step > spinbox.to) {
    //                 spinbox.value = spinbox.from;
    //             } else if (Globals.step < spinbox.from) {
    //                 spinbox.value = spinbox.to;
    //             }
    //         }
    //     }
    //
    //     Synchronizer on value {
    //         sourceObject: Globals
    //         sourceProperty: "step"
    //
    //         targetObject: spinbox
    //         targetProperty: "value"
    //     }
    //
    //     textFromValue: function (value, locale) {
    //         if (value == 0 && spinbox.contentItem.activeFocus) {
    //             return "";
    //         }
    //         return Number(value).toLocaleString(locale, 'f', 0);
    //     }
    //
    //     valueFromText: function (text, locale) {
    //         if (text.trim() === "")
    //             return 0;
    //         return parseInt(text, 10);
    //     }
    //
    //     anchors.top: parent.bottom
    //     anchors.topMargin: 16
    // }

    HoverHandler {
        cursorShape: Qt.ArrowCursor
    }
    SingleTapHandler {
        gesturePolicy: TapHandler.ReleaseWithinBounds
    }

    Behavior on opacity {
        enabled: selectionRectangle.state != "notCreated"
        InOutAnim {}
    }

    component Seperator: Rectangle {
        width: 1
        Layout.fillHeight: true
        Layout.alignment: Qt.AlignVCenter
        Layout.topMargin: 2
        Layout.bottomMargin: Layout.topMargin
        color: Config.gray
    }
}
