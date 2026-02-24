import { Accessor, createBinding, createState } from "ags";
import { Gtk } from "ags/gtk4";
import { timeout, Timer } from "ags/time";
import AstalWp from "gi://AstalWp?version=0.1";

const revealDuration = 1200;

const [showVol, setShowVol] = createState(false);
let hideTimer: Timer | null = null;

export default function VolumeRevealer() {
  const { defaultSpeaker } = AstalWp.get_default();

  const speakerVolume = createBinding(defaultSpeaker, "volume");

  defaultSpeaker.connect("notify::volume", (source) => {
    // print(`Volume changed: ${source.volume}`);
    showVolumeTemporarily();
  });
  defaultSpeaker.connect("notify::mute", (source) => {
    // print(`Mute changed: ${source.mute}`);
    if (!source.mute) showVolumeTemporarily();
  });
  return (
    <revealer
      revealChild={showVol}
      transitionType={Gtk.RevealerTransitionType.SLIDE_RIGHT}
      transitionDuration={200}
    >
      <label
        cssClasses={["vol-text"]}
        halign={Gtk.Align.CENTER}
        label={speakerVolume((v) => Math.round(v * 100) + "%")}
      />
    </revealer>
  );
}

export const showVolumeTemporarily = () => {
  setShowVol(true);

  if (hideTimer !== null) {
    hideTimer!.cancel();
    hideTimer = null;
  }

  hideTimer = timeout(revealDuration, () => {
    setShowVol(false);
    hideTimer = null;
    return false;
  });
};
