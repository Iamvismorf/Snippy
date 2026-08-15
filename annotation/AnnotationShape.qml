import QtQuick
import QtQuick.Shapes
import QtQuick.Shapes.DesignHelpers
import qs.lib
import qs.components
import qs.singletons

Item {
    id: root
    readonly property bool _selected: Globals.selectedChildId == annotation.id

    property var annotation
    property Item canvas
    property bool isTempObj: false
    property Item backdrop: null

    // dude I have no idea how this works, but it solves a dragging issue
    x: (ldr.item?.boundingRect?.x ?? 0) + (annotation?.offsetX ?? 0)
    y: (ldr.item?.boundingRect?.y ?? 0) + (annotation?.offsetY ?? 0)

    implicitWidth: ldr.item?.boundingRect?.width ?? 0
    implicitHeight: ldr.item?.boundingRect?.height ?? 0

    Keys.enabled: root.focus
    Keys.onEscapePressed: {
        Globals.selectedChild = null;
        Globals.selectedChildId = -1;
    }

    on_SelectedChanged: {
        if (_selected) {
            root.forceActiveFocus();
        } else {
            root.focus = false;
        }
    }

    RectangleShape {
        readonly property int _padding: 6

        width: parent.width + (root.annotation?.type == Enums.Tools.Text ? 0 : _padding * 2)
        height: parent.height + _padding * 2

        x: Math.round(parent.width / 2) - Math.round(width / 2)
        y: Math.round(parent.height / 2) - Math.round(height / 2)

        bevel: false
        fillColor: "transparent"
        dashPattern: [6, 8]
        radius: 0
        strokeColor: {
            if (ldr.item?.activeFocus || hoverHandler.hovered && Globals.selectedTool == Enums.Tools.Erase || root._selected) {
                return Config.accent;
            } else if (hoverHandler.hovered && (Globals.selectedTool == Enums.Tools.Select || Globals.selectedTool == Enums.Tools.Text)) {
                return Config.gray;
            } else {
                return "transparent";
            }
        }
        strokeStyle: ShapePath.DashLine
        strokeWidth: 1

        Behavior on strokeColor {
            ColorAnimation {
                duration: 250
            }
        }
    }
    HoverHandler {
        id: hoverHandler
        enabled: Globals.selectedTool == Enums.Tools.Erase || Globals.selectedTool == Enums.Tools.Select || Globals.selectedTool == Enums.Tools.Text && root.annotation.type == Enums.Tools.Text
    }

    Loader {
        id: ldr

        x: -item?.boundingRect?.x
        y: -item?.boundingRect?.y

        // qmlformat off
        sourceComponent: {
            switch (root.annotation?.type) {

            case Enums.Tools.Draw:
                return draw;

            case Enums.Tools.Rectangle:
                return rectangle;

            case Enums.Tools.FilledRectangle:
                return filledRectangle;

            case Enums.Tools.Line:
                return line;

            case Enums.Tools.Arrow:
                return arrow;

            case Enums.Tools.Ellipse:
                return ellipse;

            case Enums.Tools.FilledEllipse:
                return filledEllipse;

            case Enums.Tools.Highlight:
                return highlight;

            case Enums.Tools.Pixelate:
                return pixelate;

            case Enums.Tools.Steps:
                return step;

            case Enums.Tools.Text:
                return textComp;
            }
        }
        // qmlformat on
    }

    Component {
        id: draw
        Shape {
            preferredRendererType: Shape.CurveRenderer
            ShapePath {
                strokeWidth: root.annotation.thickness
                strokeColor: root.annotation.color
                fillColor: "transparent"
                capStyle: ShapePath.RoundCap
                joinStyle: ShapePath.RoundJoin

                PathPolyline {
                    path: root.annotation.points
                }
            }
        }
    }

    Component {
        id: rectangle
        Rectangle {
            readonly property rect boundingRect: Qt.rect(x, y, width, height)

            x: Math.min(root.annotation.endX, root.annotation.startX)
            y: Math.min(root.annotation.endY, root.annotation.startY)
            width: Math.abs(root.annotation.endX - root.annotation.startX)
            height: Math.abs(root.annotation.endY - root.annotation.startY)

            color: "transparent"
            border.width: root.annotation.thickness
            border.color: root.annotation.color
        }
    }

    Component {
        id: filledRectangle
        Rectangle {
            readonly property rect boundingRect: Qt.rect(x, y, width, height)

            x: Math.min(root.annotation.endX, root.annotation.startX)
            y: Math.min(root.annotation.endY, root.annotation.startY)
            width: Math.abs(root.annotation.endX - root.annotation.startX)
            height: Math.abs(root.annotation.endY - root.annotation.startY)

            color: root.annotation.color
        }
    }

    Component {
        id: line
        Shape {
            preferredRendererType: Shape.CurveRenderer
            ShapePath {
                startX: root.annotation.startX
                startY: root.annotation.startY
                strokeWidth: root.annotation.thickness
                strokeColor: root.annotation.color
                fillColor: "transparent"
                capStyle: ShapePath.RoundCap
                PathLine {
                    x: root.annotation.endX
                    y: root.annotation.endY
                }
            }
        }
    }

    // https://stackoverflow.com/questions/808826/drawing-an-arrow-using-html-canvas
    Component {
        id: arrow
        Shape {
            id: arrowShape
            preferredRendererType: Shape.CurveRenderer

            readonly property real _dx: root.annotation.endX - root.annotation.startX
            readonly property real _dy: root.annotation.endY - root.annotation.startY
            readonly property real _angle: Math.atan2(_dy, _dx)
            readonly property real _hypot: Math.hypot(_dy, _dx)
            readonly property real _headLength: Math.min(root.annotation.thickness * 2, _hypot)

            ShapePath {
                strokeColor: root.annotation.color
                strokeWidth: root.annotation.thickness
                fillColor: "transparent"
                capStyle: ShapePath.RoundCap

                startX: root.annotation.startX
                startY: root.annotation.startY
                PathLine {
                    x: (root.annotation.endX) - arrowShape._headLength * Math.cos(arrowShape._angle)
                    y: (root.annotation.endY) - arrowShape._headLength * Math.sin(arrowShape._angle)
                }
            }
            ShapePath {
                id: head
                readonly property real _centerX: root.annotation.endX - arrowShape._headLength * Math.cos(arrowShape._angle)
                readonly property real _centerY: root.annotation.endY - arrowShape._headLength * Math.sin(arrowShape._angle)

                strokeWidth: 0
                fillColor: root.annotation.color

                startX: arrowShape._headLength * Math.cos(arrowShape._angle) + _centerX
                startY: arrowShape._headLength * Math.sin(arrowShape._angle) + _centerY
                PathLine {
                    x: arrowShape._headLength * Math.cos(arrowShape._angle + (1 / 3) * (2 * Math.PI)) + head._centerX
                    y: arrowShape._headLength * Math.sin(arrowShape._angle + (1 / 3) * (2 * Math.PI)) + head._centerY
                }
                PathLine {
                    x: arrowShape._headLength * Math.cos(arrowShape._angle + (2 / 3) * (2 * Math.PI)) + head._centerX
                    y: arrowShape._headLength * Math.sin(arrowShape._angle + (2 / 3) * (2 * Math.PI)) + head._centerY
                }
                PathLine {
                    x: head.startX
                    y: head.startY
                }
            }
        }
    }

    Component {
        id: ellipse
        Shape {
            preferredRendererType: Shape.CurveRenderer
            ShapePath {
                strokeWidth: root.annotation.thickness
                strokeColor: root.annotation.color
                fillColor: "transparent"
                PathAngleArc {
                    centerX: (root.annotation.startX + root.annotation.endX) / 2
                    centerY: (root.annotation.startY + root.annotation.endY) / 2
                    radiusX: Math.abs(root.annotation.endX - root.annotation.startX) / 2
                    radiusY: Math.abs(root.annotation.endY - root.annotation.startY) / 2

                    sweepAngle: 360
                }
            }
        }
    }

    Component {
        id: filledEllipse
        Shape {
            preferredRendererType: Shape.CurveRenderer
            ShapePath {
                strokeWidth: 0
                fillColor: root.annotation.color
                PathAngleArc {
                    centerX: (root.annotation.startX + root.annotation.endX) / 2
                    centerY: (root.annotation.startY + root.annotation.endY) / 2
                    radiusX: Math.abs(root.annotation.endX - root.annotation.startX) / 2
                    radiusY: Math.abs(root.annotation.endY - root.annotation.startY) / 2

                    sweepAngle: 360
                }
            }
        }
    }

    Component {
        id: highlight
        Rectangle {
            readonly property rect boundingRect: Qt.rect(x, y, width, height)

            opacity: 0.4
            x: Math.min(root.annotation.endX, root.annotation.startX)
            y: Math.min(root.annotation.endY, root.annotation.startY)
            width: Math.abs(root.annotation.endX - root.annotation.startX)
            height: Math.abs(root.annotation.endY - root.annotation.startY)

            color: root.annotation.color
        }
    }

    Component {
        id: pixelate
        ShaderEffectSource {
            readonly property rect boundingRect: Qt.rect(x, y, width, height)
            readonly property int _blockSize: 10

            x: Math.min(root.annotation.endX, root.annotation.startX)
            y: Math.min(root.annotation.endY, root.annotation.startY)
            width: Math.abs(root.annotation.endX - root.annotation.startX)
            height: Math.abs(root.annotation.endY - root.annotation.startY)

            sourceItem: root.backdrop
            smooth: false
            textureSize: Qt.size(sourceRect.width / _blockSize, sourceRect.height / _blockSize)
            sourceRect: Qt.rect(root.x, root.y, width, height)
        }
    }

    Component {
        id: step
        Rectangle {
            readonly property rect boundingRect: Qt.rect(x, y, width, height)

            x: root.annotation.startX - width / 2
            y: root.annotation.startY - height / 2
            width: 8 * root.annotation.thickness
            height: 8 * root.annotation.thickness

            radius: 1000
            color: root.annotation.color

            StyledText {
                text: root.annotation.step
                anchors.centerIn: parent
                font.pointSize: 3 * root.annotation.thickness
                color: Lib.isDark(root.annotation.color) ? Config.white : Config.black

                font.features: {
                    "tnum": 1
                }
            }
        }
    }

    Component {
        id: textComp
        StyledTextArea {
            id: textarea
            readonly property rect boundingRect: Qt.rect(x, y, width, height)

            x: root.annotation.startX
            y: root.annotation.startY - implicitHeight / 2

            enabled: root.annotation.state != Enums.States.NotCreated && Globals.selectedTool == Enums.Tools.Text
            text: root.annotation.text
            color: root.annotation.color
            font.pointSize: 3 * root.annotation.thickness
            Component.onCompleted: {
                if (root.isTempObj) {
                    forceActiveFocus();
                }
            }

            Connections {
                target: root.canvas
                function onRequestCommitingTemp() {
                    textarea.editingFinished();
                }
            }
            onEditingFinished: {
                if (root.isTempObj && text == "") {
                    // console.log("hi");
                    canvas.temp = ({});
                    return;
                }
                if (!_modified) {
                    return;
                }
                if (!root.isTempObj) {
                    if (root.annotation.text.length == text.length) {
                        if (root.annotation.text == text)
                            return;
                    }
                    root.canvas.temp = root.annotation;
                    root.canvas.temp.original = false;
                }
                root.canvas.temp.text = text;
                root.canvas.commitTemp();
            }
        }
    }
}
