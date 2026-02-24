import { Gdk, Gtk } from "ags/gtk4";
import AstalWp from "gi://AstalWp";
import { Accessor, createState } from "ags";
import { execAsync } from "ags/process";
import VolumeRevealer from "./VolumeRevealer";
import AudioIcon from "./AudioIcon";
import AudioPopover from "./AudioPopover";

const AUDIO_STEP = 0.02;
const MAX_VOLUME = 1.5;

export default function Audio() {
  const [popover, setPopover] = createState<Gtk.Popover | null>(null);
  const { defaultSpeaker: speaker } = AstalWp.get_default()!;

  function onScroll(_self: Gtk.EventControllerScroll, _dx: number, dy: number) {
    if (!speaker) return;
    // dy > 0 means scrolling down, dy < 0 means scrolling up
    const delta = dy > 0 ? -AUDIO_STEP : AUDIO_STEP;
    speaker.volume = Math.max(0, Math.min(MAX_VOLUME, speaker.volume + delta));
    return true;
  }

  function toggleMute() {
    if (speaker) speaker.mute = !speaker.mute;
  }

  return (
    <box cssClasses={["audio", "widget"]}>
      <Gtk.EventControllerScroll
        flags={Gtk.EventControllerScrollFlags.VERTICAL}
        onScroll={onScroll}
      />
      <Gtk.GestureClick
        button={Gdk.BUTTON_PRIMARY}
        onPressed={() => popover()?.popup()}
      />
      <Gtk.GestureClick button={Gdk.BUTTON_MIDDLE} onPressed={toggleMute} />
      <Gtk.GestureClick
        button={Gdk.BUTTON_SECONDARY}
        onPressed={() =>
          execAsync([
            "sh",
            "-c",
            "pavucontrol || flatpak run org.pulseaudio.pavucontrol",
          ]).catch((err) => {
            printerr("Failed to launch pavucontrol:", err);
          })
        }
      />
      <VolumeRevealer />
      <AudioPopover onMount={(self) => setPopover(self)} />
      <AudioIcon />
    </box>
  );
}
