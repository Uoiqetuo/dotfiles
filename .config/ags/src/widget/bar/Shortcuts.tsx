import GObject from "ags/gobject";
import { Gdk, Gtk } from "ags/gtk4";
import AstalApps from "gi://AstalApps?version=0.1";

const apps = new AstalApps.Apps();

// for (const app of apps.list) {
//   print(`[Shortcuts] Found app: ${app.name}`);
// }

const shortcuts: ShortcutProps[] = [
  {
    app: apps.exact_query("kitty")[0],
    icon: "terminal",
  },
  {
    app: apps.exact_query("Google Chrome")[0],
    icon: "chrome",
  },
  {
    app: apps.exact_query("Files")[0],
  },
];

export default function Shortcuts() {
  return (
    <box visible={shortcuts.length > 0} spacing={2} cssClasses={["shortcuts"]}>
      {shortcuts.map((shortcut) => (
        <Shortcut
          app={shortcut.app}
          icon={shortcut.icon}
          action={shortcut.action}
        />
      ))}
    </box>
  );
}

type ShortcutProps = {
  app: AstalApps.Application;
  icon?: GObject.Object | string;
  action?: {
    onPrimaryClick?: () => void;
    onSecondaryClick?: () => void;
  };
};

function Shortcut({ app, icon, action }: ShortcutProps) {
  if (!icon) {
    icon = app.iconName || "application-x-executable";
  }
  return (
    <box cssClasses={["shortcut-item"]}>
      {typeof icon === "string" ? (
        <image iconName={icon} cssClasses={["shortcut-icon"]} pixelSize={24} />
      ) : (
        icon
      )}
      {
        <Gtk.GestureClick
          button={Gdk.BUTTON_PRIMARY}
          onPressed={() => {
            app && app.launch();
            action?.onPrimaryClick && action.onPrimaryClick();
          }}
        />
      }
      {action?.onSecondaryClick && (
        <Gtk.GestureClick
          button={Gdk.BUTTON_SECONDARY}
          onPressed={() => {
            action.onSecondaryClick && action.onSecondaryClick();
          }}
        />
      )}
    </box>
  );
}
