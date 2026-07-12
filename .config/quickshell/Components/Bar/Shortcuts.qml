import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

WrapperRectangle {
    id: root
    color: "#33000000"
    radius: 4
    implicitHeight: 28
    margin: 2

    property bool entriesLoaded: false
    property var shortcuts: []

    function loadShortcuts() {
        if (DesktopEntries.applications.values.length === 0) {
            return;
        }

        root.entriesLoaded = true;
        root.shortcuts = [
            {
                app: DesktopEntries.byId("kitty"),
                icon: "terminal"
            },
            {
                app: DesktopEntries.byId("google-chrome"),
                actions: {
                    onSecondaryClick: () => {
                        const app = DesktopEntries.byId("google-chrome");
                        app.actions.filter(action => action.id === "new-private-window")[0]?.execute();
                    }
                }
            },
            {
                app: DesktopEntries.byId("org.gnome.Nautilus")
            },
        ];
    }

    Component.onCompleted: loadShortcuts()

    Connections {
        target: DesktopEntries
        function onApplicationsChanged() {
            loadShortcuts();
        }
    }

    RowLayout {
        spacing: 2
        visible: root.entriesLoaded

        Repeater {
            model: root.shortcuts

            WrapperMouseArea {
                id: shortcutItem
                required property var modelData

                acceptedButtons: Qt.LeftButton | Qt.RightButton
                implicitWidth: shortcutContent.implicitWidth
                implicitHeight: shortcutContent.implicitHeight

                onClicked: mouse => {
                    if (modelData.app) {
                        if (mouse.button === Qt.LeftButton) {
                            modelData.actions?.onPrimaryClick ? modelData.actions?.onPrimaryClick() : modelData.app.execute();
                        }
                        if (mouse.button === Qt.RightButton) {
                            modelData.actions?.onSecondaryClick && modelData.actions?.onSecondaryClick();
                        }
                    }
                }

                Item {
                    id: shortcutContent
                    implicitWidth: 24
                    implicitHeight: 24

                    IconImage {
                        anchors.centerIn: parent
                        implicitSize: 24
                        source: Quickshell.iconPath(shortcutItem.modelData.icon || shortcutItem.modelData.app?.icon || "application-x-executable")
                    }
                }
            }
        }
    }
}
