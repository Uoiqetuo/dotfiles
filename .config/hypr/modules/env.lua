-- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

-- nvidia
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("CUDA_DISABLE_PERF_BOOST", "1")
hl.env("NVD_BACKEND", "direct")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("GBM_BACKEND", "nvidia-drm")
hl.env("__GL_MaxFramesAllowed", "1")
hl.env("VDPAU_DRIVER", "nvidia")

-- fcitx5
hl.env("XMODIFIERS", "@im=fcitx")
hl.env("QT_IM_MODULE", "fcitx")
hl.env("QT_IM_MODULES", "wayland;fcitx")
hl.env("GTK_IM_MODULE", "fcitx")

-- GTK
hl.env("GDK_BACKEND", "wayland,x11,*")

-- Qt
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")

hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
