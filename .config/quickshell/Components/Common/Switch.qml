import QtQuick
import QtQuick.Controls

Switch {
    id: root
    property color checkedColor: "#F28D9B"

    implicitWidth: 34
    implicitHeight: 20

    indicator: Rectangle {
        width: root.implicitWidth
        height: root.implicitHeight
        radius: height / 2
        color: root.checked ? root.checkedColor : "#999999"

        Rectangle {
            x: root.checked ? parent.width - width - 2 : 2
            width: parent.height - 4
            height: width
            radius: width / 2
            anchors.verticalCenter: parent.verticalCenter
            color: "#FCFCFC"

            Behavior on x {
                NumberAnimation {
                    duration: 100
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }
}
