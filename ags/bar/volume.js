const audioService = await Service.import("audio");
const { Gdk } = imports.gi;

function getIconName() {
    const volumeMap = {
        67: "speaker-high-symbolic",
        34: "speaker-low-symbolic",
        0: "speaker-none-symbolic",
    }

    if (audioService.speaker.is_muted) return "speaker-x-symbolic";

    const value = [67, 34, 0].find(
        threshold => threshold <= audioService.speaker.volume * 100
    )
    
    // console.log(volumeMap[value]);
    return volumeMap[value];
}

function volumeUp() {
    audioService.speaker.volume += 0.02;
}

function volumeDown() {
    audioService.speaker.volume -= 0.02;
}

const volume = () => {
    
    const icon = Widget.Icon({
        classNames: ["icon-container"],
        name: "volume",
        icon: Utils.watch(getIconName(), audioService.speaker, getIconName),
    })

    const percentLabel = Widget.Revealer({
        revealChild: false,
        transition: "slide_right",
        transitionDuration: 150,
        child: Widget.Label({
            className: "label-revealer-container",
            label: audioService?.speaker.bind("volume").as((v) => `${Math.round(v * 100)}%`)
        })
    })

    let lastAudioState = {};
    Utils.watch(0, audioService.speaker, "notify::volume", () => {
        const newVolume = audioService.speaker.volume;
        if (newVolume !== lastAudioState.volume) {
            percentLabel.revealChild = true;
            lastAudioState.source && lastAudioState.source.destroy();
            lastAudioState.source = setTimeout(() => {
                percentLabel.revealChild = false;
            }, 500);
            
            // console.log(audioService.speaker.volume);
            lastAudioState.volume = newVolume;
        }
    })
    Utils.watch(true, audioService.speaker, "notify::is-muted", () => {
        const newIsMuted = audioService.speaker.is_muted;
        if (newIsMuted !== lastAudioState.isMuted) {
            percentLabel.revealChild = true;
            lastAudioState.source && lastAudioState.source.destroy();
            lastAudioState.source = setTimeout(() => {
                percentLabel.revealChild = false;
            }, 500);
            
            // console.log(audioService.speaker.is_muted);
            lastAudioState.isMuted = newIsMuted;
        }
    })

    const ret = Widget.EventBox({
        onPrimaryClick: (event) => {
            audioService.speaker.is_muted = !audioService.speaker.is_muted;
            // console.log(audioService?.speaker.volume);
            // console.log(audioService?.speaker);
        },
        onSecondaryClick: (event) => {
            Utils.execAsync("pavucontrol");
        },
        setup: (self) => {
            self
                .on("scroll-event", (widget, event) => {
                    const device = event.get_source_device().get_source();
                    self.on_scroll_up = device === Gdk.InputSource.TOUCHPAD ? volumeDown: volumeUp;
                    self.on_scroll_down = device === Gdk.InputSource.TOUCHPAD ? volumeUp: volumeDown;
                })
        },
        child: Widget.Box({
            classNames: ["bar-item-container"],
            children: [
                percentLabel,
                icon
            ],
        })
    })

    return ret;
}

export default volume;