pragma Singleton

import Quickshell
import QtQuick

Singleton {
    readonly property color white: "#EEF2F6"
    readonly property color black: "#121A21"
    readonly property color accent: "#ED5A70"
    readonly property color gray: "#C0C2C4"
    readonly property color lightGray: "#DEE1E3" // todo: prob need to go darker

    readonly property color dimColor: "black"

    readonly property int minSelectionWidth: 20
    readonly property int minSelectionHeight: 20

    readonly property string saveFolder: "~/Screenshots"
    readonly property int _popupPadding: 6
    readonly property int horizontalPading: _popupPadding * 6 // right + left
    readonly property int verticalPadding: _popupPadding * 2 // top + bottom

    readonly property color red: "#ED5A70"

    readonly property int toolbarIconSize: 20
    readonly property color toolbarPalette1: "#F44236"
    readonly property color toolbarPalette2: "#FF9700"
    readonly property color toolbarPalette3: "#FEC107"
    readonly property color toolbarPalette4: "#4CB050"
    readonly property color toolbarPalette5: "#2196F3"
    readonly property color toolbarPalette6: "#3F51B5"
    readonly property color toolbarPalette7: "#F5F5F5"
    readonly property color toolbarPalette8: "#000000"

    readonly property string fontFamily: "Atkinson Hyperlegible Next"
    readonly property string fontFamilyStyle: "SemiBold"
}
