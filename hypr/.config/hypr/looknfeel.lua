-- Change the default Omarchy look'n'feel.

-- https://wiki.hypr.land/Configuring/Basics/Variables/#general
hl.config({
  general = {
    -- No gaps between windows or borders.
    gaps_in = 0,
    gaps_out = 0,
    border_size = 1,

    -- Change to niri-like side-scrolling layout.
    -- layout = "scrolling",
  },
})

-- https://wiki.hypr.land/Configuring/Basics/Variables/#decoration
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,

    -- Omarchy disables blur; enable it for the glass OSD. Windows are forced
    -- opaque below, so they get no visible blur.
    blur = { enabled = true, size = 8, passes = 3 },
  },
})

-- https://wiki.hypr.land/Configuring/Basics/Variables/#animations
hl.config({
  animations = {
    -- Disable all animations.
    enabled = false,
  },
})

-- Omarchy applies slight transparency (opacity 0.985/0.96) to every window by
-- default. Keep everything fully opaque instead.
o.window(".*", { tag = "-default-opacity", opacity = "1 1" })

-- Hide the border and rounding when a window is the only tiled window on its workspace.
hl.window_rule({ match = { float = false, workspace = "w[tv1]" }, border_size = 0, rounding = 0 })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#layout
-- hl.config({
--   layout = {
--     -- Avoid overly wide single-window layouts on wide screens.
--     single_window_aspect_ratio = { 1, 1 },
--   },
-- })

-- https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/
-- hl.config({
--   scrolling = {
--     -- See only one column per screen instead of two.
--     column_width = 0.97,
--   },
-- })

-- Frosted-glass OSD (matthias.osd): blur behind the translucent card only.
-- ignore_alpha skips the fully transparent rest of the fullscreen layer.
hl.layer_rule({ match = { namespace = "omarchy-osd" }, blur = true, ignore_alpha = 0.1 })
