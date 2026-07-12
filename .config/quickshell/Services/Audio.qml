pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

import qs.Common

Singleton {
    id: root
    property list<PwNode> sinks: []
    property list<PwNode> sources: []
    property list<PwNode> streams: []

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource

    function setDefaultSink(newSink: PwNode) {
        Pipewire.preferredDefaultAudioSink = newSink;
    }

    function setDefaultSource(newSource: PwNode) {
        Pipewire.preferredDefaultAudioSource = newSource;
    }

    function setVolume(node: PwNode, volume: real) {
        if (!node?.audio || !node.ready)
            return;

        node.audio.volume = volume;
    }

    function toggleMute(node: PwNode) {
        if (!node?.audio || !node.ready)
            return;

        node.audio.muted = !node.audio.muted;
    }

    function handleVolumeWheel(node: PwNode, wheelEvent: WheelEvent) {
        if (!node?.audio || !node.ready)
            return;

        const delta = wheelEvent.angleDelta.y;
        if (delta === 0)
            return;

        const step = AppSettings.volumeStep * (delta > 0 ? 1 : -1);
        root.setVolume(node, Math.max(0, Math.min(AppSettings.maxVolume, node.audio.volume + step)));
    }

    function getVolumeIcon(node: PwNode): string {
        if (!node || !node.ready)
            return "speaker-high";

        if (!node.audio)
            return "audio-volume-muted";

        if (node.audio.muted)
            return "speaker-x";
        else if (node.audio.volume <= 0)
            return "speaker-none";
        else if (node.audio.volume < 0.33)
            return "speaker-low";
        else
            return "speaker-high";
    }

    function getNodeIcon(node: PwNode): string {
        if (!node || !node.ready)
            return "speaker-high";
        const props = node.properties || {};
        const name = (node.name || "").toLowerCase();
        const bus = (props["device.bus"] || "").toLowerCase();

        if (!node.isStream) {
            if (node.isSink) {
                if (bus === "bluetooth")
                    return "bluetooth";
                if (bus === "usb")
                    return "headphones";
                if (name.includes("hdmi"))
                    return "monitor";
                return "speaker-high";
            } else if (node.audio)
                return "microphone";
        } else if (node.audio) {
            return Quickshell.iconPath(node.properties["application.icon-name"], true) || Utils.resolveIconPath("app-window");
        }
    }

    function getDeviceName(node: PwNode): string {
        if (!node || !node.ready)
            return "未知裝置";
        const alias = AppSettings.audioDeviceAliases[node.nickname] || AppSettings.audioDeviceAliases[node.description] || AppSettings.audioDeviceAliases[node.name];
        return alias || node.nickname || node.description || node.name || "未知裝置";
    }

    function openMixer() {
        Quickshell.execDetached(["flatpak", "run", "org.pulseaudio.pavucontrol"]);
    }

    function openPatchbay() {
        Quickshell.execDetached(["flatpak", "run", "org.pipewire.Helvum"]);
    }

    function rebuildNodeLists() {
        const newSinks = [];
        const newSources = [];
        const newStreams = [];

        for (const node of Pipewire.nodes.values) {
            if (!node.isStream) {
                if (node.isSink)
                    newSinks.push(node);
                else if (node.audio)
                    newSources.push(node);
            } else if (node.audio) {
                newStreams.push(node);
            }
        }

        root.sinks = newSinks.filter(sink => !AppSettings.hiddenAudioDevices.includes(sink.name));
        root.sources = newSources.filter(source => !AppSettings.hiddenAudioDevices.includes(source.name));
        root.streams = newStreams;
    }

    Connections {
        function onValuesChanged(): void {
            root.rebuildNodeLists();
        }

        target: Pipewire.nodes
    }

    PwObjectTracker {
        objects: [...Pipewire.nodes.values]
    }

    Component.onCompleted: {
        root.rebuildNodeLists();
    }
}
