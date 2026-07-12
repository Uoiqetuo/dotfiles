import Quickshell
import QtQuick
import "./Components/Bar"
import "./Components/SidePanel"

ShellRoot {
    Variants {
        model: Quickshell.screens
        Bar {}
    }

    SidePanel {}
}
