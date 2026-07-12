pragma Singleton

import Quickshell

Singleton {
    id: root

    readonly property var audioDeviceAliases: ({
        // name, nickname, description or name: alias
        })

    readonly property list<string> hiddenAudioDevices: [
        "alsa_output.pci-0000_00_1f.3.iec958-stereo",
        "alsa_input.pci-0000_00_1f.3.analog-stereo"
    ]

    readonly property real maxVolume: 1.5
    readonly property real volumeStep: 0.02
}
