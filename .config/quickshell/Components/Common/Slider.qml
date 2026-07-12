import QtQuick
import QtQuick.Controls
import Quickshell.Widgets

import qs.Common
import qs.Components.Common

Slider {
    id: control
    implicitHeight: 16

    property bool showLabel: false

    handle: Item {}

    background: ClippingRectangle {
        id: track
        x: control.leftPadding
        y: control.topPadding + control.availableHeight / 2 - height / 2
        width: control.availableWidth
        height: control.implicitHeight - control.topPadding - control.bottomPadding

        radius: height / 2
        color: "#D0CCCB"

        Rectangle {
            id: progress
            width: control.visualPosition * parent.width
            height: parent.height
            color: "#D0455A"
        }

        StyledText {
            visible: control.showLabel
            text: Math.round(control.value * 100)
            anchors.verticalCenter: parent.verticalCenter
            x: control.leftPadding + 8

            font.pixelSize: track.height > FontStyle.content ? FontStyle.content : track.height - 2
            font.letterSpacing: -0.4
            font.features: {
                "tnum": 1
            }
            color: "white"
        }
    }
}
