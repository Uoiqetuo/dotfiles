pragma Singleton

import Quickshell

Singleton {
    id: root

    function resolveIconPath(name) {
        if (name.startsWith("file://") || name.startsWith("qrc:/") || name.startsWith("image://"))
            return name;
        return "file://" + Quickshell.shellDir + "/assets/icons/" + name + ".svg";
    }
}
