-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- custom libraries
local LeftBar = require("bars.LeftBar")
local vicious = require("vicious")
local modules = require("modules.taglist")
local widgets = require("widgets.widgets")
local popups = require("popup.popups")
local icon_tray = require("icon_tray.icon")
local rcnf = require("rice_config")
local username = os.getenv("USER") or os.getenv("USERNAME")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- Load Debian menu entries
local debian = require("debian.menu")
local has_fdo, freedesktop = pcall(require, "freedesktop")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({
        preset = naughty.config.presets.critical,
        title = "Oops, there were errors during startup!",
        text = awesome.startup_errors
    })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function(err)
        -- Make sure we don't go into an endless error loop
        if in_error then
            return
        end
        in_error = true

        naughty.notify({
            preset = naughty.config.presets.critical,
            title = "Oops, an error happened!",
            text = tostring(err)
        })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "alacritty"
editor = os.getenv("EDITOR") or "editor"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {awful.layout.suit.floating, awful.layout.suit.tile, awful.layout.suit.tile.left,
                        awful.layout.suit.tile.bottom, awful.layout.suit.tile.top, awful.layout.suit.fair,
                        awful.layout.suit.fair.horizontal, awful.layout.suit.spiral, awful.layout.suit.spiral.dwindle,
                        awful.layout.suit.max, awful.layout.suit.max.fullscreen, awful.layout.suit.magnifier,
                        awful.layout.suit.corner.nw -- awful.layout.suit.corner.ne,
-- awful.layout.suit.corner.sw,
-- awful.layout.suit.corner.se,
}
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {{"hotkeys", function()
    hotkeys_popup.show_help(nil, awful.screen.focused())
end}, {"manual", terminal .. " -e man awesome"}, {"edit config", editor_cmd .. " " .. awesome.conffile},
                 {"restart", awesome.restart}, {"quit", function()
    awesome.quit()
end}}

local menu_awesome = {"awesome", myawesomemenu, beautiful.awesome_icon}
local menu_terminal = {"open terminal", terminal}

if has_fdo then
    mymainmenu = freedesktop.menu.build({
        before = {menu_awesome},
        after = {menu_terminal}
    })
else
    mymainmenu = awful.menu({
        items = {menu_awesome, {"Debian", debian.menu.Debian_menu.Debian}, menu_terminal}
    })
end

mylauncher = awful.widget.launcher({
    image = beautiful.awesome_icon,
    menu = mymainmenu
})

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock()

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(awful.button({}, 1, function(t)
    t:view_only()
end), awful.button({modkey}, 1, function(t)
    if client.focus then
        client.focus:move_to_tag(t)
    end
end), awful.button({}, 3, awful.tag.viewtoggle), awful.button({modkey}, 3, function(t)
    if client.focus then
        client.focus:toggle_tag(t)
    end
end), awful.button({}, 4, function(t)
    awful.tag.viewnext(t.screen)
end), awful.button({}, 5, function(t)
    awful.tag.viewprev(t.screen)
end))

local tasklist_buttons = gears.table.join(awful.button({}, 1, function(c)
    if c == client.focus then
        c.minimized = true
    else
        c:emit_signal("request::activate", "tasklist", {
            raise = true
        })
    end
end), awful.button({}, 3, function()
    awful.menu.client_list({
        theme = {
            width = 250
        }
    })
end), awful.button({}, 4, function()
    awful.client.focus.byidx(1)
end), awful.button({}, 5, function()
    awful.client.focus.byidx(-1)
end))

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
    awful.tag({"+"}, s, awful.layout.layouts[1])

