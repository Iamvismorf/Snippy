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
    // onTempChanged: console.log(JSON.stringify(temp, null, " "))
    property Item backdrop: null

    signal requestCommitingTemp

    Repeater {
        model: ScriptModel {
            values: {
                if (Globals.cstep < 0) {
                    return [];
                }

                let erasedIds = new Set();
                let transforms = new Map();
                let textContents = new Map();

                for (let i = 0; i <= Globals.cstep; i++) {
                    const entry = Globals.history[i];
                    if (entry?.type == Enums.Tools.Erase) {
                        entry?.ids.forEach(id => erasedIds.add(id));
                    } else if (entry?.type == Enums.Tools.Select) {
                        if (!transforms.has(entry.target)) {
                            transforms.set(entry.target, {
                                deltaX: 0,
                                deltaY: 0
                            });
                        }
                        let t = transforms.get(entry.target);
                        t.deltaX += entry.deltaX;
                        t.deltaY += entry.deltaY;
                    } else if (entry?.type == Enums.Tools.Text) {
                        textContents.set(entry.id, entry.text);
                    }
                }

                let out = [];
                // qmlformat off
                for (let i = 0; i <= Globals.cstep; i++) {
                    let entry = Globals.history[i];

                    if (!entry) continue;
                    if (entry.type == Enums.Tools.Select || entry.type == Enums.Tools.Erase || entry.type == Enums.Tools.Text && !entry?.original) continue;
                    if (textContents.get(entry.id) == "") continue; //don't display empty textarea in the scene
                    if (erasedIds.has(entry.id)) continue;

                    let t = transforms.get(entry.id) || { deltaX: 0, deltaY: 0 };
                    let extra = { offsetX: t.deltaX, offsetY: t.deltaY };
                    if (entry.type == Enums.Tools.Text) extra.text = textContents.get(entry.id);

                    out.push(Object.assign({}, entry, extra));
                }
                // qmlformat on

                // return Globals.history.slice(0, Globals.cstep + 1).filter(ann => !erasedIds.has(ann.id));
                // console.log(JSON.stringify(out, null, " "));
                return out;
            }
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
        if (Globals.cstep < 0 || Globals.history[Globals.cstep]?.type == Enums.Tools.Erase && Globals.history[Globals.cstep]?.all)
            return;
        let ids = Globals.history.reduce((acc, ann) => {
            if (ann.id !== undefined && ann.original != false) { // only shapes have id, actions like erase or select don't
                acc.push(ann.id);
            }
            return acc;
        }, []);

        pushToHistory({
            type: Enums.Tools.Erase,
            ids: ids,
            all: true // to guard against pushing 2 consecutive clearall
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
