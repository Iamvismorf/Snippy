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
    property Item backdrop: null

    Repeater {
        model: ScriptModel {
            values: {
                if (Globals.cstep < 0) {
                    return [];
                }

                let erasedIds = new Set();
                let transforms = new Map();

                for (let i = 0; i <= Globals.cstep; i++) {
                    if (Globals.history[i]?.type == Enums.Tools.Erase) {
                        Globals.history[i]?.ids.forEach(id => erasedIds.add(id));
                    } else if (Globals.history[i]?.type == Enums.Tools.Select) {
                        let temp = Globals.history[i];
                        if (!transforms.has(temp.target)) {
                            transforms.set(temp.target, {
                                deltaX: 0,
                                deltaY: 0
                            });
                        }
                        let t = transforms.get(temp.target);
                        t.deltaX += temp.deltaX;
                        t.deltaY += temp.deltaY;
                    }
                }

                let out = [];
                for (let i = 0; i <= Globals.cstep; i++) {
                    let temp = Globals.history[i];
                    if (temp?.type != Enums.Tools.Select && temp?.type != Enums.Tools.Erase && !erasedIds.has(temp?.id)) {
                        let t = transforms.get(temp?.id) || {
                            deltaX: 0,
                            deltaY: 0
                        };
                        out.push(Object.assign({}, temp, {
                            offsetX: t.deltaX,
                            offsetY: t.deltaY
                        }));
                    }
                }
                // return Globals.history.slice(0, Globals.cstep + 1).filter(ann => !erasedIds.has(ann.id));
                return out;
            }
        }
        delegate: AnnotationShape {
            required property var modelData
            annotation: modelData
            backdrop: root.backdrop
        }
    }

    AnnotationShape {
        annotation: root.temp
        backdrop: root.backdrop
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
        if (Globals.history[Globals.cstep]?.id == Globals.selectedChildId) {
            Globals.selectedChildId = -1;
        }

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
