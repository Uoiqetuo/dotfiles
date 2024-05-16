const batteryService = await Service.import("battery");
const { merge } = Utils;

const charging = merge(
    [batteryService.bind("charging"), batteryService.bind("charged")],
    (a, b) => a || b
)

App.addIcons(`${App.configDir}/assets/icons`)

function getColorInRange(value) {
    const colorMap = {
        51: "#34C759",
        16: "#FFCC0A",
        0: "#FFCC0A",
    };

    const index = Object.keys(colorMap)
        .sort()
        .reverse()
        .map(Number)
        .find(threshold => threshold <= value);

    return colorMap[index] ?? "white";
}

const battery = () => {
    if (!batteryService.bind("available")) return;

    const isLabelEnable = Variable(false);

    const battIcon = Widget.Icon({
        classNames: ["icon-container"],
        name: "battery",
        // icon: 'battery-vertical-empty-symbolic',
        icon: charging.as(v =>
            v ? "battery-charging-vertical-symbolic" : "battery-vertical-empty-symbolic"
        ),
    });

    const batteryLevelBar = Widget.LevelBar({
        name: "battery-level-bar",
        classNames: ["icon-container"],
        vertical: true,
        inverted: true,
        value: batteryService.bind("percent"),
        // value: 100,
        maxValue: 100,
        css: batteryService.bind("percent")
            .as(value =>
                `.filled {background-color: ${getColorInRange(value)};}`
            ),
    })

    const icon = Widget.Overlay({
        passThrough: true,
        child: Widget.Icon({ 
            classNames: ["icon-container"]
        }),
        overlays: [
            batteryLevelBar,
            battIcon,
        ],
    })

    const percentLabel = Widget.Revealer({
        revealChild: false,
        transition: "slide_right",
        transitionDuration: 150,
        child: Widget.Label({
            className: "label-revealer-container",
            label: batteryService.bind("percent").as(v => `${v}%`)
        }),
        setup: self => {
            self.hook(isLabelEnable, self => {
                self.revealChild = isLabelEnable.value;
            })
        }
    })


    const ret = Widget.EventBox({
        onPrimaryClick: (event) => {
            // console.log(batteryService.percent);
            // console.log(event);
        },
        child: Widget.Box({
            classNames: ["bar-item-container"],
            children: [
                percentLabel,
                icon
            ],
            // tooltip_text: batteryService.bind("percent").as(v => `${v}%`)
        }),
        setup: (self) => {
            self
                .on("leave-notify-event", () => {
                    // console.log("hide battery label");
                    setTimeout(() => {
                        isLabelEnable.value = false;
                    }, 500);
                })
                // .on("enter-notify-event", () => {
                //     isHover.value = true;
                //     console.log("hover");
                // })
                .on("button-press-event", () => {
                    if (isLabelEnable.value) {
                        isLabelEnable.value = false;
                        // console.log("hide battery label");
                    } else {
                        isLabelEnable.value = true;
                        // console.log("show battery label");
                    }
                })
        },
    });

    return ret;
}

// find /usr/share/icons -type f -name '*.png' -o -name '*.svg' -o -name '*.xpm'
// find /usr/share/pixmaps -type f

export default battery;