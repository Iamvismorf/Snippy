pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

import qs.lib
import qs.toolbar
import "../"

Item {
    id: root
    property var temp: {}

    Repeater {
        model: ScriptModel {
            values: Globals.cstep >= 0 ? Globals.history.slice(0, Globals.cstep + 1) : []
        }
        delegate: AnnotationShape {
            required property var modelData
            annotation: modelData
        }
    }

    AnnotationShape {
        annotation: root.temp
        visible: !Lib.isEmpty(root.temp)
    }
}
