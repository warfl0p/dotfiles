-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")

-- Application bindings
o.bind("SUPER + B", "Chrome (default profile)", { launch = 'google-chrome-stable --profile-directory="Default"' })

hl.unbind("SUPER + SHIFT + B") -- was: Browser
o.bind("SUPER + SHIFT + B", "Chrome (profile 1)", { launch = 'google-chrome-stable --profile-directory="Profile 1"' })

hl.unbind("SUPER + SHIFT + S") -- was: Google Maps
o.bind("SUPER + SHIFT + S", "Music", { omarchy = "spotify" })

o.bind("SUPER + SHIFT + T", "Activity", { tui = "btop" })

hl.unbind("SUPER + SHIFT + C") -- was: Calendar (hey.com webapp)
o.bind("SUPER + SHIFT + C", "Calendar", "omarchy-launch-or-focus dcal")

-- Move Omarchy menu to Super + Ctrl + D.
hl.unbind("SUPER + CTRL + D") -- was: Display panel
o.bind("SUPER + CTRL + D", "Omarchy menu", "omarchy-menu")

-- Bind Super+D to the Omarchy Quattro apps menu (Walker was removed in the
-- Quattro upgrade), and repurpose Super+Space/Super+Alt+Space for monitor
-- scripts.
hl.unbind("SUPER + D") -- was: unbound
o.bind("SUPER + D", "Apps menu", "omarchy-menu toggle apps")

hl.unbind("SUPER + SPACE") -- was: Omarchy menu
o.bind("SUPER + SPACE", nil, "~/.config/hypr/scripts/monitor_auto_move.sh")

hl.unbind("SUPER + ALT + SPACE") -- was: Apps menu
o.bind("SUPER + ALT + SPACE", nil, "~/.config/hypr/scripts/enable_laptop_profile.sh")

-- Overwrite Share to launch workspace apps instead.
hl.unbind("SUPER + CTRL + S") -- was: Share menu
o.bind("SUPER + CTRL + S", "Launch workspace apps", "~/.local/bin/launch-workspace-apps")

-- Move Keybindings cheatsheet to Super+Ctrl+K (was Herdr keybindings), since
-- Super+K is repurposed below for vim-style focus movement.
hl.unbind("SUPER + CTRL + K") -- was: Herdr keybindings
o.bind("SUPER + CTRL + K", "Keybindings", "omarchy-menu-keybindings")

-- Move focus with SUPER + vim keys.
hl.unbind("SUPER + L") -- was: Toggle workspace layout
hl.unbind("SUPER + J") -- was: Toggle window split
hl.unbind("SUPER + K") -- was: Keybindings
o.bind("SUPER + H", "Move focus left", hl.dsp.focus({ direction = "l" }))
o.bind("SUPER + L", "Move focus right", hl.dsp.focus({ direction = "r" }))
o.bind("SUPER + K", "Move focus up", hl.dsp.focus({ direction = "u" }))
o.bind("SUPER + J", "Move focus down", hl.dsp.focus({ direction = "d" }))

o.bind("SUPER + SHIFT + H", "Swap window to the left", hl.dsp.window.swap({ direction = "l" }))
o.bind("SUPER + SHIFT + L", "Swap window to the right", hl.dsp.window.swap({ direction = "r" }))
o.bind("SUPER + SHIFT + K", "Swap window up", hl.dsp.window.swap({ direction = "u" }))
o.bind("SUPER + SHIFT + J", "Swap window down", hl.dsp.window.swap({ direction = "d" }))

-- Use SUPER+TAB for group cycling instead of workspace switching, freeing
-- SUPER+ALT+TAB (which no longer needs to do group cycling).
hl.unbind("SUPER + TAB") -- was: Next workspace
hl.unbind("SUPER + SHIFT + TAB") -- was: Previous workspace
hl.unbind("SUPER + CTRL + TAB") -- was: Former workspace
hl.unbind("SUPER + ALT + TAB") -- was: Next window in group
hl.unbind("SUPER + ALT + SHIFT + TAB") -- was: Previous window in group
o.bind("SUPER + TAB", "Next window in group", hl.dsp.group.next())
o.bind("SUPER + SHIFT + TAB", "Previous window in group", hl.dsp.group.prev())
