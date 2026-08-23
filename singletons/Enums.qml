pragma Singleton

import Quickshell
import QtQuick

Singleton {
    enum Actions {
        Undo,//ctrl z
        Redo,//ctrl y
        Clear,//ctrl q?
        Copy,//ctrl c
        Save,//ctrl s
        Abort
    }
    enum Tools {
        None,
        Select,
        Draw,
        Erase,
        Rectangle,
        FilledRectangle,
        Line,
        Arrow,
        Ellipse,
        FilledEllipse,
        HighlightRectangle,
        HighlightDraw,
        Steps,
        Pixelate,
        Text
    }
    enum States {
        NotCreated,
        Creating,
        Created
    }

    QtObject {
        id: internal
        property var toolsToString: ["None", "Selector", "Freehand", "Eraser", "Rectangle", "Filled Rectangle", "Line", "Arrow", "Ellipse", "Filled Ellipse", "Highlight Rectangle", "Highlight Freehand", "Number", "Pixelate", "Text"]
    }

    // qmlformat off
    function actionsToString(val)    { return Qt.enumValueToString(Enums.Actions, val)}
    function toolsToString(val)  { return internal.toolsToString[val]  ?? "Unknown" }
    // qmlformat on
}