end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(awful.button({}, 3, function()
    mymainmenu:toggle()
end), awful.button({}, 4, awful.tag.viewnext), awful.button({}, 5, awful.tag.viewprev)))
-- }}}
-- {{{ Key bindings
globalkeys = gears.table.join(awful.key({modkey}, "h", hotkeys_popup.show_help, {
    description = "show help",
    group = "awesome"
}), awful.key({modkey}, "Left", awful.tag.viewprev, {
    description = "view previous",
    group = "tag"
}), awful.key({modkey}, "Right", awful.tag.viewnext, {
    description = "view next",
    group = "tag"
}), awful.key({modkey}, "Escape", awful.tag.history.restore, {
    description = "go back",
    group = "tag"
}), awful.key({modkey}, "Tab", function()
    awful.client.focus.byidx(1)
end, {
    description = "focus next by index",
    group = "client"
}), awful.key({modkey, "Shift"}, "Tab", function()
    awful.client.focus.byidx(-1)
end, {
    description = "focus previous by index",
    group = "client"
}), awful.key({modkey}, "w", function()
    mymainmenu:show()
end, {
    description = "show main menu",
    group = "awesome"
}), awful.key({modkey}, "d", function()
    awful.spawn("rofi -show run")
end, {
    description = "show main menu",
    group = "awesome"
}), -- boi your custom bindings are here dont forget 
awful.key({modkey, "Shift"}, "s", function()
    awful.spawn("alacritty -e sudo openvpn /home/spidey/Downloads/Sp1d3y.ovpn")
end, {
    description = "show main menu",
    group = "awesome"
}), -- moving windows keybindings are here 
awful.key({modkey, "Shift"}, "Left", function()
    awful.client.swap.bydirection("left")
end, {
    description = "Move window to the left",
    group = "client"
}), awful.key({modkey, "Shift"}, "Right", function()
    awful.client.swap.bydirection("right")
end, {
    description = "Move window to the right",
    group = "client"
}), awful.key({modkey, "Shift"}, "Up", function()
    awful.client.swap.bydirection("up")
end, {
    description = "Move window up",
    group = "client"
}), awful.key({modkey, "Shift"}, "Down", function()
    awful.client.swap.bydirection("down")
end, {
    description = "Move window down",
    group = "client"
}), -- Layout manipulation
awful.key({modkey, "Shift"}, "j", function()
    awful.client.swap.byidx(1)
end, {
    description = "swap with next client by index",
    group = "client"
}), awful.key({modkey, "Shift"}, "k", function()
    awful.client.swap.byidx(-1)
end, {
    description = "swap with previous client by index",
    group = "client"
}), awful.key({modkey, "Control"}, "j", function()
    awful.screen.focus_relative(1)
end, {
    description = "focus the next screen",
    group = "screen"
}), awful.key({modkey, "Control"}, "k", function()
    awful.screen.focus_relative(-1)
end, {
    description = "focus the previous screen",
    group = "screen"
}), awful.key({modkey}, "u", awful.client.urgent.jumpto, {
    description = "jump to urgent client",
    group = "client"
}), awful.key({modkey}, "Tab", function()
    awful.client.focus.history.previous()
    if client.focus then
        client.focus:raise()
    end
end, {
    description = "go back",
    group = "client"
}), -- Standard program
awful.key({modkey}, "Return", function()
    awful.spawn(terminal)
end, {
    description = "open a terminal",
    group = "launcher"
}), awful.key({modkey, "Control"}, "r", awesome.restart, {
    description = "reload awesome",
    group = "awesome"
}), awful.key({modkey, "Shift"}, "q", awesome.quit, {
    description = "quit awesome",
    group = "awesome"
}), awful.key({modkey}, "l", function()
    awful.tag.incmwfact(0.05)
end, {
    description = "increase master width factor",
    group = "layout"
}), awful.key({modkey}, "h", function()
    awful.tag.incmwfact(-0.05)
end, {
    description = "decrease master width factor",
    group = "layout"
}), awful.key({modkey, "Shift"}, "h", function()
    awful.tag.incnmaster(1, nil, true)
end, {
    description = "increase the number of master clients",
    group = "layout"
}), awful.key({modkey, "Shift"}, "l", function()
    awful.tag.incnmaster(-1, nil, true)
end, {
    description = "decrease the number of master clients",
    group = "layout"
}), awful.key({modkey, "Control"}, "h", function()
    awful.tag.incncol(1, nil, true)
end, {
    description = "increase the number of columns",
    group = "layout"
}), awful.key({modkey, "Control"}, "l", function()
    awful.tag.incncol(-1, nil, true)
end, {
    description = "decrease the number of columns",
    group = "layout"
}), awful.key({modkey}, "space", function()
    awful.layout.inc(1)
end, {
    description = "select next",
    group = "layout"
}), awful.key({modkey, "Shift"}, "space", function()
    awful.layout.inc(-1)
end, {
    description = "select previous",
    group = "layout"
}), awful.key({modkey, "Control"}, "n", function()
    local c = awful.client.restore()
    -- Focus restored client
    if c then
        c:emit_signal("request::activate", "key.unminimize", {
            raise = true
        })
    end
end, {
    description = "restore minimized",
    group = "client"
}), -- Prompt
awful.key({modkey}, "r", function()
    awful.screen.focused().mypromptbox:run()
end, {
    description = "run prompt",
    group = "launcher"
}), awful.key({modkey}, "x", function()
    awful.prompt.run {
        prompt = "Run Lua code: ",
        textbox = awful.screen.focused().mypromptbox.widget,
        exe_callback = awful.util.eval,
        history_path = awful.util.get_cache_dir() .. "/history_eval"
    }
end, {
    description = "lua execute prompt",
    group = "awesome"
}), -- Menubar
awful.key({modkey}, "p", function()
    menubar.show()
end, {
    description = "show the menubar",
    group = "launcher"
}))

clientkeys = gears.table.join(awful.key({modkey}, "f", function(c)
    c.fullscreen = not c.fullscreen
    c:raise()
end, {
    description = "toggle fullscreen",
    group = "client"
}), awful.key({modkey, "Shift"}, "c", function(c)
    c:kill()
end, {
    description = "close",
    group = "client"
}), awful.key({modkey, "Control"}, "space", awful.client.floating.toggle, {
    description = "toggle floating",
    group = "client"
}), awful.key({modkey, "Control"}, "Return", function(c)
    c:swap(awful.client.getmaster())
end, {
    description = "move to master",
    group = "client"
}), awful.key({modkey}, "o", function(c)
    c:move_to_screen()
end, {
    description = "move to screen",
    group = "client"
}), awful.key({modkey}, "t", function(c)
    c.ontop = not c.ontop
end, {
    description = "toggle keep on top",
    group = "client"
}), awful.key({modkey}, "n", function(c)
    -- The client currently has the input focus, so it cannot be
    -- minimized, since minimized clients can't have the focus.
    c.minimized = true
end, {
    description = "minimize",
    group = "client"
}), awful.key({modkey}, "m", function(c)
    c.maximized = not c.maximized
    c:raise()
end, {
    description = "(un)maximize",
    group = "client"
}), awful.key({modkey, "Control"}, "m", function(c)
    c.maximized_vertical = not c.maximized_vertical
    c:raise()
end, {
    description = "(un)maximize vertically",
    group = "client"
}), awful.key({modkey, "Shift"}, "m", function(c)
    c.maximized_horizontal = not c.maximized_horizontal
    c:raise()
end, {
    description = "(un)maximize horizontally",
    group = "client"
}))

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys, -- View tag only.
    awful.key({modkey}, "#" .. i + 9, function()
        local screen = awful.screen.focused()
        local tag = screen.tags[i]
        if tag then
            tag:view_only()
        end
    end, {
        description = "view tag #" .. i,
        group = "tag"
    }), -- Toggle tag display.
    awful.key({modkey, "Control"}, "#" .. i + 9, function()
        local screen = awful.screen.focused()
        local tag = screen.tags[i]
        if tag then
            awful.tag.viewtoggle(tag)
        end
    end, {
        description = "toggle tag #" .. i,
        group = "tag"
    }), -- Move client to tag.
    awful.key({modkey, "Shift"}, "#" .. i + 9, function()
        if client.focus then
            local tag = client.focus.screen.tags[i]
            if tag then
                client.focus:move_to_tag(tag)
            end
        end
    end, {
        description = "move focused client to tag #" .. i,
        group = "tag"
    }), -- Toggle tag on focused client.
    awful.key({modkey, "Control", "Shift"}, "#" .. i + 9, function()
        if client.focus then
            local tag = client.focus.screen.tags[i]
            if tag then
                client.focus:toggle_tag(tag)
            end
        end
    end, {
        description = "toggle focused client on tag #" .. i,
        group = "tag"
    }))
end

clientbuttons = gears.table.join(awful.button({}, 1, function(c)
    c:emit_signal("request::activate", "mouse_click", {
        raise = true
    })
end), awful.button({modkey}, 1, function(c)
    c:emit_signal("request::activate", "mouse_click", {
        raise = true
    })
    awful.mouse.client.move(c)
end), awful.button({modkey, "Shift"}, 1, function(c)
    c:emit_signal("request::activate", "mouse_click", {
        raise = true
    })
    awful.mouse.client.resize(c)
end))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = { -- All clients will match this rule.
{
    rule = {},
    properties = {
        border_width = 2,
        focus = awful.client.focus.filter,
        raise = true,
        keys = clientkeys,
        buttons = clientbuttons,
        screen = awful.screen.preferred,
        placement = awful.placement.no_overlap + awful.placement.no_offscreen
    }
}, -- Floating clients.
{
    rule_any = {
        instance = {"DTA", -- Firefox addon DownThemAll.
        "copyq", -- Includes session name in class.
        "pinentry"},
        class = {"Arandr", "Blueman-manager", "Gpick", "Kruler", "MessageWin", -- kalarm.
        "Sxiv", "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
        "Wpa_gui", "veromix", "xtightvncviewer"},

        -- Note that the name property shown in xprop might be set slightly after creation of the client
        -- and the name shown there might not match defined rules here.
        name = {"Event Tester" -- xev.
        },
        role = {"AlarmWindow", -- Thunderbird's calendar.
        "ConfigManager", -- Thunderbird's about:config.
        "pop-up" -- e.g. Google Chrome's (detached) Developer Tools.
        }
    },
    properties = {
        floating = true
    }
}, -- Add titlebars to normal clients and dialogs
{
    rule_any = {
        type = {"normal", "dialog"}
    },
    properties = {
        titlebars_enabled = false
    }
}}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end
    c.shape = function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, 14) -- You can adjust the radius (8 in this example)
    end
    c.useless_gap_width = 10

    if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {
        raise = false
    })
