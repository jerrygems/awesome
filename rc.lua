-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

local vicious = require("vicious")
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
        if in_error then return end
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
awful.layout.layouts = {
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
    awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
    { "hotkeys",     function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
    { "manual",      terminal .. " -e man awesome" },
    { "edit config", editor_cmd .. " " .. awesome.conffile },
    { "restart",     awesome.restart },
    { "quit",        function() awesome.quit() end },
}

local menu_awesome = { "awesome", myawesomemenu, beautiful.awesome_icon }
local menu_terminal = { "open terminal", terminal }

if has_fdo then
    mymainmenu = freedesktop.menu.build({
        before = { menu_awesome },
        after = { menu_terminal }
    })
else
    mymainmenu = awful.menu({
        items = {
            menu_awesome,
            { "Debian", debian.menu.Debian_menu.Debian },
            menu_terminal,
        }
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
local taglist_buttons = gears.table.join(
    awful.button({}, 1, function(t) t:view_only() end),
    awful.button({ modkey }, 1, function(t)
        if client.focus then
            client.focus:move_to_tag(t)
        end
    end),
    awful.button({}, 3, awful.tag.viewtoggle),
    awful.button({ modkey }, 3, function(t)
        if client.focus then
            client.focus:toggle_tag(t)
        end
    end),
    awful.button({}, 4, function(t) awful.tag.viewnext(t.screen) end),
    awful.button({}, 5, function(t) awful.tag.viewprev(t.screen) end)
)

local tasklist_buttons = gears.table.join(
    awful.button({}, 1, function(c)
        if c == client.focus then
            c.minimized = true
        else
            c:emit_signal(
                "request::activate",
                "tasklist",
                { raise = true }
            )
        end
    end),
    awful.button({}, 3, function()
        awful.menu.client_list({ theme = { width = 250 } })
    end),
    awful.button({}, 4, function()
        awful.client.focus.byidx(1)
    end),
    awful.button({}, 5, function()
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
    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
        awful.button({}, 1, function() awful.layout.inc(1) end),
        awful.button({}, 3, function() awful.layout.inc(-1) end),
        awful.button({}, 4, function() awful.layout.inc(1) end),
        awful.button({}, 5, function() awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = taglist_buttons
    }

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons
    }

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s })

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            mylauncher,
            s.mytaglist,
            s.mypromptbox,
        },
        s.mytasklist, -- Middle widget
        {             -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            mykeyboardlayout,
            wibox.widget.systray(),
            mytextclock,
            s.mylayoutbox,
        },
    }
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({}, 3, function() mymainmenu:toggle() end),
    awful.button({}, 4, awful.tag.viewnext),
    awful.button({}, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
    awful.key({ modkey, }, "s", hotkeys_popup.show_help,
        { description = "show help", group = "awesome" }),
    awful.key({ modkey, }, "Left", awful.tag.viewprev,
        { description = "view previous", group = "tag" }),
    awful.key({ modkey, }, "Right", awful.tag.viewnext,
        { description = "view next", group = "tag" }),
    awful.key({ modkey, }, "Escape", awful.tag.history.restore,
        { description = "go back", group = "tag" }),

    awful.key({ modkey, }, "j",
        function()
            awful.client.focus.byidx(1)
        end,
        { description = "focus next by index", group = "client" }
    ),
    awful.key({ modkey, }, "k",
        function()
            awful.client.focus.byidx(-1)
        end,
        { description = "focus previous by index", group = "client" }
    ),
    awful.key({ modkey, }, "w", function() mymainmenu:show() end,
        { description = "show main menu", group = "awesome" }),

    -- Layout manipulation
    awful.key({ modkey, "Shift" }, "j", function() awful.client.swap.byidx(1) end,
        { description = "swap with next client by index", group = "client" }),
    awful.key({ modkey, "Shift" }, "k", function() awful.client.swap.byidx(-1) end,
        { description = "swap with previous client by index", group = "client" }),
    awful.key({ modkey, "Control" }, "j", function() awful.screen.focus_relative(1) end,
        { description = "focus the next screen", group = "screen" }),
    awful.key({ modkey, "Control" }, "k", function() awful.screen.focus_relative(-1) end,
        { description = "focus the previous screen", group = "screen" }),
    awful.key({ modkey, }, "u", awful.client.urgent.jumpto,
        { description = "jump to urgent client", group = "client" }),
    awful.key({ modkey, }, "Tab",
        function()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        { description = "go back", group = "client" }),

    -- Standard program
    awful.key({ modkey, }, "Return", function() awful.spawn(terminal) end,
        { description = "open a terminal", group = "launcher" }),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
        { description = "reload awesome", group = "awesome" }),
    awful.key({ modkey, "Shift" }, "q", awesome.quit,
        { description = "quit awesome", group = "awesome" }),
    awful.key({ modkey, }, "l", function() awful.tag.incmwfact(0.05) end,
        { description = "increase master width factor", group = "layout" }),
    awful.key({ modkey, }, "h", function() awful.tag.incmwfact(-0.05) end,
        { description = "decrease master width factor", group = "layout" }),
    awful.key({ modkey, "Shift" }, "h", function() awful.tag.incnmaster(1, nil, true) end,
        { description = "increase the number of master clients", group = "layout" }),
    awful.key({ modkey, "Shift" }, "l", function() awful.tag.incnmaster(-1, nil, true) end,
        { description = "decrease the number of master clients", group = "layout" }),
    awful.key({ modkey, "Control" }, "h", function() awful.tag.incncol(1, nil, true) end,
        { description = "increase the number of columns", group = "layout" }),
    awful.key({ modkey, "Control" }, "l", function() awful.tag.incncol(-1, nil, true) end,
        { description = "decrease the number of columns", group = "layout" }),
    awful.key({ modkey, }, "space", function() awful.layout.inc(1) end,
        { description = "select next", group = "layout" }),
    awful.key({ modkey, "Shift" }, "space", function() awful.layout.inc(-1) end,
        { description = "select previous", group = "layout" }),

    awful.key({ modkey, "Control" }, "n",
        function()
            local c = awful.client.restore()
            -- Focus restored client
            if c then
                c:emit_signal(
                    "request::activate", "key.unminimize", { raise = true }
                )
            end
        end,
        { description = "restore minimized", group = "client" }),

    -- Prompt
    awful.key({ modkey }, "r", function() awful.screen.focused().mypromptbox:run() end,
        { description = "run prompt", group = "launcher" }),

    awful.key({ modkey }, "x",
        function()
            awful.prompt.run {
                prompt       = "Run Lua code: ",
                textbox      = awful.screen.focused().mypromptbox.widget,
                exe_callback = awful.util.eval,
                history_path = awful.util.get_cache_dir() .. "/history_eval"
            }
        end,
        { description = "lua execute prompt", group = "awesome" }),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end,
        { description = "show the menubar", group = "launcher" })
)

