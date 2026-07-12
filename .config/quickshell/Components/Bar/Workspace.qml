import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import Quickshell.Widgets
import qs.Common
import qs.Components.Common

WrapperRectangle {
    id: root
    color: "#22000000"
    radius: 4
    implicitHeight: 28
    margin: 4

    RowLayout {
        spacing: 4

        Component {
            id: workspaceItem

            WrapperMouseArea {
                id: workspace
                required property var modelData
                acceptedButtons: Qt.LeftButton
                implicitWidth: workspaceContent.implicitWidth
                implicitHeight: workspaceContent.implicitHeight

                function isSpecial() {
                    return modelData.name.startsWith("special");
                }

                onClicked: {
                    workspace.isSpecial() ? Hyprland.dispatch("hl.dsp.workspace.toggle_special('magic')") : workspace.modelData.activate();
                }

                Item {
                    id: workspaceContent
                    implicitWidth: 20
                    implicitHeight: 20

                    Rectangle {
                        anchors.fill: parent
                        color: workspace.modelData.focused ? "#33FFFFFF" : "#33000000"
                        radius: 4
                    }

                    StyledText {
                        text: {
                            workspace.isSpecial() ? "S" : workspace.modelData.name;
                        }
                        anchors.centerIn: parent
                        color: "white"
                        font.pixelSize: FontStyle.content
                    }
                }
            }
        }

        // normal workspaces
        Repeater {
            model: Hyprland.workspaces.values.filter(w => !w.name.startsWith("special"))
            delegate: workspaceItem
        }

        // special workspaces
        Repeater {
            model: Hyprland.workspaces.values.filter(w => w.name.startsWith("special"))
            delegate: workspaceItem
        }
    }
}
