import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

import "./Pages"

PanelWindow {
    id: side_panel
    anchors {
        top: true
        right: true
        bottom: true
        left: true
    }
    color: "transparent"
    implicitWidth: 400

    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "qs-side-panel"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    visible: false
    property string page: "network"

    onPageChanged: updatePageStatus()
    onVisibleChanged: updatePageStatus()
    Component.onCompleted: updatePageStatus()

    function updatePageStatus() {
        pageLazyLoader.active = false;
        if (!side_panel.visible)
            return;

        switch (side_panel.page) {
        case "network":
            pageLazyLoader.component = networkPageComp;
            pageLazyLoader.active = true;
            break;
        case "audio":
            pageLazyLoader.component = audioPageComp;
            pageLazyLoader.active = true;
            break;
        default:
            console.warn(`Unknown page: ${side_panel.page}`);
        }
    }

    // close panel when clicking outside of the page
    MouseArea {
        anchors.fill: parent

        focus: true
        onClicked: {
            side_panel.visible = false;
        }
        Keys.onEscapePressed: event => {
            side_panel.visible = false;
            event.accepted = true;
        }

        // Lazy-load page into a container so the loaded item can be anchored
        Item {
            id: pageContainer

            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right

            anchors.topMargin: 46
            anchors.bottomMargin: 16
            anchors.rightMargin: 16

            implicitWidth: 400

            MouseArea {
                anchors.fill: parent
                onClicked: mouse => {
                    mouse.accepted = true; // prevent clicks from propagating to the background
                }
            }

            Component {
                id: networkPageComp
                NetworkPage {}
            }
            Component {
                id: audioPageComp
                AudioPage {}
            }

            LazyLoader {
                id: pageLazyLoader
                loading: side_panel.visible
                activeAsync: true

                onActiveChanged: {
                    if (active && item) {
                        // parent must be set on the loaded item
                        item.parent = pageContainer;
                    }
                }
            }
        }
    }

    IpcHandler {
        target: "side_panel"

        function visible(v: string) {
            switch (v) {
            case "true":
                side_panel.visible = true;
                break;
            case "false":
                side_panel.visible = false;
                break;
            case "toggle":
                side_panel.visible = !side_panel.visible;
                break;
            default:
                console.warn(`Unknown visibility command: ${v}`);
            }
        }

        function setPage(page: string) {
            side_panel.page = page;
        }
    }
}
