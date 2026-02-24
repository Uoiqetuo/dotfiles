import AstalNetwork from "gi://AstalNetwork?version=0.1";
import { Accessor, createBinding, createComputed, createState } from "ags";
import { Gdk, Gtk } from "ags/gtk4";
import { execAsync } from "ags/process";

type AccessPointProps = {
  ap: AstalNetwork.AccessPoint;
  state: Accessor<"active" | "inactive" | "connecting">;
};

const network = AstalNetwork.get_default();
const networkState = createBinding(network, "state");
const connections = createBinding(network.client, "connections").as((conns) => {
  const wirelessConns = conns.filter(
    (c) => c.get_connection_type() === "802-11-wireless",
  );
  // print(
  //   "[Network] Known connections:\n",
  //   wirelessConns.map((c) => `${c.get_id()} (${c.get_uuid()})`).join("\n "),
  // );
  return wirelessConns;
});

function hasStoredConnection(ap: AstalNetwork.AccessPoint): boolean {
  return connections.peek().some((conn) => conn.get_id() === ap.ssid);
}

async function connectAP(ap: AstalNetwork.AccessPoint, password?: string) {
  // 優先使用 SSID 連接（支援隨機 BSSID 的手機熱點）
  // 只在需要區分相同 SSID 的多個 AP 時才使用 BSSID
  const baseCmd = password
    ? `nmcli device wifi connect '${ap.ssid}' password '${password}'`
    : `nmcli device wifi connect '${ap.ssid}'`;

  await execAsync(["sh", "-c", baseCmd])
    .then(() => {
      print(`[Network] Connected to ${ap.ssid}`);
    })
    .catch((err) => {
      printerr(`[Network] Failed to connect to ${ap.ssid}:`, err);
      throw err;
    });
}

function disconnectAP(ap: AstalNetwork.AccessPoint) {
  execAsync(["sh", "-c", `nmcli connection down '${ap.ssid}'`])
    .then(() => {
      print(`[Network] Disconnected from ${ap.ssid}`);
    })
    .catch((err) => {
      printerr(`[Network] Failed to disconnect from ${ap.ssid}:`, err);
    });
}

function deleteConnection(ap: AstalNetwork.AccessPoint) {
  execAsync(["sh", "-c", `nmcli connection delete '${ap.ssid}'`])
    .then(() => {
      print(`[Network] Deleted connection for ${ap.ssid}`);
    })
    .catch((err) => {
      printerr(`[Network] Failed to delete connection for ${ap.ssid}:`, err);
    });
}

export default function AccessPoint({ ap, state }: AccessPointProps) {
  const [showInput, setShowInput] = createState(false);

  async function onClick() {
    if (showInput()) {
      setShowInput(false);
      return;
    }
    if (networkState() === AstalNetwork.State.CONNECTING) return;
    if (state() === "active") {
      print(`[Network] Disconnecting from ${ap.ssid}...`);
      disconnectAP(ap);
      return;
    }
    if (hasStoredConnection(ap)) {
      print(`[Network] Connecting to ${ap.ssid} using saved connection...`);
      try {
        await connectAP(ap);
      } catch (err: any) {
        if (err.message.includes("Secrets were required, but not provided")) {
          deleteConnection(ap);
        }
        setShowInput(true);
      }
      return;
    }
    if (ap.requiresPassword === false) {
      print(`[Network] Connecting to ${ap.ssid}...`);
      await connectAP(ap);
      return;
    }
    if (ap.requiresPassword === true) {
      print(`[Network] Connecting to ${ap.ssid} (password required)...`);
      setShowInput(true);
    }
  }

  return (
    <box cssClasses={["accessPoint"]} orientation={Gtk.Orientation.VERTICAL}>
      <Gtk.GestureClick button={Gdk.BUTTON_PRIMARY} onPressed={onClick} />
      <box>
        <label
          label={state((v) =>
            v === "active" ? "▸" : (v === "connecting" && "...") || "",
          )}
          visible={state((v) => v === "active" || v === "connecting")}
        />
        <label
          label={createComputed(() =>
            state() === "active" ? `  ${ap.ssid}` : `    ${ap.ssid}`,
          )}
        />
        <box
          visible={connections((v) => {
            // 根據 SSID 判斷是否已儲存此連線
            return v.some((c) => c.get_id() === ap.ssid);
          })}
        >
          <Gtk.GestureClick
            button={Gdk.BUTTON_PRIMARY}
            onPressed={(source) => {
              deleteConnection(ap);
              source.set_state(Gtk.EventSequenceState.CLAIMED);
            }}
          />
          <label label="    D" />
        </box>
      </box>
      <box visible={showInput}>
        <entry
          placeholderText="Password"
          visibility={false}
          invisibleChar={42 /* '*' */}
          onActivate={async (self) => {
            const password = self.get_text();
            setShowInput(false);
            await connectAP(ap, password);
            self.set_text("");
          }}
        />
      </box>
    </box>
  );
}
