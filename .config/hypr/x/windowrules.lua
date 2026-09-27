-- Ref https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
-- "Smart gaps" / "No gaps when only"
-- uncomment all if you wish to use that.
-- hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
-- hl.workspace_rule({ workspace = "f[1]",   gaps_out = 0, gaps_in = 0 })
-- hl.window_rule({
--     name  = "no-gaps-wtv1",
--     match = { float = false, workspace = "w[tv1]" },
--     border_size = 0,
--     rounding    = 0,
-- })
-- hl.window_rule({
--     name  = "no-gaps-f1",
--     match = { float = false, workspace = "f[1]" },
--     border_size = 0,
--     rounding    = 0,
-- })
-- Satty screenshot editor overlay
hl.window_rule({
    name  = "satty-overlay",
    match = {
        class = ".*satty.*",
    },

    -- Tells Hyprland to make the window float
    float = true,
})

-- Floating utility dialogs
hl.window_rule({
    name  = "float-pavucontrol",
    match = { class = ".*pavucontrol.*" },
    float = true,
    center = true,
    size = "1000 650",
})

hl.window_rule({
    name  = "float-nm-editor",
    match = { class = "^(nm-connection-editor)$" },
    float = true,
    center = true,
    size = "900 550",
})

hl.window_rule({
    name  = "float-file-roller",
    match = { class = "^(org.gnome.FileRoller)$" },
    float = true,
    center = true,
    size = "1000 600",
})

hl.window_rule({
    name  = "float-blueman",
    match = { class = "^(blueman-manager)$" },
    float = true,
    center = true,
    size = "900 550",
})

-- Browser PiP
hl.window_rule({
    name  = "float-pip",
    match = { title = "^(Picture-in-Picture)$" },
    float = true,
    pin   = true,
    size = "800 450",
})

-- App → workspace (silent = open there without stealing focus)
-- Comment out any you don't want pinned to a workspace
hl.window_rule({
    name  = "ws-zen",
    match = { class = "^(zen|zen-browser)$" },
    workspace = "1 silent",
})

hl.window_rule({
    name  = "ws-obsidian",
    match = { class = "^(obsidian|md.obsidian.Obsidian)$" },
    workspace = "3 silent",
})

hl.window_rule({
    name  = "ws-telegram",
    match = { class = "^(org.telegram.desktop|TelegramDesktop)$" },
    workspace = "5 silent",
})


-------- layers rules ----------
hl.layer_rule({
    name  = "no-anim-selection",
    match = { namespace = "selection" },
    no_anim = true,
})

hl.layer_rule({
    match = { namespace = "logout_dialog" },
    blur = true,
    ignore_alpha = 0.0,

})


hl.layer_rule({
    match = { namespace = "swaync-control-center" },
    blur = true,
    ignore_alpha = 0.5,

})



hl.layer_rule({
    match = { namespace = "waybar" },
    blur = true,
    ignore_alpha = 0.5,

})











hl.layer_rule({
    match = { namespace = "swaync-notification-window" },
    blur = true,
    ignore_alpha = 0.5,

})





hl.layer_rule({
    match = { tag = "notif*" },
    ignore_alpha = 0.3,
})







   hl.layer_rule({
       match = { namespace = "rofi" },
       blur = true,
       ignore_alpha = 0.0,
       --dim_around = true,
   animation = "popin 80%",
 })













--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Example window rules that are useful

local suppressMaximizeRule = hl.window_rule({
    -- Ignore maximize requests from all apps. You'll probably like this.
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})
-- suppressMaximizeRule:set_enabled(false)

hl.window_rule({
    -- Fix some dragging issues with XWayland
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

-- Layer rules also return a handle.
-- local overlayLayerRule = hl.layer_rule({
--     name  = "no-anim-overlay",
--     match = { namespace = "^my-overlay$" },
--     no_anim = true,
-- })
-- overlayLayerRule:set_enabled(false)

-- Hyprland-run windowrule
hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },

    move  = "20 monitor_h-120",
    float = true,
})
