import QtQuick
import QtQuick.Shapes
import "../"

Item {
    id: root
    property var annotation

    implicitWidth: ldr.implicitWidth
    implicitHeight: ldr.implicitHeight

    Loader {
        id: ldr
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
            x: Math.min(root.annotation.x, root.annotation.startX)
            y: Math.min(root.annotation.y, root.annotation.startY)
            width: Math.abs(root.annotation.x - root.annotation.startX)
            height: Math.abs(root.annotation.y - root.annotation.startY)

            color: "transparent"
            border.width: root.annotation.thickness
            border.color: root.annotation.color
        }
    }

    Component {
        id: filledRectangle
        Rectangle {
            x: Math.min(root.annotation.x, root.annotation.startX)
            y: Math.min(root.annotation.y, root.annotation.startY)
            width: Math.abs(root.annotation.x - root.annotation.startX)
            height: Math.abs(root.annotation.y - root.annotation.startY)

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
                    x: root.annotation.x
                    y: root.annotation.y
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

            readonly property real _dx: root.annotation.x - root.annotation.startX
            readonly property real _dy: root.annotation.y - root.annotation.startY
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
                    x: (root.annotation.x) - arrowShape._headLength * Math.cos(arrowShape._angle)
                    y: (root.annotation.y) - arrowShape._headLength * Math.sin(arrowShape._angle)
                }
            }
            ShapePath {
                id: head
                readonly property real _centerX: root.annotation.x - arrowShape._headLength * Math.cos(arrowShape._angle)
                readonly property real _centerY: root.annotation.y - arrowShape._headLength * Math.sin(arrowShape._angle)

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
                    centerX: (root.annotation.startX + root.annotation.x) / 2
                    centerY: (root.annotation.startY + root.annotation.y) / 2
                    radiusX: Math.abs(root.annotation.x - root.annotation.startX) / 2
                    radiusY: Math.abs(root.annotation.y - root.annotation.startY) / 2

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
                    centerX: (root.annotation.startX + root.annotation.x) / 2
                    centerY: (root.annotation.startY + root.annotation.y) / 2
                    radiusX: Math.abs(root.annotation.x - root.annotation.startX) / 2
                    radiusY: Math.abs(root.annotation.y - root.annotation.startY) / 2

                    sweepAngle: 360
                }
            }
        }
    }

    Component {
        id: highlight
        Rectangle {
            opacity: 0.4
            x: Math.min(root.annotation.x, root.annotation.startX)
            y: Math.min(root.annotation.y, root.annotation.startY)
            width: Math.abs(root.annotation.x - root.annotation.startX)
            height: Math.abs(root.annotation.y - root.annotation.startY)

            color: root.annotation.color
        }
    }
}
