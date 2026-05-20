-- 螢幕
-- https://wiki.hypr.land/Configuring/Basics/Monitors/

hl.monitor({
    output = "DP-1",
    mode = "2560x1440@165",
    position = "1920x0",
    scale = 1.25,
    -- cm = "hdr",

    disabled = false,
})

hl.monitor({
    output = "HDMI-A-1",
    mode = "1920x1080@75",
    position = "0x400",
    scale = 1,

    disabled = false,
})

hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})

-- 其他裝置
-- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/

hl.device({
    name = "asustek-rog-omni-receiver",
    sensitivity = -0.65,
})
