-- https://wiki.hypr.land/Configuring/Basics/Autostart/

hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.exec_cmd("hyprlauncher -d")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("fcitx5")
    hl.exec_cmd("ags run")
end)
