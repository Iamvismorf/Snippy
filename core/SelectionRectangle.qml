import QtQuick
import qs.components
import qs.singletons

Rectangle {
    id: root

    readonly property int _resizeZoneWidth: 12
    readonly property bool locked: Globals.selectedTool != Enums.Tools.None

    property bool resizing: false
    property var cursor: null

    property real startX
    property real startY
    property bool active: false

    color: "transparent"
    border.width: 1
    border.color: Config.accent

    state: "notCreated"
    states: [
        State {
            name: "notCreated"
            PropertyChanges {
                root.opacity: 0
            }
        },
        State {
            name: "creating"
            PropertyChanges {
                root.opacity: 1
            }
        },
        State {
            name: "created"
        }
    ]
    transitions: [
        Transition {
            from: "*"
            to: "notCreated"

            SequentialAnimation {
                PauseAnimation {
                    duration: 75
                }
                InOutAnim {
                    property: "opacity"
                }
                ScriptAction {
                    script: {
                        root.implicitWidth = 0;
                        root.implicitHeight = 0;
                    }
                }
            }
        }
    ]

    Repeater {
        model: parent.state == "created" ? [
            {
                h: parent.left,
                v: undefined,
                cursor: Qt.SizeHorCursor,
                left: true
            },
            {
                h: undefined,
                v: parent.top,
                cursor: Qt.SizeVerCursor,
                up: true
            },
            {
                h: parent.right,
                v: undefined,
                cursor: Qt.SizeHorCursor,
                right: true
            },
            {
                h: undefined,
                v: parent.bottom,
                cursor: Qt.SizeVerCursor,
                down: true
            },
            {
                h: parent.left,
                v: parent.top,
                cursor: Qt.SizeFDiagCursor,
                up: true,
                left: true
            },
            {
                h: parent.right,
                v: parent.top,
                cursor: Qt.SizeBDiagCursor,
                up: true,
                right: true
            },
            {
                h: parent.right,
                v: parent.bottom,
                cursor: Qt.SizeFDiagCursor,
                down: true,
                right: true
            },
            {
                h: parent.left,
                v: parent.bottom,
                cursor: Qt.SizeBDiagCursor,
                down: true,
                left: true
            }
        ] : []

        Item {
            required property var modelData

            readonly property bool isCorner: modelData.h && modelData.v || false
            readonly property bool isHorizontal: !modelData.v
            readonly property bool isVertical: !modelData.h

            width: isCorner ? parent._resizeZoneWidth * 2 : isHorizontal ? parent._resizeZoneWidth : parent.width
            height: isCorner ? width : modelData.v == undefined ? parent.height : parent._resizeZoneWidth

            anchors {
                horizontalCenter: modelData.h
                verticalCenter: modelData.v
            }

            HoverHandler {
                enabled: !root.active
                cursorShape: root.locked ? Qt.ForbiddenCursor : modelData.cursor
            }

            SingleTapHandler {
                gesturePolicy: TapHandler.ReleaseWithinBounds
            }

            DragHandler {
                enabled: !root.locked
                target: null

                onGrabChanged: t => {
                    if (t == PointerDevice.GrabPassive && !root.resizing) {
                        root.resizing = true;
                        root.active = true; // this is needed. Trust
                        root.cursor = modelData.cursor;
                    } else if (t == PointerDevice.UngrabPassive) {
                        root.active = false;
                        root.resizing = false;
                        root.cursor = null;
                    }
                }

                onActiveTranslationChanged: delta => {
                    if (!!modelData.left) {
                        root.implicitWidth -= delta.x;
                        root.x += delta.x;
                    } else if (!!modelData.right) {
                        root.implicitWidth += delta.x;
                    }

                    if (!!modelData.up) {
                        root.implicitHeight -= delta.y;
                        root.y += delta.y;
                    } else if (!!modelData.down) {
                        root.implicitHeight += delta.y;
                    }
                }
                onActiveChanged: {
                    if (!active) {
                        if (root.implicitWidth < Config.minSelectionWidth || root.implicitHeight < Config.minSelectionHeight) {
                            root.destruct();
                        }
                    }
                }
            }
        }
    }

    HoverHandler {
        enabled: !root.locked && root.state == "created" && !root.resizing
        cursorShape: Qt.ArrowCursor
    }

    function destruct() {
        root.state = "notCreated";
    }
}
