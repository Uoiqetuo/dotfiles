import AstalNetwork from "gi://AstalNetwork?version=0.1";
import { createBinding, createComputed, With } from "ags";
import { Gtk } from "ags/gtk4";

const network = AstalNetwork.get_default();

export default function WiredNetwork() {
  const wired = createBinding(network, "wired").as((w) => {
    // print("[Network] Wired devices:", w ? w.device.interface : "none");
    // print("[Network] Wired state:", w ? w.state : "none");
    return w;
  });
  const primaryConnection = createBinding(
    network.client,
    "primaryConnection",
  ).as((conn) => {
    // print("[Network] Primary connection:", conn ? conn.type : "none");
    return conn.type === "802-3-ethernet" ? conn : null;
  });

  const interfaceName = createComputed(() => {
    if (primaryConnection()?.type === "802-3-ethernet") {
      return primaryConnection()?.devices[0].interface;
    }
    return wired().device.interface;
  });

  const isActive = createComputed(() => {
    if (primaryConnection()?.type === "802-3-ethernet") {
      return true;
    }
    return wired().state === AstalNetwork.DeviceState.ACTIVATED;
  });

  return (
    <box orientation={Gtk.Orientation.VERTICAL}>
      <label label="Wired" halign={Gtk.Align.START} />
      <With value={wired}>
        {(wired) => (
          <box orientation={Gtk.Orientation.VERTICAL}>
            <label
              label={createComputed(
                () => (isActive() ? "▸" : " ") + `   ${interfaceName()}`,
              )}
              halign={Gtk.Align.START}
            />
          </box>
        )}
      </With>
    </box>
  );
}
