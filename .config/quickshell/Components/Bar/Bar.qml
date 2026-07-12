import Quickshell
import QtQuick

PanelWindow {
    id: root
    anchors {
        top: true
        left: true
        right: true
    }
    margins {
        top: 8
        bottom: 8
        left: 8
        right: 8
    }
    color: "transparent"
    implicitHeight: 28
    // exclusionMode: ExclusionMode.Ignore

    required property var modelData
    screen: modelData

    // left
    Row {
        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
        }
        spacing: 8

        Workspace {}
        Shortcuts {}
    }

    // center
    // Row {
    //     anchors.centerIn: parent
    //     spacing: 8
    // }

    // right
    Row {
        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
        spacing: 8

        Tray {
            screen: root.screen
        }
        Audio {}
        Network {}
        Clock {}
    }
}
