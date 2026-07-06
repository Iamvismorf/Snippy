pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

import qs.lib
import qs.toolbar
import "../"

Item {
    id: root
    property int tempId: 0
    property var temp: ({})

    Repeater {
        model: ScriptModel {
            values: {
                if (Globals.cstep < 0) {
                    return [];
                }

                let erasedIds = new Set();
                for (let i = 0; i <= Globals.cstep; i++) {
                    if (Globals.history[i]?.type == Enums.Tools.Erase) {
                        Globals.history[i]?.ids.forEach(id => erasedIds.add(id));
                    }
                }
                Globals.history.slice(0, Globals.cstep + 1).filter(ann => !erasedIds.has(ann.id));
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
        Globals.cstep++;
        if (Globals.cstep < Globals.history.length) {
            Globals.history.length = Globals.cstep;
        }

        Globals.history.push(ann);
        Globals.historyChanged();
    }

    //no need for safe guard because we safe guard by disabling the button
    function undo() { //canvas.qml
        Globals.cstep--;
    }
    function redo() { //canvas.qml
        Globals.cstep++;
    }
    function clearAll() {
        if (Globals.cstep < 0 || Globals.history[Globals.cstep]?.type == Enums.Tools.Erase && Globals.history[Globals.cstep]?.all)
            return;
        let ids = Globals.history.reduce((acc, ann) => {
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
    function commitTemp() {
        if (!Lib.isEmpty(temp)) {
            pushToHistory(temp);
            temp = ({});
            tempId++;
        }
    }
}