end)

client.connect_signal("focus", function(c)
    c.border_color = beautiful.border_focus
end)
client.connect_signal("unfocus", function(c)
    c.border_color = beautiful.border_normal
end)
-- }}}

-- Customizations

-- bar
local bars_visible = true

local wb = awful.wibar {
    position = "left",
    width = 46,
    height = 900,
    visible = bars_visible,
    bg = "#00000000",
    fg = "#ffffffff",
    ontop = false,
    border_width = 2,
    border_color = "#8c52ff",
    shape = function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, 12)
    end
}

local s1 = awful.screen.focused()
local taskBox = awful.widget.tasklist {
    screen = s1,
    filter = awful.widget.tasklist.filter.currenttags,
    buttons = tasklist_buttons,
    style = {
        shape_border_width = 0,
        shape_border_color = '#8c52ff',
        bg_normal = "#00000000",
        bg_focus = "#8c52ff",
        shape = function(cr, w, h)
            gears.shape.rounded_rect(cr, w, h, 2)
        end

    },
    layout = {
        spacing = 5,
        spacing_widget = {
            valign = 'center',
            halign = 'center',
            widget = wibox.container.place
        },

        layout = wibox.layout.fixed.vertical,
        forced_height = 230
    },

    widget_template = {
        {
            {
                {
                    {

                        id = 'icon_role',
                        resize = true,
                        forced_height = 26,
                        widget = wibox.widget.imagebox
                    },
                    margins = 0,
                    widget = wibox.container.margin
                },
                layout = wibox.layout.fixed.horizontal
            },
            left = 10,
            right = 10,
            valign = "center",
            halign = "center",
            widget = wibox.container.place
        },
        -- forced_height = 25,

        id = 'background_role',
        widget = wibox.container.background,
        create_callback = function(self, c, index, objects)
            local icon_path = "/home/spidey/.config/awesome/iconion/bash.png"
            if c.class == "Alacritty" then
                icon_path = "/home/spidey/.config/awesome/iconion/bash.png"

            elseif c.class == "firefox" then
                icon_path = "/home/spidey/.config/awesome/iconion/firefox.png"
            end
            self:get_children_by_id('icon_role')[1].image = icon_path
        end
    }
}

