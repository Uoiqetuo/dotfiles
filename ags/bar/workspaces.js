const hyprland = await Service.import("hyprland");
const { Gtk } = imports.gi;

const MAX_WORKSPACE_NUM = 10;

const workspaces = () => {
    const activeId = hyprland.active.workspace.bind("id");
    const workspaces = hyprland.bind("workspaces").as((wss) => 
        wss.sort((a, b) => a.id - b.id).map((ws) => {
            // console.log(ws);
            if (ws.id < 1 || ws.id > MAX_WORKSPACE_NUM) {
                ws.id = "S"
            }
            return Widget.EventBox({
                onPrimaryClick: (event) => {
                    console.log(`change to ws ${ws.id}`);
                    hyprland.messageAsync(`dispatch workspace ${ws.id}`)
                },
                child: Widget.Box({
                    classNames: activeId
                    .as(i => `${i === ws.id ? "active" : ""}`)
                    .as((v) => [v, "workspace-box"]),
                    child: Widget.Label({
                        halign: Gtk.Align.CENTER,
                        hexpand: true,
                        label: `${ws.id}`,
                    })
                })
            })
        })
    )

    const ret = Widget.EventBox({
        child: Widget.Box({
            classNames: ["workspaces"],
            children: workspaces,
        }),
    });

    return ret;
}

export default workspaces;