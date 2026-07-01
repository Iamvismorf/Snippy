pragma ComponentBehavior: Bound

import Quickshell.Wayland
import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.components
import qs.toolbar
import qs.annotation
import qs.lib

PanelWindow {
    id: root

    required property ShellScreen modelData
    screen: modelData
    property int count: 0//todo: remove

    component Dim: Rectangle {
        color: Config.dimColor
    }

    anchors {
        left: true
        top: true
        right: true
        bottom: true
    }
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    // WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusionMode: ExclusionMode.Ignore

    PointHandler {
        id: pointHandler
        acceptedButtons: Qt.LeftButton

        // qmlformat off
        onActiveChanged: {
            if (active) {
                const mouse = point.position;

                if (!selectionRectangle.locked) { // no tools are selected
                    selectionRectangle.destruct(); // fixes weird toolbar anim
                    selectionRectangle.active = true;

                    // selectionRectangle.x = mouse.x;
                    // selectionRectangle.y = mouse.y;
                    selectionRectangle.startX = mouse.x;
                    selectionRectangle.startY = mouse.y;

                    selectionRectangle.state = "creating";
                }

                else {
                    canvas.temp = ({
                       startX: mouse.x,
                       startY: mouse.y,
                       x: mouse.x,
                       y: mouse.y,
                       type: Globals.selectedTool,
                       points: [],
                       thickness: Globals.thickness,
                       color: Qt.rgba(Globals.selectedColor.r, Globals.selectedColor.g, Globals.selectedColor.b) // bruh
                    });
                }
            }

            else {
               //todo: selection or eraser
               if (selectionRectangle.state == "created") { // we know this is triggered only when a tool is clicked
                  Globals.pushToHistory(canvas.temp)
                  canvas.temp = {};
               }

                if (selectionRectangle.active) {
                    selectionRectangle.active = false;
                }

                if (selectionRectangle.implicitWidth < Config.minSelectionWidth || selectionRectangle.implicitHeight < Config.minSelectionHeight) {
                    selectionRectangle.destruct();
                }

                else {
                    selectionRectangle.state = "created";
                }
            }
        }
        // qmlformat on

                // qmlformat off
        onPointChanged: {
            const mouse = point.position;

            if (!active)
                return;

            if (selectionRectangle.state == "creating") {
                const widthTmp = Math.abs(mouse.x - selectionRectangle.startX);
                const heightTmp = Math.abs(mouse.y - selectionRectangle.startY);
                if (widthTmp == 0 && heightTmp == 0) {
                    return;
                }

                selectionRectangle.x = Math.min(mouse.x, selectionRectangle.startX);
                selectionRectangle.y = Math.min(mouse.y, selectionRectangle.startY);
                selectionRectangle.implicitWidth = widthTmp;
                selectionRectangle.implicitHeight = heightTmp;
            }

            else if (selectionRectangle.state == "created" && active) {

               if (canvas.temp.type == Enums.Tools.Draw) {
                  canvas.temp.points.push(mouse);
               }
               else {
                  canvas.temp.x = mouse.x;
                  canvas.temp.y = mouse.y;
               }

               canvas.temp = Object.assign({}, canvas.temp)

               // switch (canvas.temp.type) {
               //    case Enums.Tools.FilledRectangle:
               //
               //
               //    Object.assign(canvas.temp, {
               //
               //       x: Math.min(mouse.x, canvas.temp.startX),
               //       y: Math.min(mouse.y, canvas.temp.startY),
               //       w: Math.abs(mouse.x - canvas.temp.startX),
               //       h: Math.abs(mouse.y - canvas.temp.startY)
               //
               //    })
               //
               //    break;
               // }
            }

        }
            // qmlformat on
    }
    HoverHandler {
        id: hoverhandler
        cursorShape: Qt.CrossCursor
    }

    FocusScope {
        width: parent.width
        height: parent.height

        focus: true

        Keys.onEscapePressed: {
            if (Config.clearSelectionOnEscape && selectionRectangle.state == "created") {
                selectionRectangle.destruct();
            } else {
                Qt.quit();
            }
        }
        Keys.onReturnPressed: {
            // let rx = Math.round(selectionRectangle.x);
            // let ry = Math.round(selectionRectangle.y);
            // let rw = Math.round(selectionRectangle.width);
            // let rh = Math.round(selectionRectangle.height);
            //
            // result.width = rw;
            // result.height = rh;
            // result.x = rx;
            // result.y = ry;
            //
            // content.x = -rx;
            // content.y = -ry;
            //
            // result.grabToImage(function (r) {
            //     r.saveToFile("something.png");
            // });
        }

        ShortcutInhibitor {
            window: root
            enabled: true
        }
    }
    Item {
        id: result

        width: root.width
        height: root.height
        clip: true

        Item {
            id: content
            width: root.width
            height: root.height

            ScreencopyView {
                id: screenCopy

                // paintCursor: true
                // captureSource: modelData
                // anchors.fill: parent
            }
            AnnotationCanvas {
                id: canvas
                anchors.fill: parent
            }
        }
    }
    SelectionRectangle {
        id: selectionRectangle

        readonly property bool locked: Globals.selectedTool != Enums.Tools.None

        DragHandler {
            id: selectionRectangleDragHandler
            enabled: !selectionRectangle.locked

            cursorShape: Qt.DragMoveCursor
            // grabPermissions: PointerHandler.TakeOverForbidden

            xAxis {
                minimum: 0
                maximum: root.width - selectionRectangle.width
            }
            yAxis {
                minimum: 0
                maximum: root.height - selectionRectangle.height
            }
            onActiveChanged: selectionRectangle.active = active
        }
        TapHandler {
            enabled: selectionRectangleDragHandler.enabled

            gesturePolicy: TapHandler.ReleaseWithinBounds
            onActiveChanged: selectionRectangle.active = active
        }
    }
    Item {
        anchors.fill: parent
        layer.enabled: true
        // opacity: 0.6
        opacity: 0.2

        Dim {
            //top
            width: parent.width
            height: selectionRectangle.y
        }
        Dim {
            // left
            width: selectionRectangle.x
            height: parent.height
        }
        Dim {
            // down
            width: parent.width
            height: parent.height - (selectionRectangle.state == "notCreated" ? 0 : (selectionRectangle.y + selectionRectangle.height))

            y: selectionRectangle.y + (selectionRectangle.state == "notCreated" ? 0 : selectionRectangle.height)
        }
        Dim {
            //right
            width: parent.width - (selectionRectangle.state == "notCreated" ? 0 : (selectionRectangle.x + selectionRectangle.width))
            height: parent.height

            x: selectionRectangle.x + (selectionRectangle.state == "notCreated" ? 0 : selectionRectangle.width)
        }
    }

    DimensionBadge {
        selectionRectangle: selectionRectangle

        anchors.horizontalCenter: selectionRectangle.horizontalCenter
        anchors.bottom: selectionRectangle.top
        anchors.bottomMargin: 8
    }
    Toolbar {
        id: toolbar
        selectionRectangle: selectionRectangle

        anchors.top: selectionRectangle.bottom
        anchors.horizontalCenter: selectionRectangle.horizontalCenter
        anchors.topMargin: 24

        onAction: action => {
            switch (action) {
            case Enums.Actions.Undo:
                Globals.undo();
                break;
            case Enums.Actions.Redo:
                Globals.redo();
                break;
            case Enums.Actions.Abort:
                Qt.quit();
                break;
            }
        }
    }

    component Seperator: Rectangle {
        width: 1
        Layout.fillHeight: true
        Layout.alignment: Qt.AlignVCenter
        Layout.topMargin: 2
        Layout.bottomMargin: Layout.topMargin
        color: Qt.lighter(Config.black, 4.5)
    }

    component Icon: KirigamiIcon {
        // required property var callBack

        Layout.alignment: Qt.AlignVCenter

        size: Config.toolbarIconSize
        fillColor: Config.gray
    }

    // Timer {
    //     interval: 120
    //     repeat: true
    //     running: !screenCopy.hasContent
    //     property int tries: 0
    //     onTriggered: {
    //         if (screenCopy.hasContent || tries > 10) {
    //             running = false;
    //             return;
    //         }
    //         screenCopy.captureFrame();
    //         tries += 1;
    //     }
    // }
}
