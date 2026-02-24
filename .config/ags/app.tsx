// while sleep 0.3; do find src | entr -drc ags run ./app.tsx; done
// sass --no-source-map --watch src/styles/style.scss /run/user/1000/ags/style.css &

import app from "ags/gtk4/app";
import Bar from "./src/widget/bar/Bar";
import { monitorFile, readFile } from "ags/file";
import AstalHyprland from "gi://AstalHyprland?version=0.1";
import { createBinding, For } from "ags";
import { exec } from "ags/process";
import GLib from "gi://GLib?version=2.0";
import { Gtk } from "ags/gtk4";

const runtimeConfig = `${GLib.get_user_runtime_dir()}/ags`;
exec(`mkdir -p ${runtimeConfig}`);
const CSS_PATH = `${runtimeConfig}/style.css`;

// if css file doesn't exist, compile it once
try {
  readFile(CSS_PATH);
} catch {
  print("Compiling initial CSS...");
  exec(`sass --no-source-map ${SRC}/src/styles/style.scss ${CSS_PATH}`);
}

monitorFile(CSS_PATH, async (_, event) => {
  print("CSS file changed, applying new styles...");
  app.reset_css();
  app.apply_css(CSS_PATH);
});

app.start({
  icons: `${SRC}/icons`,
  css: CSS_PATH,
  main() {
    const hyprland = AstalHyprland.get_default();
    const monitors = createBinding(hyprland, "monitors");
    return (
      <For
        cleanup={(elem, monitor, _idx) => {
          print(
            `[Bar] Destroy bar for monitor: ${monitor.name} (ID: ${monitor.id})`,
          );
          (elem as Gtk.Window).destroy();
        }}
        each={monitors}
      >
        {(monitor) => <Bar monitor={monitor} />}
      </For>
    );
  },
});
