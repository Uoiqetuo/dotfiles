const Gtk = imports.gi.Gtk;
const Gio = imports.gi.Gio;
import battery from "./battery.js";
import clock from "./clock.js";
import volume from "./volume.js";
import workspaces from "./workspaces.js";
import systemTray from "./systemTray.js";
import test from "./test.js";

const widgetOrder = {
    left: [
        // clock(),
        test()
    ],
    center: [
        // clock(),
        // battery()
        workspaces()
    ],
    right: [
        systemTray(),
        volume(),
        battery(),
        clock()
    ]
}

const left = () => {
    return Widget.Box({
        name: "left",
        halign: Gtk.Align.START,
        children: widgetOrder.left
    })
}

const center = () => {
    return Widget.Box({
        name: "center",
        halign: Gtk.Align.CENTER,
        children: widgetOrder.center
    })
}

const right = () => {
    return Widget.Box({
        name: "right",
        halign: Gtk.Align.END,
        children: widgetOrder.right
    })
}

const bar = () => {
    const bar = Widget.Window({
        // monitor: 1,
        name: "bar",
        anchor: ["top", "left", "right"],
        exclusivity: "exclusive",
        child: Widget.CenterBox({
            startWidget: left(),
            centerWidget: center(),
            endWidget: right()
        })
    })

    return bar
}

export default bar;

