pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

import qs.lib
import qs.toolbar
import "../"

Item {
    id: root
    property var temp: {}
    property var history: []
    property int cstep: -1

    Repeater {
        model: ScriptModel {
            values: root.cstep >= 0 ? root.history.slice(0, root.cstep + 1) : []
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

    function pushToHistory(ann) {
        cstep++;
        if (cstep < history.length) {
            history.length = cstep;
        }

        history.push(ann);
        historyChanged();
    }

    //no need for safe guard because we safe guard by disabling the button
    function undo() { //canvas.qml
        cstep--;
    }
    function redo() { //canvas.qml
        cstep++;
    }
}
