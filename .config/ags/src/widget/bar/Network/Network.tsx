import AstalNetwork from "gi://AstalNetwork?version=0.1";
import { createBinding, createComputed, For, With } from "ags";
import { Gdk, Gtk } from "ags/gtk4";
import AccessPoint from "./AccessPoint";
import NetworkIcon from "./NetworkIcon";
import WiredNetwork from "./WiredNetwork";

export default function Network() {
  const network = AstalNetwork.get_default();
  const wifi = createBinding(network, "wifi");
  const activeAP = createBinding(network.wifi, "activeAccessPoint");
  const networkState = createBinding(network, "state");

  let popover: Gtk.Popover | null = null;

  const sorted = (arr: Array<AstalNetwork.AccessPoint>) => {
    return arr
      .filter((ap) => !!ap.ssid)
      .sort((a, b) => b.strength - a.strength);
  };

  const onClick = () => {
    popover?.popup();
    if (!wifi().scanning) {
      wifi().scan();
      print("[Network] Scanning for wifi networks...");
    }
  };

  return (
    <box cssClasses={["network", "widget"]}>
      <Gtk.GestureClick button={Gdk.BUTTON_PRIMARY} onPressed={onClick} />
      <NetworkIcon />

      <popover
        $={(self) => {
          popover = self;
        }}
      >
        <box orientation={Gtk.Orientation.VERTICAL} spacing={12}>
          <box orientation={Gtk.Orientation.VERTICAL}>
            <With value={wifi}>
              {(wifi) => (
                <box orientation={Gtk.Orientation.VERTICAL}>
                  <box>
                    <label label="Wifi" />
                    <label
                      visible={createBinding(wifi, "scanning")}
                      label=" (scanning...)"
                    />
                  </box>
                  <box orientation={Gtk.Orientation.VERTICAL}>
                    <For each={createBinding(wifi, "accessPoints")(sorted)}>
                      {(ap: AstalNetwork.AccessPoint) => (
                        <AccessPoint
                          ap={ap}
                          state={createComputed(() => {
                            if (activeAP() === ap) {
                              if (
                                networkState() === AstalNetwork.State.CONNECTING
                              )
                                return "connecting";
                              return "active";
                            }
                            return "inactive";
                          })}
                        />
                      )}
                    </For>
                  </box>
                </box>
              )}
            </With>
          </box>

          <WiredNetwork />
        </box>
      </popover>
    </box>
  );
}
