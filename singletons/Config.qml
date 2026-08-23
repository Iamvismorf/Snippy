pragma Singleton

import Quickshell
import QtQuick
import Quickshell.Io
import Snippy as Snippy

Singleton {
    FileView {
        id: fileview
        path: Snippy.Filesystem.getConfigFile()

        JsonAdapter {
            id: config
            property JsonObject general: JsonObject {
                property string fontFamily: "Atkinson Hyperlegible Next"
                property string fontFamilyStyle: "SemiBold"
                property bool showToolTip: false
                property int minSelectionRectangleWidth: 20
                property int minSelectionRectangleHeight: 20
                property string saveFolder: "Screenshots"
            }
            property JsonObject theming: JsonObject {
                property color white: "#EEF2F6"
                property color black: "#121A21"
                property color accent: "#ED5A70"
                property color gray: "#C0C2C4"
                property color lightGray: "#D6D9DB"
                property color red: "#ED5A70"
            }
            property JsonObject toolbar: JsonObject {
                property JsonObject rectangle: JsonObject {
                    property bool defaultToFilled: true
                }
                property JsonObject ellipse: JsonObject {
                    property bool defaultToFilled: true
                }
                property JsonObject highlight: JsonObject {
                    property bool defaultToRectangle: true
                }
            }
        }

        onLoaded: Snippy.Filesystem.createSaveDir(config.general.saveFolder)
        onLoadFailed: e => {
            if (e == FileViewError.FileNotFound) {
                writeAdapter();
                Snippy.Filesystem.createSaveDir(config.general.saveFolder);
            } else {
                console.log(FileViewError.toString(e));
            }
        }
    }

    readonly property string fontFamily: config.general.fontFamily
    readonly property string fontFamilyStyle: config.general.fontFamilyStyle
    readonly property bool showToolTip: config.general.showToolTip
    readonly property int minSelectionWidth: config.general.minSelectionRectangleWidth
    readonly property int minSelectionHeight: config.general.minSelectionRectangleHeight

    //theming in config
    readonly property color white: config.theming.white
    readonly property color black: config.theming.black
    readonly property color accent: config.theming.accent
    readonly property color gray: config.theming.gray
    readonly property color lightGray: config.theming.lightGray
    readonly property color red: config.theming.red

    readonly property bool ellipseDefaultToFilled: config.toolbar.ellipse.defaultToFilled
    readonly property bool highlightDefaultToRectangle: config.toolbar.highlight.defaultToRectangle
    readonly property bool rectangleDefaultToFilled: config.toolbar.rectangle.defaultToFilled

    readonly property color dimColor: "black"

    readonly property int _popupPadding: 6
    readonly property int horizontalPading: _popupPadding * 6 // right + left
    readonly property int verticalPadding: _popupPadding * 2 // top + bottom

    readonly property int toolbarIconSize: 20

    readonly property color toolbarPalette1: "#F44236"
    readonly property color toolbarPalette2: "#FF9700"
    readonly property color toolbarPalette3: "#FEC107"
    readonly property color toolbarPalette4: "#4CB050"
    readonly property color toolbarPalette5: "#2196F3"
    readonly property color toolbarPalette6: "#3F51B5"
    readonly property color toolbarPalette7: "#F5F5F5"
    readonly property color toolbarPalette8: "#000000"

    //todo: make this float?
    readonly property int normalThickness: 4
    readonly property int mediumThickness: 6
    readonly property int largeThickness: 8
}
