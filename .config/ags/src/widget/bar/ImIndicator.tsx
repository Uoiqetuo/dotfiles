import { createBinding } from "ags";
import { Gdk, Gtk } from "ags/gtk4";
import AstalTray from "gi://AstalTray?version=0.1";

const ICON_MAP: Record<string, string> = {
  "input-keyboard-symbolic": "keyboard-symbolic.svg",
  fcitx_mcbopomofo: "im-bopomofo-symbolic.svg",
};

export default function ImIndicator() {
  const tray = AstalTray.get_default();
  const fcitxItem = createBinding(tray, "items").as((items) =>
    items.find((item) => item.id === "Fcitx"),
  );

  const icon = (
    <image
      cssClasses={["icon"]}
      $={(img) => {
        let handler: number | undefined;

        const update = () => {
          const item = fcitxItem();
          if (!item) return;
          // print(item.iconName);
          if (item.iconName in ICON_MAP) {
            const iconPath = `${SRC}/icons/${ICON_MAP[item.iconName]}`;
            img.file = iconPath;
            return;
          }
          img.gicon = item.gicon;
        };
        update();

        // 當 tray item 出現 / 消失
        const untrack = fcitxItem.subscribe(() => {
          if (handler) {
            fcitxItem()?.disconnect(handler);
            handler = undefined;
          }

          const item = fcitxItem();
          if (item) {
            update();
            handler = item.connect("notify::gicon", update);
          }
        });

        return () => {
          untrack();
          if (handler) fcitxItem()?.disconnect(handler);
        };
      }}
    />
  );

  return (
    <box cssClasses={["widget"]} visible={fcitxItem(Boolean)}>
      <Gtk.GestureClick
        button={Gdk.BUTTON_PRIMARY}
        onPressed={() => fcitxItem()?.activate(0, 0)}
      />
      {icon}
    </box>
  );
}
