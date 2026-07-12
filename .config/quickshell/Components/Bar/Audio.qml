import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.Common
import qs.Components.Common
import qs.Services

WrapperRectangle {
    id: root
    color: "#22000000"
    radius: 4
    implicitHeight: 28

    property bool showVolume: false
    readonly property int showVolumeDuration: 1200
    property var sinkAudio: AudioService.sink?.audio || null

    onSinkAudioChanged: {
        if (root.sinkAudio) {
            root.showVolumeTemporarily();
        }
    }

    function showVolumeTemporarily() {
        root.showVolume = true;
        hideTimer.restart();
    }

    Connections {
        target: root.sinkAudio

        function onVolumeChanged() {
            root.showVolumeTemporarily();
        }

        function onMutedChanged() {
            if (!root.sinkAudio.muted) {
                root.showVolumeTemporarily();
            }
        }
    }

    Timer {
        id: hideTimer
        interval: root.showVolumeDuration
        running: false
        repeat: false

        onTriggered: {
            root.showVolume = false;
        }
    }

    WrapperMouseArea {
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        anchors.fill: parent

        onClicked: mouse => {
            if (mouse.button === Qt.LeftButton) {
                Quickshell.execDetached(["qs", "ipc", "call", "side_panel", "setPage", "audio"]);
                Quickshell.execDetached(["qs", "ipc", "call", "side_panel", "visible", "true"]);
            } else if (mouse.button === Qt.MiddleButton) {
                AudioService.toggleMute(AudioService.sink);
            }
        }
        onWheel: wheel => {
            AudioService.handleVolumeWheel(AudioService.sink, wheel);
        }

        Row {
            id: contentRow
            spacing: -2

            Item {
                implicitWidth: root.showVolume ? volumeText.implicitWidth + 4 : 0
                implicitHeight: 28
                clip: true

                Behavior on implicitWidth {
                    NumberAnimation {
                        duration: 150
                        easing.type: Easing.InOutQuad
                    }
                }

                StyledText {
                    id: volumeText
                    anchors.verticalCenter: parent.verticalCenter
                    x: 4
                    color: "white"
                    text: Math.round((sinkAudio?.volume || 0) * 100) + "%"
                    font.pixelSize: FontStyle.content
                    font.weight: Font.Medium
                    font.letterSpacing: 0.4
                }
            }

            WrapperItem {
                margin: 4
                IconImage {
                    source: Utils.resolveIconPath(AudioService.getVolumeIcon(AudioService.sink))
                    implicitSize: 20
                }
            }
        }
    }
}
