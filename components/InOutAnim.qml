import QtQuick

NumberAnimation {
    duration: 250
    easing.type: Easing.BezierSpline
    easing.bezierCurve: [0.45, 0, 0.55, 1, 1, 1]
}
