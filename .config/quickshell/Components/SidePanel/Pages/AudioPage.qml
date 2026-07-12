pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Pipewire

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

            // Parts.topbar {}
            WrapperRectangle {
                width: parent.width
                color: "#F2E3E6"
                radius: 8
                topMargin: 8
                bottomMargin: 8
                leftMargin: 16
                rightMargin: 8

                RowLayout {
                    StyledText {
                        Layout.fillWidth: true
                        text: "音訊裝置"
                        font.pixelSize: FontStyle.h3
                        font.weight: Font.Medium
                        color: "#EE455F"
                    }

                    WrapperMouseArea {
                        margin: 4
                        onClicked: {
                            AudioService.openPatchbay();
                            Quickshell.execDetached(["qs", "ipc", "call", "side_panel", "visible", "false"]);
                        }
                        IconImage {
                            source: Utils.resolveIconPath("tree-structure")
                            implicitSize: 20
                        }
                    }

                    WrapperMouseArea {
                        margin: 4
                        onClicked: {
                            AudioService.openMixer();
                            Quickshell.execDetached(["qs", "ipc", "call", "side_panel", "visible", "false"]);
                        }
                        IconImage {
                            source: Utils.resolveIconPath("gear")
                            implicitSize: 20
                        }
                    }
                }
            }

            // Parts.Devices {}
            Column {
                visible: AudioService.sinks.length > 0
                width: parent.width
                spacing: 8

                StyledText {
                    text: "輸出"
                    leftPadding: 12
                    bottomPadding: -6
                    color: "#DDAEB5"
                    font.pixelSize: FontStyle.h5
                    font.weight: Font.Medium
                }

                Repeater {
                    model: AudioService.sinks
                    delegate: DeviceComp {
                        checked: modelData?.id === AudioService.sink?.id
                        onClicked: {
                            AudioService.setDefaultSink(modelData);
                        }
                    }
                }
            }

            Column {
                visible: AudioService.sources.length > 0
                width: parent.width
                spacing: 8

                StyledText {
                    text: "輸入"
                    leftPadding: 12
                    bottomPadding: -6
                    color: "#DDAEB5"
                    font.pixelSize: FontStyle.h5
                    font.weight: Font.Medium
                }

                Repeater {
                    model: AudioService.sources
                    delegate: DeviceComp {
                        checked: modelData?.id === AudioService.source?.id
                        onClicked: {
                            AudioService.setDefaultSource(modelData);
                        }
                    }
                }
            }

            Column {
                visible: AudioService.streams.length > 0
                width: parent.width
                spacing: 8

                StyledText {
                    text: "應用程式"
                    leftPadding: 12
                    bottomPadding: -6
                    color: "#DDAEB5"
                    font.pixelSize: FontStyle.h5
                    font.weight: Font.Medium
                }

                Repeater {
                    model: AudioService.streams
                    delegate: AudioNodeComp {
                        name: AudioService.getDeviceName(modelData)
                        iconName: AudioService.getNodeIcon(modelData)
                    }
                }
            }
        }
    }

    component DeviceComp: RadioCard {
        id: deviceItem
        required property PwNode modelData

        width: parent.width

        contentItem: AudioNodeComp {
            color: "transparent"
            modelData: deviceItem.modelData
            name: AudioService.getDeviceName(deviceItem.modelData)
            iconName: AudioService.getNodeIcon(deviceItem.modelData)
        }
    }
    component AudioNodeComp: WrapperRectangle {
        id: card
        color: "#FCFCFC"
        radius: 8
        margin: 8
        width: parent.width
        required property PwNode modelData
        required property string name
        required property string iconName

        RowLayout {
            spacing: 8

            WrapperItem {
                margin: 4
                IconImage {
                    source: Utils.resolveIconPath(card.iconName)
                    implicitSize: 24
                }
            }
            Column {
                Layout.fillWidth: true
                StyledText {
                    width: parent.width
                    text: card.name
                    font.pixelSize: 14
                }
                Slider {
                    id: volumeSlider
                    width: parent.width
                    implicitHeight: 24
                    topPadding: 4
                    showLabel: true

                    from: 0.0
                    to: 1.5
                    stepSize: AppSettings.volumeStep

                    value: card.modelData?.audio.volume || 0
                    onMoved: {
                        AudioService.setVolume(card.modelData, value);
                    }

                    wheelEnabled: true
                }
            }
            WrapperMouseArea {
                onClicked: {
                    AudioService.toggleMute(card.modelData);
                }
                WrapperRectangle {
                    margin: 4
                    radius: 4
                    color: card.modelData?.audio.muted ? "#F28D9B" : "transparent"
                    IconImage {
                        source: Utils.resolveIconPath("speaker-x")
                        implicitSize: 20
                    }
                }
            }
        }
    }
}
