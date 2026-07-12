import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.Common
import qs.Services

WrapperRectangle {
    id: root
    color: "#22000000"
    radius: 4
    implicitHeight: 28
    implicitWidth: 28

    WrapperMouseArea {
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        implicitWidth: root.implicitWidth
        implicitHeight: root.implicitHeight

        onClicked: mouse => {
            if (mouse.button === Qt.LeftButton) {
                Quickshell.execDetached(["qs", "ipc", "call", "side_panel", "setPage", "network"]);
                Quickshell.execDetached(["qs", "ipc", "call", "side_panel", "visible", "true"]);
            }
        }

        WrapperItem {
            margin: 4
            IconImage {
                source: Utils.resolveIconPath(NetworkService.getNetworkIcon())
                implicitSize: 20
            }
        }
    }
}
