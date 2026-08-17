// I don't like this singleton at all, but I don't like passing around toolbar and canvas either, so ig we are stuck with this one
pragma Singleton

import Quickshell
import QtQuick
import qs.toolbar

Singleton {
    property color selectedColor
    property int/* Toolbar.ToolTypes */ selectedTool: Enums.Tools.None

    property int cstep: -1
    property var history: []
    property var consumedHistory: {
        if (cstep < 0) {
            return [];
        }

        let erasedIds = new Set();
        let transforms = new Map();
        let textContents = new Map();

        for (let i = 0; i <= cstep; i++) {
            const entry = history[i];
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
                for (let i = 0; i <= cstep; i++) {
                    let entry = history[i];

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
    property int selectedThickness
    property var selectedChild
    property int selectedChildId: -1 // needed to survive repeater's rebuilding
    property int step: 1

    onSelectedToolChanged: {
        selectedChild = null;
        selectedChildId = -1;
        step = 1;
    }

    onStepChanged: console.log(step)
    // onCstepChanged: console.log(cstep)
    // onSelectedToolChanged: console.log(Qt.enumValueToStrings(Enums.Tools, selectedTool))

    // onHistoryChanged: console.log(JSON.stringify(history, null, " "))
    // onSelectedChildChanged: console.log(selectedChild)
    // onSelectedThicknessChanged: console.log(selectedThickness)
}
