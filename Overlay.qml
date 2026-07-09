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

    DragHandler {
        enabled: !tapHandler.enabled
        target: null
        onActiveChanged: {
            if (active) {
                if (!selectionRectangle.locked) {
                    selectionRectangle.destruct();
                    selectionRectangle.state = "creating";
                }
            } else {
                if (selectionRectangle.state == "created") {
                    canvas.commitTemp();
                } else if (selectionRectangle.state == "creating" && selectionRectangle.implicitWidth < Config.minSelectionWidth || selectionRectangle.implicitHeight < Config.minSelectionHeight) {
                    selectionRectangle.destruct();
                } else {
                    selectionRectangle.state = "created";
                }
            }
            selectionRectangle.active = active;
        }
        onCentroidChanged: {
            if (!active)
                return;

            if (selectionRectangle.state == "creating") { // drawing selection rectangle
                selectionRectangle.x = Math.min(centroid.position.x, centroid.pressPosition.x);
                selectionRectangle.y = Math.min(centroid.position.y, centroid.pressPosition.y);
                selectionRectangle.implicitWidth = Math.abs(centroid.position.x - centroid.pressPosition.x);
                selectionRectangle.implicitHeight = Math.abs(centroid.position.y - centroid.pressPosition.y);
            } else if (selectionRectangle.state == "created") { // handling tools that need dragging
                canvas.temp = {
                    id: canvas.tempId,
                    startX: centroid.pressPosition.x,
                    startY: centroid.pressPosition.y,
                    endX: centroid.position.x,
                    endY: centroid.position.y,
                    type: Globals.selectedTool,
                    thickness: Globals.thickness,
                    color: Qt.rgba(Globals.selectedColor.r, Globals.selectedColor.g, Globals.selectedColor.b) // bruh
                };
            }
        }
    }
    SingleTapHandler {
        id: tapHandler
        property point _lastPosition
        property point _cumulativeDelta: Qt.point(0, 0)

        enabled: Globals.selectedTool == Enums.Tools.Erase || Globals.selectedTool == Enums.Tools.Select || Globals.selectedTool == Enums.Tools.Draw || Globals.selectedTool == Enums.Tools.Steps
        gesturePolicy: TapHandler.WithinBounds

        onPressedChanged: {
            if (!pressed) {
                _cumulativeDelta = Qt.point(0, 0);
                canvas.commitTemp();
                return;
            }
            let child = canvas.childAt(point.pressPosition.x, point.pressPosition.y);
            if (Globals.selectedTool == Enums.Tools.Erase) {
                if (child) {
                    canvas.pushToHistory({
                        type: Enums.Tools.Erase,
                        ids: [child.annotation.id]
                    });
                }
            } else if (Globals.selectedTool == Enums.Tools.Select) {
                _lastPosition = point.pressPosition;
                Globals.selectedChild = child;
                Globals.selectedChildId = child?.annotation?.id ?? -1;
            }
        }
        onPointChanged: {
            selectionRectangle.active = active && point.velocity.length() > 0;
            if (active) {
                if (Globals.selectedTool == Enums.Tools.Draw) {
                    let pts = canvas.temp?.points ?? [];
                    pts.push(point.position);
                    canvas.temp = {
                        id: canvas.tempId,
                        type: Enums.Tools.Draw,
                        startX: point.pressPosition.x,
                        startY: point.pressPosition.y,
                        points: pts,
                        thickness: Globals.thickness,
                        color: Qt.rgba(Globals.selectedColor.r, Globals.selectedColor.g, Globals.selectedColor.b) // bruh
                    };
                } else if (Globals.selectedTool == Enums.Tools.Select && Globals.selectedChild && point.velocity.length() > 0) {
                    let deltaX = point.position.x - _lastPosition.x;
                    let deltaY = point.position.y - _lastPosition.y;

                    Globals.selectedChild.x += deltaX;
                    Globals.selectedChild.y += deltaY;

                    _cumulativeDelta.x += deltaX;
                    _cumulativeDelta.y += deltaY;

                    _lastPosition = point.position;
                    canvas.temp = {
                        type: Enums.Tools.Select,
                        target: Globals.selectedChild.annotation.id,
                        deltaX: _cumulativeDelta.x,
                        deltaY: _cumulativeDelta.y
                    };
                }
            }
        }
    }

    // PointHandler {
    //     id: pointHandler
    //     acceptedButtons: Qt.LeftButton
    //
    //     onActiveChanged: {
    //         if (active) {
    //             const mouse = point.position;
    //
    //             if (!selectionRectangle.locked) { // no tools are selected
    //                 selectionRectangle.destruct(); // fixes weird toolbar anim
    //                 selectionRectangle.active = true;
    //
    //                 // selectionRectangle.x = mouse.x;
    //                 // selectionRectangle.y = mouse.y;
    //                 selectionRectangle.startX = mouse.x;
    //                 selectionRectangle.startY = mouse.y;
    //
    //                 selectionRectangle.state = "creating";
    //             } else {
    //                 if (Globals.selectedTool == Enums.Tools.Erase) {
    //                     let annotationId = canvas.childAt(mouse.x, mouse.y)?.annotation?.id;
    //                     if (annotationId != undefined) {
    //                         canvas.pushToHistory({
    //                             type: Enums.Tools.Erase,
    //                             ids: [annotationId]
    //                         });
    //                     }
    //                 } else if (Globals.selectedTool == Enums.Tools.Select) {
    //                     //todo: penis
    //                 } else {
    //                     canvas.temp = ({
    //                             id: canvas.tempId,
    //                             startX: mouse.x,
    //                             startY: mouse.y,
    //                             x: mouse.x,
    //                             y: mouse.y,
    //                             type: Globals.selectedTool,
    //                             points: [],
    //                             thickness: Globals.thickness,
    //                             color: Qt.rgba(Globals.selectedColor.r, Globals.selectedColor.g, Globals.selectedColor.b) // bruh
    //                         });
    //                     canvas.tempId++;
    //                 }
    //             }
    //         } else {
    //             //todo: selection or eraser
    //             if (selectionRectangle.state == "created") { // we know this is triggered only when a tool is selected
    //                 if (!Lib.isEmpty(canvas.temp)) {
    //                     canvas.pushToHistory(canvas.temp);
    //                     canvas.temp = {};
    //                 }
    //             }
    //
    //             if (selectionRectangle.active) {
    //                 selectionRectangle.active = false;
    //             }
    //
    //             if (selectionRectangle.implicitWidth < Config.minSelectionWidth || selectionRectangle.implicitHeight < Config.minSelectionHeight) {
    //                 selectionRectangle.destruct();
    //             } else {
    //                 selectionRectangle.state = "created";
    //             }
    //         }
    //     }
    //     onPointChanged: {
    //         const mouse = point.position;
    //
    //         if (!active)
    //             return;
    //
    //         if (selectionRectangle.state == "creating") {
    //             const widthTmp = Math.abs(mouse.x - selectionRectangle.startX);
    //             const heightTmp = Math.abs(mouse.y - selectionRectangle.startY);
    //             if (widthTmp == 0 && heightTmp == 0) {
    //                 return;
    //             }
    //
    //             selectionRectangle.x = Math.min(mouse.x, selectionRectangle.startX);
    //             selectionRectangle.y = Math.min(mouse.y, selectionRectangle.startY);
    //             selectionRectangle.implicitWidth = widthTmp;
    //             selectionRectangle.implicitHeight = heightTmp;
    //         } else if (selectionRectangle.state == "created" && Globals.selectedTool != Enums.Tools.Erase) {
    //             if (canvas.temp.type == Enums.Tools.Draw) {
    //                 canvas.temp.points.push(mouse);
    //             } else {
    //                 canvas.temp.x = mouse.x;
    //                 canvas.temp.y = mouse.y;
    //             }
    //
    //             canvas.temp = Object.assign({}, canvas.temp);
    //         }
    //     }
    // }
    HoverHandler {
        id: hoverhandler
        cursorShape: Globals.selectedTool == Enums.Tools.Erase || Globals.selectedTool == Enums.Tools.Select ? Qt.ArrowCursor : Qt.CrossCursor
    }

    FocusScope {
        width: parent.width
        height: parent.height

        focus: true

        Keys.onEscapePressed: {
            Qt.quit();
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

            xAxis {
                minimum: 0
                maximum: root.width - selectionRectangle.width
            }
            yAxis {
                minimum: 0
                maximum: root.height - selectionRectangle.height
            }
            onGrabChanged: t => {
                if (t == PointerDevice.GrabPassive) {
                    selectionRectangle.active = true;
                } else if (t == PointerDevice.UngrabPassive) {
                    selectionRectangle.active = false;
                }
            }
        }
    }
    Item {
        anchors.fill: parent
        layer.enabled: true
        opacity: 0.6

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
                canvas.undo();
                break;
            case Enums.Actions.Redo:
                canvas.redo();
                break;
            case Enums.Actions.Abort:
                Qt.quit();
                break;
            case Enums.Actions.Clear:
                canvas.clearAll();
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
