pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Networking

Singleton {
    id: root

    readonly property bool wifiEnabled: Networking.wifiEnabled

    property WifiDevice primaryWifiDevice: Networking.devices.values.find(device => device.type === DeviceType.Wifi) || null

    property list<NetworkDevice> wiredDevices: Networking.devices.values.filter(device => device.type === DeviceType.Wired) || []

    function toggleWifi() {
        Networking.wifiEnabled = !Networking.wifiEnabled;
        if (Networking.wifiEnabled && root.primaryWifiDevice) {
            primaryWifiDevice.scannerEnabled = true;
        }
    }

    function getWifiStrengthIcon(wifi: WifiNetwork): string {
        if (wifi.signalStrength > 0.7)
            return "wifi-high";
        else if (wifi.signalStrength > 0.4)
            return "wifi-medium";
        else
            return "wifi-low";
    }

    function getNetworkIcon(): string {
        if (root.wiredDevices.some(device => device.state === ConnectionState.Connected))
            return "network";

        const wifi = root.primaryWifiDevice;

        if (!wifi)
            return "wifi-slash";
        if (!wifi.connected)
            return "wifi-x";

        const network = wifi.networks.values.find(network => network.connected);

        return network ? root.getWifiStrengthIcon(network) : "wifi-x";
    }

    Timer {
        id: wifiScanTimer
        interval: 60 * 1000
        repeat: false
        running: root.primaryWifiDevice?.scannerEnabled || false

        onTriggered: {
            if (root.primaryWifiDevice) {
                root.primaryWifiDevice.scannerEnabled = false;
            }
        }
    }
}
