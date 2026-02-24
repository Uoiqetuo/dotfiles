import AstalTray from "gi://AstalTray?version=0.1";
import { createBinding, For } from "ags";
import { Gtk } from "ags/gtk4";

export default function Tray() {
  const tray = AstalTray.get_default();
  const items = createBinding(tray, "items")
    .as((items) => {
      return items.filter((item) => item.id !== "Fcitx");
    });

  const init = (btn: Gtk.MenuButton, item: AstalTray.TrayItem) => {
    btn.menuModel = item.menuModel;
    btn.insert_action_group("dbusmenu", item.actionGroup);
    item.connect("notify::action-group", () => {
      btn.insert_action_group("dbusmenu", item.actionGroup);
    });
  };

  return (
    <box visible={items((v) => v.length > 0)} spacing={4} cssClasses={["tray"]}>
      <For each={items}>
        {(item) => {
          // print(item.id);
          return (
            <menubutton $={(self) => init(self, item)}>
              <image pixelSize={20} gicon={createBinding(item, "gicon")} />
            </menubutton>
          );
        }}
      </For>
    </box>
  );
}
