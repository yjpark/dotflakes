local wezterm = require 'wezterm'
local act = wezterm.action

return {
    enable_wayland = true,
    --window_decorations = 'INTEGRATED_BUTTONS|RESIZE',
    font = wezterm.font 'FiraCode Nerd Font Mono',
    font_dirs = { '/run/current-system/sw/share/X11/fonts' },
    color_scheme = "Molokai",
    hide_tab_bar_if_only_one_tab = false,
    keys = {
        { key = 'w',          mods = 'CTRL|SHIFT', action = act.CloseCurrentTab { confirm = false }, },
        { key = '1',          mods = 'CTRL',       action = act.ActivateTab(0), },
        { key = '2',          mods = 'CTRL',       action = act.ActivateTab(1), },
        { key = '3',          mods = 'CTRL',       action = act.ActivateTab(2), },
        { key = '4',          mods = 'CTRL',       action = act.ActivateTab(3), },
        { key = '5',          mods = 'CTRL',       action = act.ActivateTab(4), },
        { key = '6',          mods = 'CTRL',       action = act.ActivateTab(5), },
        { key = '7',          mods = 'CTRL',       action = act.ActivateTab(6), },
        { key = '8',          mods = 'CTRL',       action = act.ActivateTab(7), },
        { key = '9',          mods = 'CTRL',       action = act.ActivateTab(8), },
        { key = '0',          mods = 'CTRL',       action = act.ActivateTab(9), },
        { key = '1',          mods = 'CTRL|ALT',   action = act.MoveTab(0), },
        { key = '2',          mods = 'CTRL|ALT',   action = act.MoveTab(1), },
        { key = '3',          mods = 'CTRL|ALT',   action = act.MoveTab(2), },
        { key = '4',          mods = 'CTRL|ALT',   action = act.MoveTab(3), },
        { key = '5',          mods = 'CTRL|ALT',   action = act.MoveTab(4), },
        { key = '6',          mods = 'CTRL|ALT',   action = act.MoveTab(5), },
        { key = '7',          mods = 'CTRL|ALT',   action = act.MoveTab(6), },
        { key = '8',          mods = 'CTRL|ALT',   action = act.MoveTab(7), },
        { key = '9',          mods = 'CTRL|ALT',   action = act.MoveTab(8), },
        { key = '0',          mods = 'CTRL|ALT',   action = act.MoveTab(9), },
        { key = 'LeftArrow',  mods = 'CTRL|ALT',   action = act.MoveTabRelative(-1) },
        { key = 'RightArrow', mods = 'CTRL|ALT',   action = act.MoveTabRelative(1) },
        {
            key = 'c',
            mods = 'CTRL',
            action = wezterm.action_callback(function(window, pane)
                local has_selection = window:get_selection_text_for_pane(pane) ~= ""
                if has_selection then
                    window:perform_action(
                        wezterm.action { CopyTo = "ClipboardAndPrimarySelection" },
                        pane)
                    window:perform_action("ClearSelection", pane)
                else
                    window:perform_action(
                        wezterm.action { SendKey = { key = "c", mods = "CTRL" } },
                        pane)
                end
            end),
        },
        {
            key = "c",
            mods = "SHIFT|ALT",
            action = wezterm.action { SendKey = { key = "c", mods = "CTRL" } }
        },
        {
            key = "v",
            mods = "CTRL",
            action = act.PasteFrom 'Clipboard',
        },
        {
            key = "v",
            mods = "SHIFT|ALT",
            action = wezterm.action { SendKey = { key = "v", mods = "CTRL" } },
        },
        { key = 't', mods = 'CTRL', action = act.SpawnTab 'CurrentPaneDomain', },
    },
}
