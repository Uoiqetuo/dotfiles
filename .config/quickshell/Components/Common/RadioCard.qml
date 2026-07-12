import QtQuick
import QtQuick.Controls

RadioButton {
    id: control
    padding: 0

    indicator: Item {}

    background: Rectangle {
        radius: 8

        color: control.checked ? "#F9E8EB" : "#FCFCFC"

        border.width: control.checked ? 1.5 : 0
        border.color: "#F28D9B"
    }
}
