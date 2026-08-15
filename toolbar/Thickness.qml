import QtQuick
import Quickshell
import qs.components
import qs.singletons

import "./icon"

RowGroup {
    spacing: 16
    Item {
        id: wrapper

        implicitWidth: root.implicitWidth
        implicitHeight: root.implicitHeight + arrow.implicitHeight
        RowGroup {
            id: root
            spacing: 8

            property Item _selectedThickness
            anchors.verticalCenter: parent.verticalCenter
            on_SelectedThicknessChanged: Globals.selectedThickness = _selectedThickness._copiedModelData
            Connections {
                target: root._selectedThickness
                function on_CopiedModelDataChanged() {
                    Globals.selectedThickness = root._selectedThickness._copiedModelData;
                }
            }

            Repeater {
                id: rep
                model: [Config.normalThickness, Config.mediumThickness, Config.largeThickness]

                StyledRectangle {
                    required property int modelData
                    required property int index

                    property int _copiedModelData: modelData

                    width: Config.toolbarIconSize
                    height: width

                    animatedColor: true
                    color: mouseArea.containsMouse ? Config.lightGray : Qt.rgba(1, 1, 1, 0)
                    radius: 4

                    StyledRectangle {
                        animatedSize: true
                        //todo: this is dumb
                        width: Math.min(Config.toolbarIconSize, _copiedModelData / rep.model[rep.model.length - 1] * 16)
                        height: width
                        anchors.centerIn: parent

                        animatedColor: true
                        radius: 100
                        color: root._selectedThickness == parent ? Config.accent : Config.black
                    }
                    StyledMouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        onClicked: root._selectedThickness = parent
                    }
                }
                Component.onCompleted: root._selectedThickness = itemAt(1)
            }
        }

        KirigamiIcon {
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
    Icon {
        id: icon
        source: Quickshell.iconPath(Quickshell.shellPath(`assets/reloadv2.svg`))
        size: Config.toolbarIconSize * 0.75
        icon.color: Config.accent
        color: mouseArea.containsMouse ? Config.lightGray : Qt.rgba(1, 1, 1, 0)
        mouseArea.cursorShape: Qt.PointingHandCursor
        mouseArea.onClicked: {
            reloadAnim.running = true;
            root._selectedThickness._copiedModelData = root._selectedThickness.modelData;
        }
        NumberAnimation {
            id: reloadAnim

            target: icon.icon
            property: "rotation"
            alwaysRunToEnd: true
            to: 360
            duration: 600

            easing.type: Easing.BezierSpline
            easing.bezierCurve: [0.33, 1, 0.68, 1, 1, 1]

            onFinished: icon.icon.rotation = 0
        }
    }
    CustomSpinBox {
        id: spinbox

        from: Config.normalThickness
        to: Config.largeThickness
        value: root._selectedThickness._copiedModelData
        onValueChanged: {
            if (root._selectedThickness) {
                root._selectedThickness._copiedModelData = value;
            }
        }
        textFromValue: function (v, l) {
            return Number(v - from + 1).toLocaleString(l, 'f', 0);
        }
        valueFromText: function (t, l) {
            return Number.fromLocaleString(l, t) + from - 1;
        }
    }
}
