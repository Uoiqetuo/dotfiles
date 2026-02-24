import app from "ags/gtk4/app";
import { Astal } from "ags/gtk4";
import Clock from "./Clock";
import Audio from "./Audio/Audio";
import Network from "./Network/Network";
import Workspace from "./Workspace";
import ImIndicator from "./ImIndicator";
import Tray from "./Tray";
import AstalHyprland from "gi://AstalHyprland";
import Shortcuts from "./Shortcuts";

export default function Bar({ monitor }: { monitor: AstalHyprland.Monitor }) {
  const { TOP, LEFT, RIGHT } = Astal.WindowAnchor;
  print(`[Bar] Creating bar for monitor: ${monitor.name} (ID: ${monitor.id})`);

  return (
    <window
      visible
      name={`Bar-${monitor.name}`}
      class="bar"
      monitor={monitor.id}
      exclusivity={Astal.Exclusivity.EXCLUSIVE}
      anchor={TOP | LEFT | RIGHT}
      application={app}
    >
      <centerbox cssClasses={["centerbox"]}>
        <box $type="start" spacing={8}>
          <Workspace />
          <Shortcuts />
        </box>
        <box $type="center" spacing={8}></box>
        <box $type="end" spacing={8}>
          <Tray />
          <ImIndicator />
          <Audio />
          <Network />
          <Clock />
        </box>
      </centerbox>
    </window>
  );
}
