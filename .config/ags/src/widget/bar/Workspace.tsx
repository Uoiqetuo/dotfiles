import { createBinding, createComputed, For } from "ags"
import { Gtk } from "ags/gtk4";
import AstalHyprland from "gi://AstalHyprland?version=0.1"

export default function Workspace() {
  const hyprland = AstalHyprland.get_default()!
  const workspaces = createBinding(hyprland, "workspaces")
    .as((ws => {
      return ws.slice().sort((a, b) => {
        const aIsSpecial = a.name?.startsWith("special");
        const bIsSpecial = b.name?.startsWith("special");
        if (aIsSpecial && !bIsSpecial) return 1;
        if (!aIsSpecial && bIsSpecial) return -1;
        return a.id - b.id;
      });
    }
  ));
  const focusedWorkspace = createBinding(hyprland, "focusedWorkspace");
  
  const onWorkspaceClick = (ws: AstalHyprland.Workspace) => {
    if (ws.name?.startsWith("special")) {
      hyprland.dispatch("togglespecialworkspace", "magic");
      return;
    };
    if (ws.id === focusedWorkspace()?.id) return;
    hyprland.dispatch("workspace", ws.id.toString());
  }

  return (
    <box cssClasses={["workspace", "widget"]} spacing={4}>
      <For each={workspaces} >
        {(ws) => (
          <box>
            <Gtk.GestureClick
              onPressed={() =>onWorkspaceClick(ws)}
            />
            <label
              halign={Gtk.Align.CENTER}
              label={ws.name.startsWith("special") ? "S" : ws.id.toString()}
              cssClasses={createComputed(() => ["workspace-item", ws.name === focusedWorkspace()?.name ? "active" : ""])}
            />
          </box>
        )}
      </For>
    </box>
  )
}