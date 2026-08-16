-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

local omarchy_gdk_scale = 1.5
local omarchy_monitor_scale = 1.5

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })

-- Configure a specific monitor.
-- hl.monitor({ output = "DP-2", mode = "2560x1440@144", position = "0x0", scale = 1 })

-- Portrait/rotated secondary monitor (transform: 1 = 90°, 3 = 270°).
-- hl.monitor({ output = "DP-2", mode = "preferred", position = "auto", scale = 1, transform = 1 })

-- Laptop panel + docked external monitor.
hl.monitor({ output = "eDP-1", mode = "2880x1800@120.00", position = "-1x-1", scale = 1.5 })
hl.monitor({ output = "HDMI-A-1", mode = "3440x1440@99.98", position = "1919x0", scale = 1.0 })

-- Workspace to monitor mapping.
hl.workspace_rule({ workspace = "1", monitor = "eDP-1" })
for workspace = 2, 9 do
  hl.workspace_rule({ workspace = tostring(workspace), monitor = "HDMI-A-1" })
end
