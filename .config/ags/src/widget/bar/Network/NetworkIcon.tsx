import AstalNetwork from "gi://AstalNetwork?version=0.1";
import Icon from "../Icon";
import { createBinding, createComputed } from "ags";
import NM from "gi://NM?version=1.0";

const network = AstalNetwork.get_default();

enum ConnectionType {
  WIFI = "802-11-wireless",
  WIRED = "802-3-ethernet",
}

export default function NetworkIcon() {
  const connection = createBinding(network.client, "primaryConnection").as(
    (c: NM.ActiveConnection | null) => {
      // print(`[Network] type: ${c ? c.type : "None"}`);
      return c;
    },
  );

  const iconName = createComputed(() => {
    const conn = connection();

    // no network
    if (!conn) return "wifi-x";

    // wireless
    if (conn.type === ConnectionType.WIFI) {
      const wifiStrength = createBinding(network.wifi, "strength");
      // print(`[Network] wifi strength: ${wifiStrength()}`);
      if (wifiStrength() >= 70) return "wifi-high";
      if (wifiStrength() >= 40) return "wifi-medium";
      if (wifiStrength() >= 10) return "wifi-low";
      return "wifi-none";
    }

    // wired
    return "network";
  });

  return <Icon iconName={iconName} />;
}
