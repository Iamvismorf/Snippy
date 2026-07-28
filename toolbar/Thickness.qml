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

        property Item _selectedThickness
        anchors.verticalCenter: parent.verticalCenter
        on_SelectedThicknessChanged: Globals.selectedThickness = _selectedThickness.modelData

        Repeater {
            id: rep
            model: [Config.normalThickness, Config.mediumThickness, Config.largeThickness]

            StyledRectangle {
                required property int modelData
                required property int index

                width: Config.toolbarIconSize
                height: width

                animatedColor: true
                color: mouseArea.containsMouse ? Config.lightGray : Qt.rgba(1, 1, 1, 0)
                radius: 4

                StyledRectangle {
                    width: Math.min(Config.toolbarIconSize, modelData / rep.model[rep.model.length - 1] * 16)
                    height: width
                    anchors.centerIn: parent

                    animatedColor: true
                    radius: 100
                    color: root._selectedThickness == parent ? Config.accent : Config.black
                }
                MouseArea {
                    id: mouseArea
                    anchors.fill: parent

                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: root._selectedThickness = parent
                }
            }
            //todo: add spinbox for custom
            Component.onCompleted: root._selectedThickness = itemAt(0)
        }
    }

    Snippy.SvgIcon {
        // KirigamiIcon {
        id: arrow
        source: Quickshell.iconPath(Quickshell.shellPath(`assets/triangle.svg`))

        x: root._selectedThickness?.mapToItem(wrapper, 0, 0).x + (root._selectedThickness?.width - implicitWidth) / 2
        y: root.y - implicitHeight

        implicitWidth: 10
        implicitHeight: implicitWidth
        color: Config.accent

        Behavior on x {
            DeccelAnim {}
        }
    }
}
