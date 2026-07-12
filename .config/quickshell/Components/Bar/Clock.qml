import QtQuick
import Quickshell
import Quickshell.Widgets

import qs.Common
import qs.Components.Common

WrapperRectangle {
    id: root
    color: "#22000000"
    radius: 4
    implicitHeight: 28

    Item {
        id: clockContent
        implicitWidth: clockText.implicitWidth + 12
        implicitHeight: 28

        StyledText {
            id: clockText
            anchors.centerIn: parent
            color: "white"

            font.pixelSize: FontStyle.content
            font.letterSpacing: 0.4
            font.weight: Font.Medium
            font.features: {
                "tnum": 1
            }

            text: Qt.formatDateTime(clock.date, "hh:mm:ss")

            SystemClock {
                id: clock
                precision: SystemClock.Seconds
            }
        }
    }
}
