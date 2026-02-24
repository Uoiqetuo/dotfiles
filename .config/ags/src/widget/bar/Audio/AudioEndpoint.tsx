import { Gdk, Gtk } from "ags/gtk4";
import { execAsync } from "ags/process";
import { Accessor, createComputed } from "gnim";
import ProfileList from "./Profile";
import AstalWp from "gi://AstalWp?version=0.1";

type AudioEndpointProps = {
  endpoint: AstalWp.Endpoint;
  isActive: Accessor<boolean>;
};

export default function AudioEndpoint({
  endpoint,
  isActive,
}: AudioEndpointProps) {
  return (
    <box orientation={Gtk.Orientation.VERTICAL} cssClasses={["device-item"]}>
      <box cssClasses={["device-header"]}>
        <Gtk.GestureClick
          button={Gdk.BUTTON_PRIMARY}
          onPressed={async () => {
            await execAsync(`wpctl set-default ${endpoint.id}`);
            print(
              `[Audio] Set default device to endpoint "${endpoint.description}" (${endpoint.id})`,
            );
          }}
        />
        <label
          label={createComputed(() => {
            return isActive()
              ? `● ${endpoint.device.description}`
              : `○ ${endpoint.device.description}`;
          })}
          halign={Gtk.Align.START}
          cssClasses={createComputed(() =>
            isActive() ? ["device-name", "active"] : ["device-name"],
          )}
        />
      </box>
      <ProfileList
        endpoint={endpoint}
        activeProfileId={endpoint.device.activeProfileId}
      />
    </box>
  );
}
