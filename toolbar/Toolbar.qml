pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.components
import "../"

Rectangle {
    id: root

    required property Rectangle selectionRectangle

    signal action(action: int/*Enums.Actions*/)

    implicitWidth: rowLayout.implicitWidth + Config.horizontalPading
    implicitHeight: rowLayout.implicitHeight + Config._popupPadding * 3

    radius: 10
    color: Config.white
    clip: true
    opacity: !selectionRectangle.active && selectionRectangle.state == "created" //todo: should also be when drawing
    // opacity: 1
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
                        icon: "blur",
                        type: Enums.Tools.Blur
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

                            color: {
                                if (Globals.selectedTool == _current.type) {
                                    return Config.accent;
                                }
                                if (hoverHandler.hovered) {
                                    return Config.lightGray;
                                }
                                return Qt.rgba(1, 1, 1, 0);
                            }

                            IconV2 {
                                id: filled

                                readonly property int type: modelData.types[0]
                                sauce: Quickshell.iconPath(Quickshell.shellPath(`assets/${modelData.icons[0]}.svg`))
                                color: "transparent"
                                property string eyedih: "filled"

                                icon.fillColor: {
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

                                tapHandler.enabled: false
                                hoverHandler.enabled: false
                            }
                            IconV2 {
                                id: notFilled

                                readonly property int type: modelData.types[1]
                                sauce: Quickshell.iconPath(Quickshell.shellPath(`assets/${modelData.icons[1]}.svg`))
                                color: "transparent"
                                property string eyedih: "notfilled"

                                icon.fillColor: {
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

                                tapHandler.enabled: false
                                hoverHandler.enabled: false
                            }
                            tapHandler {
                                acceptedButtons: Qt.LeftButton | Qt.RightButton
                                onTapped: (e, b) => {
                                    if (b == Qt.LeftButton) {
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
                        delegate: IconV2 {
                            required property var modelData
                            readonly property bool _available: {
                                if (modelData.type == Enums.Tools.Select || modelData.type == Enums.Tools.Erase)
                                    return Globals.history.length > 0;
                                else
                                    return true;
                            }

                            sauce: Quickshell.iconPath(Quickshell.shellPath(`assets/${modelData.icon}.svg`))

                            color: {
                                if (Globals.selectedTool == modelData.type) {
                                    return Config.accent;
                                }
                                if (hoverHandler.hovered) {
                                    return Config.lightGray;
                                }
                                return Qt.rgba(1, 1, 1, 0);
                            }
                            //here
                            icon.fillColor: {
                                if (!_available) {
                                    return Config.gray;
                                }
                                if (Globals.selectedTool == modelData.type) {
                                    return Config.white;
                                }
                                return Config.black;
                            }

                            hoverHandler.cursorShape: _available ? Qt.PointingHandCursor : Qt.ForbiddenCursor
                            tapHandler.enabled: _available
                            tapHandler.onTapped: {
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
        Seperator {}

        ColorPalette {
            id: palette
        }
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
                        delegate: IconV2 {
                            required property var modelData

                            sauce: Quickshell.iconPath(Quickshell.shellPath(`assets/${modelData.icon}.svg`))

                            icon.fillColor: Config.red

                            color: hoverHandler.hovered ? Qt.lighter(Config.red, 1.65) : Qt.rgba(1, 1, 1, 0)
                            tapHandler.onTapped: root.action(modelData.action)
                        }
                    }

                    DelegateChoice {
                        delegate: IconV2 {
                            required property var modelData
                            readonly property bool _available: {
                                if (modelData.action == Enums.Actions.Undo)
                                    return Globals.cstep > -1;
                                return Globals.cstep != Globals.history.length - 1;
                            }

                            sauce: Quickshell.iconPath(Quickshell.shellPath(`assets/${modelData.icon}.svg`))
                            innerPadding: 2

                            icon.fillColor: _available ? Config.black : Config.gray
                            hoverHandler.cursorShape: _available ? Qt.PointingHandCursor : Qt.ForbiddenCursor
                            tapHandler.enabled: _available
                            tapHandler.onTapped: root.action(modelData.action)

                            radius: 100
                            color: hoverHandler.hovered ? Config.lightGray : Qt.rgba(1, 1, 1, 0)
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
                delegate: IconV2 {
                    required property var modelData

                    readonly property bool _isCloseIcon: modelData.action == Enums.Actions.Abort

                    sauce: Quickshell.iconPath(Quickshell.shellPath(`assets/${modelData.icon}.svg`))
                    color: {
                        if (hoverHandler.hovered) {
                            if (_isCloseIcon) {
                                return Qt.lighter(Config.red, 1.65);
                            } else {
                                return Config.lightGray;
                            }
                        }
                        return Qt.rgba(1, 1, 1, 0);
                    }

                    icon.fillColor: _isCloseIcon ? Config.red : Config.black
                    tapHandler.onTapped: root.action(modelData.action)
                }
            }
        }
    }

    HoverHandler {
        cursorShape: Qt.ArrowCursor
    }
    TapHandler {
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
        property alias hoverHandler: hoverHandler
        property alias tapHandler: tapHandler

        radius: 4
        Behavior on color {
            ColorAnimation {
                duration: 275
            }
        }
        HoverHandler {
            id: hoverHandler
            cursorShape: Qt.PointingHandCursor
        }
        TapHandler {
            id: tapHandler
        }
    }

    component IconV2: IconBackground {
        id: iconComp

        property alias sauce: kirigamiIcon.sauce
        property alias size: kirigamiIcon.size
        property alias fillColor: kirigamiIcon.fillColor

        property alias icon: kirigamiIcon

        property int innerPadding: 4

        implicitWidth: kirigamiIcon.implicitWidth + innerPadding * 2
        implicitHeight: kirigamiIcon.implicitHeight + innerPadding * 2

        KirigamiIcon {
            id: kirigamiIcon

            anchors.centerIn: parent
            size: Config.toolbarIconSize
            fillColor: Config.black

            Behavior on fillColor {
                ColorAnimation {
                    duration: 275
                }
            }
        }
    }
}
