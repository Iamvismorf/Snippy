pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

import qs.lib
import qs.toolbar
import qs.singletons

Item {
    id: root
    property int tempId: 0
    property var temp: ({})
    // onTempChanged: console.log(JSON.stringify(temp, null, " "))
    property Item backdrop: null

    signal requestCommitingTemp

    Repeater {
        model: ScriptModel {
            values: Globals.consumedHistory
        }
        delegate: AnnotationShape {
            required property var modelData

            annotation: modelData
            backdrop: root.backdrop
            canvas: root
        }
    }

    AnnotationShape {
        // annotation: root.temp
        isTempObj: true
        Binding on annotation {
            value: root.temp
        }
        backdrop: root.backdrop
        canvas: root
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
    function undo() {
        if (Globals.history[Globals.cstep]?.id == Globals.selectedChildId) {
            Globals.selectedChildId = -1;
        }

        Globals.cstep--;
    }
    function redo() {
        Globals.cstep++;
    }
    function clearAll() {
        let ids = Globals.history.reduce((acc, ann) => {
            if (ann.id !== undefined && ann.original != false) { // only shapes have id, actions like erase or select don't
                acc.push(ann.id);
            }
            return acc;
        }, []);

        pushToHistory({
            type: Enums.Tools.Erase,
            ids: ids
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
