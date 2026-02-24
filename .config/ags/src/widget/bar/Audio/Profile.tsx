import { Gdk, Gtk } from "ags/gtk4";
import { Accessor, createBinding, For } from "ags";
import AstalWp from "gi://AstalWp?version=0.1";
import { execAsync } from "ags/process";

type ProfileListProps = {
  endpoint: AstalWp.Endpoint;
  activeProfileId: number;
};

export default function ProfileList({
  endpoint,
  activeProfileId,
}: ProfileListProps) {
  const profiles = createBinding(endpoint.device, "profiles");

  return (
    <box orientation={Gtk.Orientation.VERTICAL} cssClasses={["profile-list"]}>
      <For
        each={createBinding(endpoint, "deviceId").as(
          () => profiles()?.sort((a, b) => a.index - b.index) || [],
        )}
      >
        {(profile: AstalWp.Profile) => {
          return (
            <ProfileItem
              endpoint={endpoint}
              profile={profile}
              active={activeProfileId === profile.index}
            />
          );
        }}
      </For>
    </box>
  );
}

function ProfileItem({
  endpoint,
  profile,
  active,
}: {
  endpoint: AstalWp.Endpoint;
  profile: AstalWp.Profile;
  active: boolean;
}) {
  async function onClick() {
    try {
      await execAsync(
        `wpctl set-profile ${endpoint.device.id} ${profile.index}`,
      );
      print(
        `[Audio] Set profile "${profile.description}" for device ${endpoint.device.description} (${endpoint.device.id})`,
      );
    } catch (err) {
      printerr("Failed to set profile:", err);
    }
    try {
      await execAsync(`wpctl set-default ${endpoint.id}`);
      print(
        `[Audio] Set default device to endpoint "${endpoint.description}" (${endpoint.id})`,
      );
    } catch (err) {
      printerr("Failed to set default device:", err);
    }
  }

  return (
    <box>
      <Gtk.GestureClick button={Gdk.BUTTON_PRIMARY} onPressed={onClick} />
      <label
        label={createBinding(
          endpoint,
          "deviceId",
        )(() => {
          if (active) {
            return `  ▸ ${profile.description}`;
          } else {
            return `     ${profile.description}`;
          }
        })}
        halign={Gtk.Align.START}
        cssClasses={["profile-label"]}
      />
    </box>
  );
}
