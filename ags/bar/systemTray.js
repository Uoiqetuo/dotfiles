const systemtray = await Service.import("systemtray");

const CUSTOM_TRAY_ICONS = {
    // "fcitx-mcbopomofo": 
    "input-keyboard-symbolic": "keyboard-symbolic",
    "blueman-tray": "bluetooth-symbolic",
    "blueman-disabled": "bluetooth-x-symbolic",
    "blueman-active": "bluetooth-connected-symbolic",
};


const systemTray = () => {
    console.log(systemtray.items);
    const items = systemtray.bind("items").as((items) => {
        console.log(items);
        return items.map((item) => {
            console.log(item.icon);
            return Widget.EventBox({
                onPrimaryClick: (_, event) => item.activate(event),
                onSecondaryClick: (_, event) => item.openMenu(event),
                tooltipMarkup: item.bind("tooltip_markup"),
                child: Widget.Icon({
                    classNames: ["icon-container", "bar-item-container"],
                    // FIX: use custom icon can't change on signal 
                    // icon: item.icon in CUSTOM_TRAY_ICONS ? CUSTOM_TRAY_ICONS[item.icon]: item.bind("icon")
                    icon: item.bind("icon")
                }),
            })
        })
    });

    const ret = Widget.EventBox({
        child: Widget.Box({
            classNames: [],
            children: items,
        }),
    });

    return ret;
};

export default systemTray;