-- ╔══════════════════════════════════════════════════════════╗
-- ║              WezTerm Configuration                       ║
-- ║  Font: JetBrains Mono 16 | Fullscreen F11 | Modern UI   ║
-- ╚══════════════════════════════════════════════════════════╝

local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- ─────────────────────────────────────────
-- FONT
-- ─────────────────────────────────────────
config.font = wezterm.font("JetBrains Mono", { weight = "Regular" })
config.font_size = 16.0
config.line_height = 1.2
config.cell_width = 1.0

-- Fallback fonts for symbols/icons (used by Starship prompt)
config.font_rules = {
	{
		intensity = "Bold",
		font = wezterm.font("JetBrains Mono", { weight = "Bold" }),
	},
	{
		intensity = "Half",
		font = wezterm.font("JetBrains Mono", { weight = "Light" }),
	},
}

-- ─────────────────────────────────────────
-- COLOUR SCHEME  (Catppuccin Mocha — modern dark)
-- ─────────────────────────────────────────
config.color_scheme = "Catppuccin Mocha"

-- Fine-tune window background opacity for a subtle depth effect
config.window_background_opacity = 0.92
config.text_background_opacity = 1.0

-- Windows alternatives (keep commented unless running on Windows)
-- config.win32_system_backdrop = "Mica"
-- config.win32_system_backdrop = "Acrylic"

-- ─────────────────────────────────────────
-- WINDOW APPEARANCE
-- ─────────────────────────────────────────
config.window_decorations = "RESIZE" -- hide title bar, keep resize border
config.window_padding = {
	left = 7,
	right = 7,
	top = 5,
	bottom = 5,
}
config.initial_cols = 220
config.initial_rows = 50

-- Tab bar
config.enable_tab_bar = true
config.use_fancy_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = false
config.tab_max_width = 32

-- ─────────────────────────────────────────
-- CURSOR
-- ─────────────────────────────────────────
config.default_cursor_style = "BlinkingBar"
config.cursor_blink_rate = 500
config.cursor_blink_ease_in = "Linear"
config.cursor_blink_ease_out = "Linear"

-- ─────────────────────────────────────────
-- SCROLLBACK
-- ─────────────────────────────────────────
config.scrollback_lines = 10000
config.enable_scroll_bar = false

-- ─────────────────────────────────────────
-- MOUSE / COPY-PASTE
-- ─────────────────────────────────────────
-- Right-click: paste if clipboard has text, else open context menu
config.mouse_bindings = {
	-- Right-click pastes from clipboard
	{
		event = { Down = { streak = 1, button = "Right" } },
		mods = "NONE",
		action = wezterm.action.PasteFrom("Clipboard"),
	},
	-- Middle-click pastes from primary selection
	{
		event = { Down = { streak = 1, button = "Middle" } },
		mods = "NONE",
		action = wezterm.action.PasteFrom("PrimarySelection"),
	},
	-- Left double-click selects a word and copies to clipboard
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "NONE",
		action = wezterm.action.CompleteSelectionOrOpenLinkAtMouseCursor("ClipboardAndPrimarySelection"),
	},
}

-- Copy on select (Linux behaviour)
config.selection_word_boundary = " \t\n{}[]()\"'`,;:|"

-- ─────────────────────────────────────────
-- KEY BINDINGS
-- ─────────────────────────────────────────
local act = wezterm.action

config.keys = {
	-- ── Fullscreen toggle ──────────────────
	{
		key = "F11",
		mods = "NONE",
		action = act.ToggleFullScreen,
	},

	-- ── Copy / Paste ───────────────────────
	{ key = "c", mods = "CTRL|SHIFT", action = act.CopyTo("Clipboard") },
	{ key = "v", mods = "CTRL|SHIFT", action = act.PasteFrom("Clipboard") },

	-- ── Tabs ───────────────────────────────
	{ key = "t", mods = "CTRL|SHIFT", action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "w", mods = "CTRL|SHIFT", action = act.CloseCurrentTab({ confirm = true }) },
	{ key = "Tab", mods = "CTRL", action = act.ActivateTabRelative(1) },
	{ key = "Tab", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(-1) },

	-- ── Tab bar toggle (Alt+B) ─────────────

	{
		key = "b",
		mods = "ALT",
		action = wezterm.action_callback(function(window, _)
			local overrides = window:get_config_overrides() or {}
			if overrides.hide_tab_bar_if_only_one_tab == true then
				-- Currently hidden — show it
				overrides.hide_tab_bar_if_only_one_tab = false
				overrides.enable_tab_bar = true
				overrides.use_fancy_tab_bar = true
			else
				-- Currently visible — hide it
				overrides.hide_tab_bar_if_only_one_tab = true
				overrides.enable_tab_bar = true
				overrides.use_fancy_tab_bar = false
			end
			window:set_config_overrides(overrides)
		end),
	},

	-- ── Pane splitting ─────────────────────
	{ key = "\\", mods = "CTRL|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "-", mods = "CTRL|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "h", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Left") },
	{ key = "l", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Right") },
	{ key = "k", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Up") },
	{ key = "j", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Down") },

	-- ── Font size ──────────────────────────
	{ key = "=", mods = "CTRL", action = act.IncreaseFontSize },
	{ key = "-", mods = "CTRL", action = act.DecreaseFontSize },
	{ key = "0", mods = "CTRL", action = act.ResetFontSize },

	-- ── Search ─────────────────────────────
	{ key = "f", mods = "CTRL|SHIFT", action = act.Search({ CaseInSensitiveString = "" }) },
}

-- ─────────────────────────────────────────
-- PERFORMANCE
-- ─────────────────────────────────────────
config.front_end = "WebGpu" -- GPU-accelerated rendering
config.webgpu_power_preference = "HighPerformance"
config.animation_fps = 60
config.max_fps = 60

-- ─────────────────────────────────────────
-- BELL
-- ─────────────────────────────────────────
config.audible_bell = "Disabled"
config.visual_bell = {
	fade_in_duration_ms = 75,
	fade_out_duration_ms = 75,
	target = "CursorColor",
}

return config
