import { Gtk } from "ags/gtk4";
import { Accessor, createBinding, For } from "ags";
import AudioEndpoint from "./AudioEndpoint";
import AstalWp from "gi://AstalWp?version=0.1";

type AudioPopoverProps = {
  onMount?: (popover: Gtk.Popover) => void;
};

export default function AudioPopover({ onMount }: AudioPopoverProps) {
  const {
    defaultSpeaker: speaker,
    defaultMicrophone: microphone,
    audio,
  } = AstalWp.get_default()!;

  const speakerDeviceIdBinding = createBinding(speaker, "deviceId");
  const micDeviceIdBinding = createBinding(microphone, "deviceId");

  const speakerEndpoints = createBinding(audio, "speakers").as((v) => {
    // print("Speaker Endpoints updated:\n ", v.map(d => d.description).join("\n  "));
    return v;
  });
  const micEndpoints = createBinding(audio, "microphones").as((v) => {
    // print("Microphone Endpoints updated:\n ", v.map(d => d.description).join("\n  "));
    return v;
  });

  return (
    <popover
      $={(self) => {
        onMount?.(self);
      }}
    >
      <box
        orientation={Gtk.Orientation.VERTICAL}
        spacing={12}
        cssClasses={["audio-popover"]}
      >
        <box orientation={Gtk.Orientation.VERTICAL}>
          <box cssClasses={["audio-section-header"]}>
            <label label="Speaker" cssClasses={["section-title"]} />
          </box>
          <box
            orientation={Gtk.Orientation.VERTICAL}
            spacing={4}
            cssClasses={["device-list"]}
          >
            <For each={speakerEndpoints}>
              {(speakerEndpoint) => (
                <AudioEndpoint
                  endpoint={speakerEndpoint}
                  isActive={speakerDeviceIdBinding(
                    (speakerDeviceId) =>
                      speakerDeviceId === speakerEndpoint.deviceId,
                  )}
                />
              )}
            </For>
          </box>
        </box>
        <box cssClasses={["separator"]} />
        <box orientation={Gtk.Orientation.VERTICAL}>
          <box cssClasses={["audio-section-header"]}>
            <label label="Microphone" cssClasses={["section-title"]} />
          </box>
          <box
            orientation={Gtk.Orientation.VERTICAL}
            spacing={4}
            cssClasses={["device-list"]}
          >
            <For each={micEndpoints}>
              {(micEndpoint) => (
                <AudioEndpoint
                  endpoint={micEndpoint}
                  isActive={micDeviceIdBinding(
                    (micDeviceId) => micDeviceId === micEndpoint.deviceId,
                  )}
                />
              )}
            </For>
          </box>
        </box>
      </box>
    </popover>
  );
}
