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
    property int selectedThickness
    property var selectedChild
    property int selectedChildId: -1 // needed to survive repeater's rebuilding
    property int step: 1

    onSelectedToolChanged: {
        selectedChild = null;
        selectedChildId = -1;
        step = 1;
    }

    // function pushToHistory(ann) { // canvas.qml
    //     cstep++;
    //     if (cstep < history.length) {
    //         history.length = cstep;
    //     }
    //
    //     history.push(ann);
    //     historyChanged();
    // }

    // //no need for safe guard because we safe guard by disabling the button
    // function undo() { //canvas.qml
    //     cstep--;
    // }
    // function redo() { //canvas.qml
    //     cstep++;
    // }

    // onCstepChanged: console.log(cstep)
    // onSelectedToolChanged: console.log(Qt.enumValueToStrings(Enums.Tools, selectedTool))

    // onHistoryChanged: console.log(JSON.stringify(history, null, " "))
    // onSelectedChildChanged: console.log(selectedChild)
}
