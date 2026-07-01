pragma Singleton

import Quickshell
import QtQuick

Singleton {
    enum Actions {
        Undo,
        Redo,
        Clear,
        Copy,
        Save,
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
        Highlight,
        Steps,
        Blur,
        Text
    }
}