-- setup

wb:setup{

    layout = wibox.layout.fixed.vertical,
    LeftBar.icon1_group,
    -- separator
    LeftBar.separatorCirclebottom,
    widgets.separatorLine,
    LeftBar.separatorCircletop,
    -- separator
    LeftBar.icon2_group,
    LeftBar.paddedLine,
    LeftBar.icon3_group,
    LeftBar.paddedLine,
    wibox.container.margin(taskBox, 4, 4, 0, 0),
    LeftBar.iconf_grp
}

-- Bar two customizations
local wb1 = awful.wibar {
    position = "top",
    width = 1800,
    height = 40,
    visible = bars_visible,
    bg = "#00000000",
    fg = "#ffffffff",
    ontop = false,
    border_width = 2,
    border_color = "#8c52ff",
    shape = function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, 12)
    end
}

-- local function createHorizontalIconContainer(icons)
--     local icon_container = wibox.layout.fixed.vertical()

--     for _, icon_path in ipairs(icons) do
--         local icon_widget = wibox.widget {
--             image = icon_path,
--             resize = true,
--             forced_width = 30,
--             forced_height = 30,
--             widget = wibox.widget.imagebox,
--         }
--         local icon_with_margin = wibox.container.margin(icon_widget, 0, 0, 8, 4)
--         icon_container:add(icon_with_margin)
--     end

