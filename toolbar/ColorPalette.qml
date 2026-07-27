import QtQuick
import Quickshell
import qs.components
import Snippy as Snippy

import "../"

Item {
    id: wrapper

    implicitWidth: root.implicitWidth
    implicitHeight: root.implicitHeight + arrow.implicitHeight

    RowGroup {
        id: root

        property Rectangle _selectedColor
        anchors.verticalCenter: parent.verticalCenter

        on_SelectedColorChanged: Globals.selectedColor = _selectedColor.color

        Repeater {
            model: [Config.toolbarPalette1, Config.toolbarPalette2, Config.toolbarPalette3, Config.toolbarPalette4, Config.toolbarPalette5, Config.toolbarPalette6, Config.toolbarPalette7, Config.toolbarPalette8]

            StyledRectangle {
                required property color modelData

                width: Config.toolbarIconSize
                height: width

                animatedColor: true
                radius: 100
                color: root._selectedColor == this ? "transparent" : modelData

                border.width: root._selectedColor == this ? 2 : 1
                // border.width: 1
                border.color: root._selectedColor == this ? Qt.lighter(Config.accent, 1.25) : Qt.darker(modelData, 1.5)

                MouseArea {
                    anchors.fill: parent

                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: root._selectedColor = parent
                }

                StyledRectangle {
                    width: parent.width - parent.border.width * 2 - 2 * 2 // padding 2
                    height: width

                    anchors.centerIn: parent

                    animatedSize: true
                    animatedColor: true

                    color: modelData
                    radius: 100
                }
            }
            Component.onCompleted: root._selectedColor = itemAt(1)
        }
    }
    Snippy.SvgIcon {
        id: arrow
        source: Quickshell.iconPath(Quickshell.shellPath(`assets/triangle.svg`))

        x: root._selectedColor?.mapToItem(wrapper, 0, 0).x + (root._selectedColor?.width - implicitWidth) / 2
        y: root.y - implicitHeight

        implicitWidth: 10
        implicitHeight: implicitWidth
        color: Config.accent

        Behavior on x {
            DeccelAnim {}
        }
    }
}
