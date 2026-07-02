pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

import qs.lib
import qs.toolbar
import "../"

Item {
    id: root
    property int tempId: 0
    property var temp: {}
    property var history: []
    property int cstep: -1
    onHistoryChanged: console.log(JSON.stringify(history, null, " "))
    // onCstepChanged: console.log("cstep: ", cstep)

    Repeater {
        model: ScriptModel {
            values: {
                if (cstep < 0) {
                    return [];
                }

                let erasedIds = new Set();
                for (let i = 0; i <= cstep; i++) {
                    if (root.history[i]?.type == Enums.Tools.Erase) {
                        root.history[i].ids.forEach(id => erasedIds.add(id));
                    }
                }
                root.history.slice(0, root.cstep + 1).filter(ann => !erasedIds.has(ann.id));
            }
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
    function clearAll() {
        if (cstep < 0 || history[cstep]?.type == Enums.Tools.Erase && history[cstep]?.all)
            return;
        let ids = history.reduce((acc, ann) => {
            if (ann.type != Enums.Tools.Erase) {
                acc.push(ann.id);
            }
            return acc;
        }, []);

        pushToHistory({
            type: Enums.Tools.Erase,
            ids: ids,
            all: true
        });
    }
}