--     return icon_container
-- end

local container = wibox.layout.fixed.vertical()
container:setup{
    {
        wibox.container.margin(modules.taglist, 10, 0, 2, 2),
        layout = wibox.layout.fixed.vertical
    },
    widget = wibox.container.margin,
    margins = 4,
    bg = "#8c52ff",
    font = "" .. rcnf.vars.default_font .. " " .. rcnf.vars.font_size  .. ""

}

local left_group = wibox.widget {
    {
        container,
        layout = wibox.layout.align.horizontal
    },
    widget = wibox.container.background,
    shape = function(cr, w, h)
        gears.shape.rounded_rect(cr, w, h, 8)
    end,
    border_width = 2,
    border_color = "#8c52ff",
    forced_width = 800,
    forced_height = 40,
    font = "" .. rcnf.vars.default_font .. " " .. rcnf.vars.font_size  .. ""
}

local center_group = wibox.widget {
    {
        widgets.rounded_music_container,
        layout = wibox.layout.align.horizontal
    },
    widget = wibox.container.background,
    shape = function(cr, w, h)
        gears.shape.rounded_rect(cr, w, h, 8)
    end,
    border_width = 2,
    border_color = "#8c52ff",
    forced_width = 300,
    forced_height = 40
}

local right_group = wibox.widget {
    {
        -- Your right-aligned content here
        wibox.container.place(widgets.info_container),
        wibox.container.margin(widgets.layoutBox, 6, 6, 6, 6),
        layout = wibox.layout.align.horizontal
    },
    shape = function(cr, w, h)
        gears.shape.rounded_rect(cr, w, h, 8)
    end,
    widget = wibox.container.place,
    forced_width = 500,
    forced_height = 40,
    halign = "right"
}
-- setup
wb1:setup{
    layout = wibox.layout.fixed.horizontal,
    left_group,
    center_group,
    wibox.container.margin(right_group, 190, 0, 0, 0)
}

local textbox_output = wibox.widget.textbox()

local constraint_output = wibox.container.constraint(textbox_output, "exact", nil, 200)

local command_widget = wibox.widget {
    {
        constraint_output,
        widget = wibox.container.margin
    },
    layout = wibox.layout.align.vertical
}

-- local function update_output(widget, stdout, stderr, exitreason, exitcode)
--     local output = "" .. exitcode .. "\n"
--     if not stdout:match("^%s*$") then
--         output = output .. "\n" .. stdout
--     end
--     if not stderr:match("^%s*$") then
--         output = output .. "\nError:\n" .. stderr
--     end
--     widget:set_text(output)
-- end

-- local command = "nmcli -f bars,bssid,rate,ssid dev wifi" -- Replace with your command
-- awful.spawn.easy_async(command, function(stdout, stderr, exitreason, exitcode)
--     update_output(textbox_output, stdout, stderr, exitreason, exitcode)
-- end)

awful.spawn("picom --config " .. rcnf.vars.picom_conf_path .. "")
gears.wallpaper.maximized(rcnf.vars.wall, s)
beautiful.notification_font = "" .. rcnf.vars.default_font .. " " .. rcnf.vars.notif_font_size .. ""
beautiful.notification_bg = rcnf.vars.notif_bg
beautiful.notification_fg = rcnf.vars.notif_fg
beautiful.notification_border_width = rcnf.vars.notif_border_width
beautiful.notification_border_color = rcnf.vars.notif_border_color
beautiful.notification_shape = function(cr, w, h)
    gears.shape.rounded_rect(cr, w, h, rcnf.vars.notif_box_radius)
end
naughty.config.defaults.position = rcnf.vars.notif_position
beautiful.notification_width = rcnf.vars.notif_width
beautiful.notification_height = rcnf.vars.notif_height
beautiful.border_focus = rcnf.vars.window_border_focus
beautiful.border_normal = rcnf.vars.window_border_normal