clientkeys = gears.table.join(
    awful.key({ modkey, }, "f",
        function(c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        { description = "toggle fullscreen", group = "client" }),
    awful.key({ modkey, "Shift" }, "c", function(c) c:kill() end,
        { description = "close", group = "client" }),
    awful.key({ modkey, "Control" }, "space", awful.client.floating.toggle,
        { description = "toggle floating", group = "client" }),
    awful.key({ modkey, "Control" }, "Return", function(c) c:swap(awful.client.getmaster()) end,
        { description = "move to master", group = "client" }),
    awful.key({ modkey, }, "o", function(c) c:move_to_screen() end,
        { description = "move to screen", group = "client" }),
    awful.key({ modkey, }, "t", function(c) c.ontop = not c.ontop end,
        { description = "toggle keep on top", group = "client" }),
    awful.key({ modkey, }, "n",
        function(c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end,
        { description = "minimize", group = "client" }),
    awful.key({ modkey, }, "m",
        function(c)
            c.maximized = not c.maximized
            c:raise()
        end,
        { description = "(un)maximize", group = "client" }),
    awful.key({ modkey, "Control" }, "m",
        function(c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end,
        { description = "(un)maximize vertically", group = "client" }),
    awful.key({ modkey, "Shift" }, "m",
        function(c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end,
        { description = "(un)maximize horizontally", group = "client" })
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
            function()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                    tag:view_only()
                end
            end,
            { description = "view tag #" .. i, group = "tag" }),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
            function()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                    awful.tag.viewtoggle(tag)
                end
            end,
            { description = "toggle tag #" .. i, group = "tag" }),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
            function()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                        client.focus:move_to_tag(tag)
                    end
                end
            end,
            { description = "move focused client to tag #" .. i, group = "tag" }),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
            function()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                        client.focus:toggle_tag(tag)
                    end
                end
            end,
            { description = "toggle focused client on tag #" .. i, group = "tag" })
    )
