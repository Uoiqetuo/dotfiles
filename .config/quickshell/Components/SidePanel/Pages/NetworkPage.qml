import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Widgets
import Quickshell.Networking as QsNetworking

import qs.Common
import qs.Components.Common
import qs.Services

Rectangle {
    id: root
    anchors.fill: parent
    color: "#F5EFEF"
    radius: 8

    Flickable {
        anchors.fill: parent
        anchors.margins: 8
        contentHeight: column.height
        clip: true

        boundsBehavior: Flickable.StopAtBounds
        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
        }

        Column {
            id: column
            width: parent.width
            spacing: 16

            // Topbar
            WrapperRectangle {
                width: parent.width
                color: "#F2E3E6"
                radius: 8
                topMargin: 8
                bottomMargin: 8
                leftMargin: 16
                rightMargin: 16

                RowLayout {
                    StyledText {
                        Layout.fillWidth: true
                        text: "Wi-Fi"
                        font.pixelSize: FontStyle.h3
                        font.weight: Font.Medium
                        color: "#EE455F"
                    }

                    WrapperMouseArea {
                        visible: NetworkService.wifiEnabled
                        margin: 4
                        onClicked: {
                            NetworkService.primaryWifiDevice.scannerEnabled = !NetworkService.primaryWifiDevice.scannerEnabled;
                        }
                        IconImage {
                            source: Utils.resolveIconPath("arrow-clockwise")
                            implicitSize: 20

                            transformOrigin: Item.Center

                            RotationAnimator on rotation {
                                from: 0
                                to: 360
                                duration: 1000
                                loops: Animation.Infinite
                                running: NetworkService.primaryWifiDevice?.scannerEnabled || false
                            }
                        }
                    }

                    Switch {
                        id: wifiSwitch
                        checked: NetworkService.wifiEnabled
                        onToggled: {
                            NetworkService.toggleWifi();
                        }
                    }
                }
            }

            // AvailableNetworks
            WrapperRectangle {
                visible: NetworkService.wifiEnabled && NetworkService.primaryWifiDevice !== null
                width: parent.width
                color: "#FCFCFC"
                radius: 8

                ColumnLayout {
                    spacing: 0

                    Repeater {
                        model: NetworkService.primaryWifiDevice?.networks || []
                        delegate: WrapperMouseArea {
                            id: wifiItem
                            Layout.fillWidth: true
                            required property QsNetworking.WifiNetwork modelData
                            property bool showPasswordField: false

                            function connectWithPassword(password) {
                                modelData.connectWithPsk(password);
                                showPasswordField = false;
                            }

                            onClicked: {
                                if (modelData.state === QsNetworking.ConnectionState.Connecting)
                                    return;
                                if (modelData.connected) {
                                    modelData.disconnect();
                                    return;
                                }
                                if (modelData.known) {
                                    modelData.connect();
                                } else {
                                    if ([QsNetworking.WifiSecurityType.WpaPsk, QsNetworking.WifiSecurityType.Wpa2Psk, QsNetworking.WifiSecurityType.Sae].includes(modelData.security)) {
                                        wifiItem.showPasswordField = !wifiItem.showPasswordField;
                                    } else {
                                        modelData.connect();
                                    }
                                }
                            }

                            Connections {
                                target: wifiItem.modelData
                                function onConnectionFailed(reason) {
                                    if (reason === QsNetworking.ConnectionFailReason.NoSecrets) {
                                        wifiItem.modelData.forget();
                                        wifiItem.showPasswordField = true;
                                        passwordField.placeholderText = "密碼錯誤";
                                    }
                                }
                            }

                            WrapperRectangle {
                                color: "#FCFCFC"
                                radius: 8
                                margin: 8
                                ColumnLayout {
                                    RowLayout {
                                        spacing: 8
                                        WrapperItem {
                                            margin: 4
                                            IconImage {
                                                source: Utils.resolveIconPath(NetworkService.getWifiStrengthIcon(wifiItem.modelData))
                                                implicitSize: 20
                                            }
                                        }

                                        StyledText {
                                            text: wifiItem.modelData.name
                                            font.pixelSize: 14
                                        }

                                        Item {
                                            Layout.fillWidth: true
                                        }

                                        StyledText {
                                            visible: wifiItem.modelData.state === QsNetworking.ConnectionState.Connected || wifiItem.modelData.state === QsNetworking.ConnectionState.Connecting
                                            font.pixelSize: 12
                                            font.weight: Font.Light
                                            text: {
                                                switch (wifiItem.modelData.state) {
                                                case QsNetworking.ConnectionState.Connected:
                                                    return "已連線";
                                                case QsNetworking.ConnectionState.Connecting:
                                                    return "連線中...";
                                                default:
                                                    return "";
                                                }
                                            }
                                        }

                                        WrapperMouseArea {
                                            margin: 8
                                            visible: wifiItem.modelData.known
                                            onClicked: {
                                                wifiItem.modelData.forget();
                                            }
                                            IconImage {
                                                source: Utils.resolveIconPath("trash")
                                                implicitSize: 16
                                            }
                                        }
                                    }
                                    RowLayout {
                                        spacing: 4
                                        visible: wifiItem.showPasswordField
                                        WrapperItem {
                                            Layout.fillWidth: true
                                            TextField {
                                                id: passwordField
                                                placeholderText: "輸入密碼"
                                                echoMode: TextInput.Password
                                                implicitHeight: 32

                                                onAccepted: {
                                                    wifiItem.connectWithPassword(passwordField.text);
                                                }

                                                Keys.onEscapePressed: {
                                                    parent.forceActiveFocus();
                                                    wifiItem.showPasswordField = false;
                                                }

                                                Connections {
                                                    target: wifiItem
                                                    function onShowPasswordFieldChanged() {
                                                        if (wifiItem.showPasswordField) {
                                                            passwordField.focus = true;
                                                        }
                                                        passwordField.text = "";
                                                    }
                                                }
                                            }
                                        }
                                        WrapperMouseArea {
                                            margin: 8
                                            onClicked: {
                                                wifiItem.connectWithPassword(passwordField.text);
                                            }

                                            IconImage {
                                                source: Utils.resolveIconPath("arrow-right")
                                                implicitSize: 16
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Ethernet
            WrapperRectangle {
                width: parent.width
                color: "#FCFCFC"
                radius: 8

                ColumnLayout {
                    spacing: 0

                    Repeater {
                        model: NetworkService.wiredDevices
                        delegate: WrapperMouseArea {
                            id: ethernetItem
                            required property var modelData
                            Layout.fillWidth: true
                            WrapperRectangle {
                                color: "#FCFCFC"
                                radius: 8
                                margin: 8
                                RowLayout {
                                    spacing: 8
                                    WrapperItem {
                                        margin: 4
                                        IconImage {
                                            Layout.alignment: Qt.AlignVCenter
                                            source: Utils.resolveIconPath("network")
                                            implicitSize: 20
                                        }
                                    }

                                    StyledText {
                                        Layout.alignment: Qt.AlignVCenter
                                        text: ethernetItem.modelData.name
                                        font.pixelSize: 14
                                    }

                                    Item {
                                        Layout.fillWidth: true
                                    }

                                    StyledText {
                                        Layout.alignment: Qt.AlignVCenter
                                        visible: ethernetItem.modelData.hasLink
                                        text: ethernetItem.modelData.hasLink && "已連線"
                                        font.pixelSize: 12
                                        font.weight: Font.Light
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
