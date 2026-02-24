import AstalWp from "gi://AstalWp?version=0.1";
import Icon from "../Icon";
import { createBinding, createComputed } from "ags";

export default function AudioIcon() {
  const { defaultSpeaker } = AstalWp.get_default();
  const speakerVolumeBinding = createBinding(defaultSpeaker, "volume");
  const speakerMuteBinding = createBinding(defaultSpeaker, "mute");

  const iconName = createComputed(() => {
    if (speakerMuteBinding()) return "speaker-x";
    const percent = Math.round(speakerVolumeBinding() * 100);
    if (percent <= 0) return "speaker-none";
    if (percent <= 33) return "speaker-low";
    return "speaker-high";
  });
  return <Icon iconName={iconName} />;
}
