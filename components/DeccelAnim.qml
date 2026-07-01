import QtQuick

NumberAnimation {
    duration: 250
    easing.type: Easing.BezierSpline
    // easing.bezierCurve: [0, 0.55, 0.45, 1, 1, 1]
    easing.bezierCurve: [0, 0.332, 0, 1, 1, 1]
}
