-- Keep only your personal input overrides here. Uncommented settings below
-- replace Omarchy's defaults.

-- Keyboard layout and options.
-- See https://wiki.hypr.land/Configuring/Basics/Variables/#input
-- hl.config({
--   input = {
--     -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt.
--     kb_layout = "us,dk,eu",
--     kb_options = "compose:caps,shift:both_capslock_cancel,grp:alts_toggle",
--
--     -- Use a specific keyboard variant if needed (e.g. intl for international keyboards).
--     kb_variant = "intl",
--
--     -- Change speed of keyboard repeat.
--     repeat_rate = 40,
--     repeat_delay = 250,
--
--     -- Start with numlock on by default.
--     numlock_by_default = true,
--
--     -- Increase sensitivity for mouse/trackpad (default: 0).
--     sensitivity = 0.35,
--
--     -- Turn off mouse acceleration (default: adaptive).
--     accel_profile = "flat",
--
--     touchpad = {
--       -- Enable the touchpad while typing.
--       disable_while_typing = false,
--
--       -- Left-click-and-drag with three fingers.
--       drag_3fg = 1,
--     },
--   },
-- })

hl.config({
  input = {
    -- Windows-style scrolling, not Mac-style reversed scrolling.
    natural_scroll = false,

    -- Reduce mouse/trackpad sensitivity (default: 0).
    sensitivity = -0.2,

    -- Focus follows click, not mouse hover.
    follow_mouse = 0,

    -- Longer initial delay before key repeat starts (default: 250).
    repeat_delay = 600,

    touchpad = {
      -- This touchpad's natural_scroll behaves inverted from usual: true
      -- gives traditional/Windows-style scrolling on this hardware, not
      -- Mac-style.
      natural_scroll = true,

      -- Slower than Omarchy's default (0.4).
      scroll_factor = 0.3,
    },
  },
})

-- Enable touchpad gestures for changing workspaces.
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- App-specific touchpad scroll speeds.
-- o.window("(Alacritty|kitty|foot)", { scroll_touchpad = 1.5 })
-- o.window("com.mitchellh.ghostty", { scroll_touchpad = 0.2 })

-- Enable touchpad gestures for moving focus (helpful on scrolling layout).
-- hl.gesture({ fingers = 3, direction = "left", action = function() hl.dispatch(hl.dsp.focus({ direction = "l" })) end })
-- hl.gesture({ fingers = 3, direction = "right", action = function() hl.dispatch(hl.dsp.focus({ direction = "r" })) end })