end

clientbuttons = gears.table.join(
    awful.button({}, 1, function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
    end),
    awful.button({ modkey }, 1, function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
        awful.mouse.client.resize(c)
    end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    {
        rule = {},
        properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            raise = true,
            keys = clientkeys,
            buttons = clientbuttons,
            screen = awful.screen.preferred,
            placement = awful.placement.no_overlap + awful.placement.no_offscreen
        }
    },

    -- Floating clients.
    {
        rule_any = {
            instance = {
                "DTA",   -- Firefox addon DownThemAll.
                "copyq", -- Includes session name in class.
                "pinentry",
            },
            class = {
                "Arandr",
                "Blueman-manager",
                "Gpick",
                "Kruler",
                "MessageWin",  -- kalarm.
                "Sxiv",
                "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
                "Wpa_gui",
                "veromix",
                "xtightvncviewer" },

            -- Note that the name property shown in xprop might be set slightly after creation of the client
            -- and the name shown there might not match defined rules here.
            name = {
                "Event Tester", -- xev.
            },
            role = {
                "AlarmWindow",   -- Thunderbird's calendar.
                "ConfigManager", -- Thunderbird's about:config.
                "pop-up",        -- e.g. Google Chrome's (detached) Developer Tools.
            }
        },
        properties = { floating = true }
    },

    -- Add titlebars to normal clients and dialogs
    {
        rule_any = { type = { "normal", "dialog" }
        },
        properties = { titlebars_enabled = true }
    },

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
        and not c.size_hints.user_position
        and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({}, 1, function()
            c:emit_signal("request::activate", "titlebar", { raise = true })
            awful.mouse.client.move(c)
        end),
        awful.button({}, 3, function()
            c:emit_signal("request::activate", "titlebar", { raise = true })
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c):setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        {     -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton(c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton(c),
            awful.titlebar.widget.ontopbutton(c),
            awful.titlebar.widget.closebutton(c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", { raise = false })
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- Customizations
-- bar
local wb = awful.wibar {
    position = "left",
    width = 46,
    height = 900,
    bg = "#000000",
    fg = "#ffffffff",
    ontop = false,
    border_width = 4,
    border_color = "#8c52ff",
    shape = function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, 12)
    end,
}

-- icons
local function createIconContainer(icons, commandsList)
    local icon_container = wibox.layout.fixed.vertical()

    for i, icon_path in ipairs(icons) do
        local icon_widget = wibox.widget {
            image = icon_path,
            resize = true,
            forced_width = 30,
            forced_height = 30,
            widget = wibox.widget.imagebox,
            on_click = function()
                awful.spawn.with_shell("rofi -show drun")
            end
        }
        local icon_with_margin = wibox.container.margin(icon_widget, 0, 0, 8, 4)
        icon_container:add(icon_with_margin)
    end

    return icon_container
end


-- Define your sets of icons
local cmdList1 = {
    "rofi -show dmenu"
}

local icons1 = {
    "/home/spidey/Downloads/menu.png"
}

local cmdList2 = {
    "rofi -show dmenu",
    "rofi -show dmenu",
    "rofi -show dmenu",
    "rofi -show dmenu",
    "rofi -show dmenu",
    "rofi -show dmenu",
    "rofi -show dmenu",
}

local icons2 = {
    "/home/spidey/Downloads/Vector.png",
    "/home/spidey/Downloads/firefox.png",
    "/home/spidey/Downloads/github.png",
    "/home/spidey/Downloads/docker.png",
    "/home/spidey/Downloads/reddit.png",
    "/home/spidey/Downloads/spotify.png",
    "/home/spidey/Downloads/vbox.png",
}

local cmdList3 = {
    "rofi -show dmenu"
}

local icons3 = {
    "/home/spidey/Downloads/power.png",
}

-- Create icon containers using the function
local centered_icon1 = wibox.container.place(createIconContainer(icons1,cmdList1), "center")
local centered_icon2 = wibox.container.place(createIconContainer(icons2,cmdList2), "center")
local centered_icon3 = wibox.container.place(createIconContainer(icons3,cmdList3), "center")
centered_icon3.fg = "#ffffff"
-- separator

local separatorLine = wibox.widget {
    widget = wibox.widget.separator,
    shape = gears.shape.rounded_bar,
    color = "#8c52ff",
    forced_width = 0,
    forced_height = 6,
}

local separatorCircle = wibox.widget {
    widget = wibox.widget.separator, -- adjust the width of the separator
    color = "#8c52ff",               -- adjust the color of the separator
    shape = gears.shape.circle,      -- use a circular shape for dots
    forced_height = 8,
}
local paddedLine = wibox.container.margin(separatorLine, 0, 0, 10, 10)
local separatorCirclebottom = wibox.container.margin(separatorCircle, 0, 0, 15, 4)
local separatorCircletop = wibox.container.margin(separatorCircle, 0, 0, 4, 15)

-- Clock
local clock_format = "%H\n%M\n%S"
local clock_widget = wibox.widget.textclock(clock_format, 1)
clock_widget.font = "JetBrainsMono Nerd Font 10 bold"

local rect_angle = wibox.widget {
    {
        {
            clock_widget,
            widget = wibox.container.margin,
            left = 3,
        },
        widget = wibox.container.background,
        bg = "#000000",
        fg = "#8c52ff",
        shape = gears.shape.rounded_rect,
        forced_width = 28,
        forced_height = 65,
    },
    layout = wibox.container.place,
    halign = "center", -- Center horizontally
    valign = "center", -- Center vertically
}

local rounded_clock_container = wibox.widget {
    layout = wibox.container.place,
    {
        rect_angle,
        widget = wibox.container.background,
        bg = "#8c52ff",
        shape = gears.shape.rounded_rect,
        forced_width = 35,
        forced_height = 65

    },
    halign = "center",
    valign = "center"
}
-- grouping
local icon1_group = wibox.layout.align.vertical()
icon1_group:set_top(centered_icon1)

local icon2_group = wibox.layout.align.vertical()
icon2_group:set_middle(centered_icon2)

local icon3_group = wibox.layout.fixed.vertical()
icon3_group:add(paddedLine)
-- Add the clock widget (rounded_clock_container) to group_three
icon3_group:add(rounded_clock_container)
-- Add the power button (centered_icon3) to group_three
icon3_group:add(centered_icon3)

local icon3_grp = wibox.container.margin(icon3_group, 0, 0, 340, 0)


-- setup
wb:setup {

    layout = wibox.layout.fixed.vertical,
    icon1_group,
    -- separator
    separatorCirclebottom,
    separatorLine,
    separatorCircletop,
    -- separator
    icon2_group,
    paddedLine,
    icon3_grp
}































-- Bar two customizations
local wb1 = awful.wibar {
    position = "top",
    width = 1800,
    height = 40,
    bg = "#000000",
    fg = "#ffffffff",
    ontop = false,
    border_width = 4,
    border_color = "#8c52ff",
    shape = function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, 12)
    end,
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

local icon1 = "/home/spidey/Downloads/house1.png"
local icon2 = "/home/spidey/Downloads/bash.png"
local icon3 = "/home/spidey/Downloads/bash.png"
local icon4 = "/home/spidey/Downloads/bash.png"
local icon5 = "/home/spidey/Downloads/browser.png"
local icon6 = "/home/spidey/Downloads/vm.png"
local icon7 = "/home/spidey/Downloads/code1.png"
local icon8 = "/home/spidey/Downloads/code1.png"
local icon9 = "/home/spidey/Downloads/chat.png"

local taglist = awful.widget.taglist {
    screen          = awful.screen.focused(),
    filter          = function(t, args)
        if #t:clients() > 0 then
            return true
        end
    end,

    style           = {
        shape = gears.shape.powerline,
        shape_border_color = '#8c52ff',
        shape_border_width = 1,
        bg_focus = "#8c52ff",
        bg_occupied = "#000000",
        bg_urgent = "#8c52ff",
    },
    layout          = {
        spacing        = -16,
        spacing_widget = {
            color  = '#8c52ff',
            shape  = gears.shape.powerline,
            widget = wibox.widget.separator,
        },
        layout         = wibox.layout.fixed.horizontal,
    },
    widget_template = {
        {
            bg = "#8c52ff",
            {
                {
                    {

                        {
                            id     = 'index_role',
                            widget = wibox.widget.textbox,
                        },
                        margins = 4,
                        widget  = wibox.container.margin,
                    },
                    bg       = '#00000000',
                    bg_focus = "#8c52ff",
                    shape    = gears.shape.circle,
                    widget   = wibox.container.background,
                },
                {
                    {
                        id     = 'icon_role',
                        widget = wibox.widget.imagebox,
                    },
                    margins = 0,
                    widget  = wibox.container.margin,
                },
                layout = wibox.layout.fixed.horizontal,
            },
            left   = 18,
            right  = 18,
            widget = wibox.container.margin,
        },
        id              = 'background_role',
        widget          = wibox.container.background,
        -- Add support for hover colors and an index label
        create_callback = function(self, c3, index, objects) --luacheck: no unused args
            if index == 1 then
                self:get_children_by_id('icon_role')[1]:set_image(icon1)
            elseif index == 2 then
                self:get_children_by_id('icon_role')[1]:set_image(icon2)
            elseif index == 3 then
                self:get_children_by_id('icon_role')[1]:set_image(icon3)
            elseif index == 4 then
                self:get_children_by_id('icon_role')[1]:set_image(icon4)
            elseif index == 5 then
                self:get_children_by_id('icon_role')[1]:set_image(icon5)
            elseif index == 6 then
                self:get_children_by_id('icon_role')[1]:set_image(icon6)
            elseif index == 7 then
                self:get_children_by_id('icon_role')[1]:set_image(icon7)
            elseif index == 8 then
                self:get_children_by_id('icon_role')[1]:set_image(icon8)
            elseif index == 9 then
                self:get_children_by_id('icon_role')[1]:set_image(icon9)
            end
            self:connect_signal('mouse::enter', function()
                if awful.tag.selected(mouse.screen) == c3 then
                    self.bg = '#8c52ff'  -- Active tag background color
                else
                    self.bg = '#000000'  -- Inactive tag background color
                end
            end)
            self:connect_signal('mouse::leave', function()
                if self.has_backup then self.bg = self.backup end
            end)
        end,
        update_callback = function(self, c3, index, objects) --luacheck: no unused args
            self:get_children_by_id('index_role')[1].markup = '<b> ' .. ' </b>'
        end,
    },
    buttons         = taglist_buttons
}

-- Create a container to hold the line and taglist

local container = wibox.layout.fixed.vertical()
container:setup {
    {
        wibox.container.margin(taglist, 10, 0, 2, 2),
        layout = wibox.layout.fixed.vertical
    },
    widget = wibox.container.margin,
    margins = 4,
    bg = "#8c52ff",
    forced_height = 46,

}

local buttons_container = wibox.widget {
    layout = wibox.layout.fixed.horizontal,
    {
        -- First button (play button)
        image = "/home/spidey/Downloads/prev2.png", -- Replace with the path to your play button icon
        widget = wibox.widget.imagebox,
        forced_width = 40,
        forced_height = 30,
    },
    {
        -- Second button (pause button)
        image = "/home/spidey/Downloads/pause.png", -- Replace with the path to your play button icon
        widget = wibox.widget.imagebox,
        forced_width = 40,
        forced_height = 30,
    },
    {
        -- Third button (stop button)
        image = "/home/spidey/Downloads/next2.png", -- Replace with the path to your play button icon
        widget = wibox.widget.imagebox,
        forced_width = 40,
        forced_height = 30,
    },
}

local inner_box = wibox.widget {
    {
        {
            layout = wibox.layout.flex.horizontal,
            wibox.container.margin(buttons_container, 13, 0, 0, 0),
            widget = wibox.container.margin,
        },
        widget = wibox.container.background,
        bg = "#04001e",
        shape = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, 16)
        end,
        forced_height = 30,
        forced_width = 135,
    },
    layout = wibox.container.place,
    halign = "center",
    valign = "center",
}

local rounded_music_container = wibox.widget {
    layout = wibox.container.place,
    {
        inner_box,
        widget = wibox.container.background,
        bg = "#5BF0FF",
        shape = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, 16)
        end,
        forced_height = 35,
        forced_width = 150
    },
    halign = "center",
    valign = "center"
}



local left_group = wibox.widget {
    {
        container,
        layout = wibox.layout.align.horizontal,
    },
    widget = wibox.container.background,
    shape = function(cr, w, h)
        gears.shape.rounded_rect(cr, w, h, 8)
    end,
    border_width = 2,
    border_color = "#8c52ff",
    forced_width = 800, -- Adjust the width as needed
    forced_height = 40,
}

local center_group = wibox.widget {
    {
        rounded_music_container,
        layout = wibox.layout.align.horizontal,
    },
    widget = wibox.container.background,
    shape = function(cr, w, h)
        gears.shape.rounded_rect(cr, w, h, 8)
    end,
    border_width = 2,
    border_color = "#8c52ff",
    forced_width = 300, -- Adjust the width as needed
    forced_height = 40,
}

local right_group = wibox.widget {
    {
        -- Your right-aligned content here
        layout = wibox.layout.align.horizontal,
    },
    widget = wibox.container.background,
    shape = function(cr, w, h)
        gears.shape.rounded_rect(cr, w, h, 8)
    end,
    border_width = 2,
    border_color = "#8c52ff",
    forced_width = 100, -- Adjust the width as needed
    forced_height = 40,
}

-- setup
wb1:setup {
    layout = wibox.layout.fixed.horizontal,
    left_group,
    center_group,
    right_group,
}


































-- inet speed here

local inet_speed = wibox.widget.textbox()
inet_speed.font = "JetBrainsMono Nerd Font 11"
local update_speed = function()
    -- Update inet_speed widget with vicious
    vicious.register(inet_speed, vicious.widgets.net,
        '<span color="#8c52ff">Download Speed\t : \t${wlp61s0 down_kb} KB/s ⬇️ \nUpload Speed\t : \t${wlp61s0 up_kb} KB/s ⬆️</span>'
    )
end

update_speed()

local speed_timer = timer({ timeout = 0.5 })
speed_timer:connect_signal("timeout", function()
    update_speed()
end)
speed_timer:start()

-- custom line

local paddedLineSpeed = wibox.widget {
    layout = wibox.layout.fixed.vertical,
    {
        layout = wibox.layout.margin,
        separatorLine,
        forced_width = 100,
    }
}

-- ip addresses here
local ip_widget = wibox.widget.textbox()
ip_widget.font = "JetBrainsMono Nerd Font 10" -- Set your desired font and size

local ip_container = wibox.layout.fixed.vertical()
-- Update function to fetch and update IP addresses
local function update_ip_widget()
    local interfaces = { "enp62s0", "ngrok0", "tun0", "tun1", "wlp61s0", "docker0" }
    local ip_text = ""
    ip_container:reset()
    for _, iface in ipairs(interfaces) do
        awful.spawn.easy_async("ip addr show " .. iface, function(stdout)
            local ip = string.match(stdout, "inet (%d+%.%d+%.%d+%.%d+)")
            if ip then
                local centered_ip_widget = wibox.container.place(ip_widget, "center", "center")
                ip_container:add(centered_ip_widget)
                ip_text = "<span color='#8c52ff' >" .. ip_text .. iface .. "\t:\t" .. ip .. " </span>\n"
            end
            ip_widget:set_text(ip_text:sub(1, -4))
            ip_widget:set_markup(ip_text)
        end)
    end
end

update_ip_widget()

--


-- Start the timer

local speed_popup = awful.popup {
    widget = wibox.widget {
        layout = wibox.layout.fixed.vertical,

        {
            layout = wibox.container.margin,
            bottom = 20,
            {
                inet_speed,
                left = 30,
                layout = wibox.container.margin,
            },
            forced_height = 80,
            forced_width = 400,
        },
        wibox.container.margin(paddedLineSpeed, 0, 0, -10, 5),
        {
            layout = wibox.container.margin,
            bottom = 20,
            {
                ip_widget,
                top = 0,
                left = 30,
                layout = wibox.container.margin,

            },
            forced_height = 120,
            forced_width = 400,
        },
    },
    border_width = 4,
    border_color = '#8c52ff',
    bg = '#00000000',
    ontop = false,
    shape = function(cr, w, h)
        gears.shape.rounded_rect(cr, w, h, 14)
    end
}

awful.placement.top_right(speed_popup, { margins = { top = 160, right = 1700 }, parent = awful.screen.focused() })
speed_popup.visible = true
