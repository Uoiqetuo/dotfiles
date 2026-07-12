pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Services.SystemTray

import qs.Common
import qs.Components.Common

WrapperRectangle {
    id: root
    color: "#33000000"
    radius: 4
    implicitHeight: 28
    leftMargin: 4
    rightMargin: 4

    required property ShellScreen screen
    property var trayItems: SystemTray.items
    property var currentTrayItem: null

    Row {
        spacing: 4

        Repeater {
            model: root.trayItems
            // model: ScriptModel {
            //     values: root.trayItems.values.filter(item => item.id !== "Fcitx")
            // }
            WrapperMouseArea {
                id: trayItem
                required property SystemTrayItem modelData
                implicitWidth: 20
                implicitHeight: 28

                onClicked: {
                    if (modelData.hasMenu) {
                        root.currentTrayItem = trayItem;
                        trayMenu.visible = true;
                    } else if (!modelData.onlyMenu) {
                        modelData.activate();
                    }
                }
                Loader {
                    active: !!trayItem.modelData?.icon
                    asynchronous: true
                    sourceComponent: Image {
                        source: trayItem.modelData.icon
                        sourceSize.width: 20
                        sourceSize.height: 16
                        fillMode: Image.PreserveAspectFit
                    }
                }
            }
        }

        PopupWindow {
            id: trayMenu
            visible: false
            grabFocus: true

            // 錨定到 trayItem，顯示在下方
            anchor.item: root.currentTrayItem
            anchor.rect.x: (root.currentTrayItem?.width ?? 0) / 2 - width / 2
            anchor.rect.y: root.currentTrayItem?.height ?? 0
            anchor.margins.top: 4

            color: "transparent"
            implicitWidth: menuContainer.width
            implicitHeight: menuContainer.height

            onVisibleChanged: {
                if (!visible) {
                    menuStack.popToIndex(0);
                }
            }

            WrapperRectangle {
                id: menuContainer
                color: "#F5EFEF"
                margin: 4
                radius: 8

                StackView {
                    id: menuStack
                    implicitWidth: currentItem.implicitWidth
                    implicitHeight: currentItem.implicitHeight
                    initialItem: SubMenu {
                        handle: root.currentTrayItem?.modelData?.menu ?? null
                    }

                    pushEnter: NoAnim {}
                    pushExit: NoAnim {}
                    popEnter: NoAnim {}
                    popExit: NoAnim {}
                    replaceEnter: NoAnim {}
                    replaceExit: NoAnim {}
                }
            }
        }
    }

    component NoAnim: Transition {}

    component MenuEntry: WrapperRectangle {
        id: menuEntry

        property QsMenuEntry entryData
        property var showLeftIcon: false
        property var leftIcon: null
        property var showRightIcon: false
        property var onClicked: null

        Layout.fillWidth: true
        radius: 4

        implicitHeight: entryData?.isSeparator ? 1 : 32
        color: entryData?.isSeparator ? "#E0DBDA" : "transparent"

        Loader {
            id: menuLoader
            active: !menuEntry.entryData?.isSeparator
            sourceComponent: WrapperMouseArea {
                id: menuItem
                enabled: menuEntry.entryData?.enabled ?? true

                hoverEnabled: true

                onClicked: {
                    if (menuEntry.onClicked) {
                        menuEntry.onClicked();
                    }
                }
                WrapperRectangle {
                    implicitHeight: menuEntry.implicitHeight
                    color: parent.containsMouse ? "#22000000" : "transparent"
                    radius: 4
                    margin: 4

                    RowLayout {
                        spacing: 4
                        Loader {
                            active: !!menuEntry.showLeftIcon
                            Layout.alignment: Qt.AlignVCenter
                            sourceComponent: WrapperItem {
                                implicitWidth: 16
                                implicitHeight: 16
                                Loader {
                                    active: !!menuEntry.leftIcon || !!menuEntry.entryData?.icon
                                    asynchronous: true
                                    sourceComponent: Image {
                                        source: menuEntry.leftIcon || menuEntry.entryData.icon
                                        sourceSize.width: 16
                                        sourceSize.height: 16
                                        fillMode: Image.PreserveAspectFit
                                    }
                                }
                            }
                        }
                        StyledText {
                            verticalAlignment: Text.AlignVCenter
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            leftPadding: 4
                            text: menuEntry.entryData?.text ?? ""
                            font.pixelSize: FontStyle.content
                            color: menuEntry.entryData?.enabled ? "black" : "#A0A0A0"
                        }
                        Loader {
                            active: menuEntry.showRightIcon && (menuEntry.entryData?.hasChildren ?? false)

                            sourceComponent: WrapperItem {
                                implicitWidth: 16
                                implicitHeight: 16
                                Image {
                                    source: Utils.resolveIconPath("caret-right")
                                    sourceSize.width: 16
                                    sourceSize.height: 16
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: subMenuComp
        SubMenu {}
    }

    component SubMenu: ColumnLayout {
        id: subMenu
        required property QsMenuHandle handle
        property bool isSubMenu: false

        QsMenuOpener {
            id: menuOpener
            menu: subMenu.handle ?? null
        }

        // back button for sub menu
        Loader {
            visible: subMenu.isSubMenu
            active: subMenu.isSubMenu

            Layout.fillWidth: true

            sourceComponent: MenuEntry {
                entryData: subMenu.handle
                showLeftIcon: true
                leftIcon: Utils.resolveIconPath("caret-left")
                onClicked: () => {
                    menuStack.pop();
                }
            }
        }

        Repeater {
            id: menuEntries
            property bool hasIcon: menuOpener.children.values.some(child => child.icon !== "")
            model: menuOpener.children

            delegate: MenuEntry {
                id: menuEntry
                required property QsMenuEntry modelData
                entryData: modelData
                showLeftIcon: menuEntries.hasIcon
                showRightIcon: true
                onClicked: () => {
                    if (menuEntry.entryData.hasChildren) {
                        menuStack.push(subMenuComp.createObject(null, {
                            handle: menuEntry.entryData,
                            isSubMenu: true
                        }));
                    } else {
                        menuEntry.entryData.triggered();
                        trayMenu.visible = false;
                    }
                }
            }
        }
    }
}
