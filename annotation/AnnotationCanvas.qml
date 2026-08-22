pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

import qs.lib
import qs.toolbar
import qs.singletons

Item {
    id: root
    readonly property bool canUndo: Globals.cstep > -1
    readonly property bool canRedo: Globals.cstep != Globals.history.length - 1
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

    function undo() {
        // qmlformat off
        if (!canUndo) return;
        if (Globals.history[Globals.cstep]?.id == Globals.selectedChildId) {
            Globals.selectedChildId = -1;
        }

        Globals.cstep--;
    }
    function redo() {
        if (!canRedo) return;
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
