pragma Singleton

import Quickshell
import QtQuick
import qs.toolbar

Singleton {
    // property color selectedColor // toolbar.qml
    // property int/* Toolbar.ToolTypes */ selectedTool: Enums.Tools.None //toolbar.qml

    // property int cstep: -1 //canvas.qml
    // property var history: [] //canvas.qml
    property int thickness: 4 //todo: make available in toolbar.qml

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

    // onHistoryChanged: console.log(JSON.stringify(history))
}
