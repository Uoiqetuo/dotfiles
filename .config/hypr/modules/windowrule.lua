-- https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

hl.window_rule({
    name         = "focus-hyprpolkitagent-prompt",
    match        = {
        class = "^hyprpolkitagent$",
    },

    stay_focused = true,
})

hl.window_rule({
    name = "focus-kwallet-access-prompt",
    match = {
        class = "org.kde.ksecretd",
    },

    float = true,
    stay_focused = true,
})

hl.layer_rule({
    name = "notifications",
    match = {
        namespace = "notifications",
    },

    no_screen_share = true,

    animation = "slide right",
    blur = true,
    ignore_alpha = 0.1,
})

hl.layer_rule({
    name = "side-panel",
    match = {
        namespace = "qs-side-panel",
    },

    animation = "slide right",
    dim_around = true,
})
