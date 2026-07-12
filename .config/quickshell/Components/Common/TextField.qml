import QtQuick
import QtQuick.Controls

import qs.Common

TextField {
    id: root
    topPadding: 4
    bottomPadding: 4
    leftPadding: 8
    rightPadding: 8
    
    font.family: FontStyle.fontFamily
    font.letterSpacing: 0.4
    
    background: Rectangle {
        implicitHeight: 32
        implicitWidth: 150
        color: "transparent"
        border.color: "#F28D9B"
        border.width: root.activeFocus ? 2 : 1
        radius: 4
    }
}