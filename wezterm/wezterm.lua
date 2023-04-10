local wezterm = require 'wezterm';

return {
  -- https://wezfurlong.org/wezterm/colorschemes/k/index.html
  color_scheme = "kanagawabones",
  term = "wezterm",
  -- https://wezfurlong.org/wezterm/config/lua/config/window_decorations.html
  window_decorations = "RESIZE",
  font = wezterm.font 'FiraCode Nerd Font Mono',
  font_size = 14,
  window_background_opacity = 1.0,
  keys = {
    -- Make Option-Left equivalent to Alt-b which many line editors interpret as backward-word
    { key = "LeftArrow", mods = "OPT", action = wezterm.action { SendString = "\x1bb" } },
    -- Make Option-Right equivalent to Alt-f; forward-word
    { key = "RightArrow", mods = "OPT", action = wezterm.action { SendString = "\x1bf" } },
  }
}
