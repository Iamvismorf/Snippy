pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.components
import qs.annotation
import "../"
import Snippy as Snippy

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

        StyledText {
            id: dimensionText

            font.pixelSize: 15
            color: Config.black
            text: Math.round(root.selectionRectangle.width) + " × " + Math.round(root.selectionRectangle.height)
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
                        types: [Enums.Tools.FilledEllipse, Enums.Tools.Ellipse]
                    },
                    {
                        icon: "highlighter",
                        type: Enums.Tools.Highlight
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
                            property Item _current: filled

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
                                property string eyedih: "filled"

                                icon.color: {
                                    if (Globals.selectedTool == type) {
                                        return Config.white;
                                    }
                                    return Config.black;
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
                                property string eyedih: "notfilled"

                                icon.color: {
                                    if (Globals.selectedTool == type) {
                                        return Config.white;
                                    }
                                    return Config.black;
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
                        delegate: Icon {
                            required property var modelData
                            readonly property bool _available: {
                                if (modelData.type == Enums.Tools.Select || modelData.type == Enums.Tools.Erase)
                                    return Globals.history.length > 0;
                                else
                                    return true;
                            }

                            source: Quickshell.iconPath(Quickshell.shellPath(`assets/${modelData.icon}.svg`))

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
                                return Config.black;
                            }

                            mouseArea.cursorShape: _available ? Qt.PointingHandCursor : Qt.ForbiddenCursor
                            mouseArea.onClicked: {
                                if (_available) {
                                    if (Globals.selectedTool == modelData.type) {
                                        Globals.selectedTool = Enums.Tools.None;
                                    } else {
                                        Globals.selectedTool = modelData.type;
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
                        action: Enums.Actions.Undo
                    },
                    {
                        icon: "redo",
                        action: Enums.Actions.Redo
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

                            icon.color: _available ? Config.black : Config.gray
                            mouseArea.cursorShape: _available ? Qt.PointingHandCursor : Qt.ForbiddenCursor
                            mouseArea.onClicked: {
                                if (_available) {
                                    root.action(modelData.action);
                                }
                            }

                            radius: 100
                            color: mouseArea.containsMouse ? Config.lightGray : Qt.rgba(1, 1, 1, 0)
                        }
                    }
                }
            }
        }
        Seperator {}

        RowGroup {
            Repeater {
                model: [
                    {
                        icon: "copy",
                        action: Enums.Actions.Copy
                    },
                    {
                        icon: "save",
                        action: Enums.Actions.Save
                    },
                    {
                        icon: "close",
                        action: Enums.Actions.Abort
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

                    icon.color: _isCloseIcon ? Config.red : Config.black
                    mouseArea.onClicked: root.action(modelData.action)
                }
            }
        }
    }

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
    component IconBackground: StyledRectangle {
        property alias mouseArea: mouseArea
        property int innerPadding: 4

        radius: 4
        Behavior on color {
            ColorAnimation {
                duration: 275
            }
        }
        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
        }
    }

    component Icon: IconBackground {
        id: iconComp
        property alias source: snippyIcon.source
        property int size: Config.toolbarIconSize
        property alias iconColor: snippyIcon.color

        property alias icon: snippyIcon

        implicitWidth: snippyIcon.implicitWidth + innerPadding * 2
        implicitHeight: snippyIcon.implicitHeight + innerPadding * 2

        Snippy.SvgIcon {
            // KirigamiIcon {
            id: snippyIcon

            anchors.centerIn: parent
            implicitWidth: iconComp.size
            implicitHeight: iconComp.size
            color: Config.black

            Behavior on color {
                ColorAnimation {
                    duration: 275
                }
            }
        }
    }
}
