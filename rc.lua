-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
    pcall(require, "luarocks.loader")

    -- custom libraries
    local vicious = require("vicious")
    local modules = require("modules.taglist")
    local widgets = require("widgets.widgets")
    local popups = require("popup.popups")
    local icon_tray = require("icon_tray.icon")
    
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
        awful.tag({"1", "2", "3", "4", "5", "6", "7", "8", "9"}, s, awful.layout.layouts[1])
    
        -- Create a promptbox for each screen
        s.mypromptbox = awful.widget.prompt()
        -- Create an imagebox widget which will contain an icon indicating which layout we're using.
        -- We need one layoutbox per screen.
        s.mylayoutbox = awful.widget.layoutbox(s)
        s.mylayoutbox:buttons(gears.table.join(awful.button({}, 1, function()
            awful.layout.inc(1)
        end), awful.button({}, 3, function()
            awful.layout.inc(-1)
        end), awful.button({}, 4, function()
            awful.layout.inc(1)
        end), awful.button({}, 5, function()
            awful.layout.inc(-1)
        end)))
        -- Create a taglist widget
        s.mytaglist = awful.widget.taglist {
            screen = s,
            filter = awful.widget.taglist.filter.all,
            buttons = taglist_buttons
        }
    
        -- Create a tasklist widget
        s.mytasklist = awful.widget.tasklist {
            screen = s,
            filter = awful.widget.tasklist.filter.currenttags,
            buttons = tasklist_buttons
        }
    
        -- Create the wibox
        s.mywibox = awful.wibar({
            position = "top",
            screen = s
        })
    
        -- Add widgets to the wibox
        s.mywibox:setup{
            layout = wibox.layout.align.horizontal,
            { -- Left widgets
                layout = wibox.layout.fixed.horizontal,
                mylauncher,
                s.mytaglist,
                s.mypromptbox
            },
            s.mytasklist, -- Middle widget
            { -- Right widgets
                layout = wibox.layout.fixed.horizontal,
                mykeyboardlayout,
                wibox.widget.systray(),
                mytextclock,
                s.mylayoutbox
            }
        }
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
    
    clientbuttons = gears.table.join(
        awful.button({}, 1, function(c)
            c:emit_signal("request::activate", "mouse_click", {
                raise = true
            })
        end),
        awful.button({ modkey }, 1, function(c)
            c:emit_signal("request::activate", "mouse_click", {
                raise = true
            })
            awful.mouse.client.move(c)
        end),
        awful.button({ modkey, "Shift" }, 1, function(c)
            c:emit_signal("request::activate", "mouse_click", {
                raise = true
            })
            awful.mouse.client.resize(c)
        end)
    )
    
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
    
    -- Add a titlebar if titlebars_enabled is set to true in the rules.
    client.connect_signal("request::titlebars", function(c)
        -- buttons for the titlebar
        local buttons = gears.table.join(awful.button({}, 1, function()
            c:emit_signal("request::activate", "titlebar", {
                raise = true
            })
            awful.mouse.client.move(c)
        end), awful.button({}, 3, function()
            c:emit_signal("request::activate", "titlebar", {
                raise = true
            })
            awful.mouse.client.resize(c)
        end))
    
        awful.titlebar(c):setup{
            { -- Left
                awful.titlebar.widget.iconwidget(c),
                buttons = buttons,
                layout = wibox.layout.fixed.horizontal
            },
            { -- Middle
                { -- Title
                    align = "center",
                    widget = awful.titlebar.widget.titlewidget(c)
                },
                buttons = buttons,
                layout = wibox.layout.flex.horizontal
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
    
    -- Define keybindings to toggle bars
    
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
    
    -- Define your sets of icons
    local cmdList1 = {"rofi -show run"}
    
    local icons1 = {"/home/spidey/.config/awesome/iconion/menu.png"}
    
    local cmdList2 = {"discord", "firefox", "firefox --new-window https://github.com/",
                      "firefox --new-window https://www.reddit.com/", "spotify", "obsidian"}
    
    local icons2 = {"/home/spidey/.config/awesome/iconion/Vector.png", "/home/spidey/.config/awesome/iconion/firefox.png",
                    "/home/spidey/.config/awesome/iconion/github.png", "/home/spidey/.config/awesome/iconion/reddit.png",
                    "/home/spidey/.config/awesome/iconion/spotify.png", "/home/spidey/.config/awesome/iconion/obsidian.png"}
    
    local cmdList3 = {"virtualbox", "VBoxManage startvm ubuntu", "alacritty -e sudo docker run -it archlinux bash"}
    
    local icons3 = {"/home/spidey/.config/awesome/iconion/vbox.png", "/home/spidey/.config/awesome/iconion/ubuntu.png",
                    "/home/spidey/.config/awesome/iconion/docker.png"}
    
    local cmdListf = {"shutdown now"}
    
    local iconsf = {"/home/spidey/.config/awesome/iconion/power.png"}
    
    -- Create icon containers using the function
    local centered_icon1 = wibox.container.place(icon_tray.createIconContainer(icons1, cmdList1), "center")
    local centered_icon2 = wibox.container.place(icon_tray.createIconContainer(icons2, cmdList2), "center")
    local centered_icon3 = wibox.container.place(icon_tray.createIconContainer(icons3, cmdList3), "center")
    local centered_iconf = wibox.container.place(icon_tray.createIconContainer(iconsf, cmdListf), "center")
    -- separator
    
    local paddedLine = wibox.container.margin(widgets.separatorLine, 0, 0, 10, 10)
    local separatorCirclebottom = wibox.container.margin(widgets.separatorCircle, 0, 0, 15, 4)
    local separatorCircletop = wibox.container.margin(widgets.separatorCircle, 0, 0, 4, 15)
    
    -- grouping
    local icon1_group = wibox.layout.align.vertical()
    icon1_group:set_top(centered_icon1)
    
    local icon2_group = wibox.layout.align.vertical()
    icon2_group:set_middle(centered_icon2)
    
    local icon3_group = wibox.layout.align.vertical()
    icon3_group:set_middle(centered_icon3)
    
    local iconf_group = wibox.layout.fixed.vertical()
    iconf_group:add(paddedLine)
    -- Add the clock widget (rounded_clock_container) to group_three
    iconf_group:add(widgets.rounded_clock_container)
    -- Add the power button (centered_icon3) to group_three
    iconf_group:add(centered_iconf)
    
    local iconf_grp = wibox.container.margin(iconf_group, 0, 0, 220, 0)
    
    -- setup
    wb:setup{
    
        layout = wibox.layout.fixed.vertical,
        icon1_group,
        -- separator
        separatorCirclebottom,
        widgets.separatorLine,
        separatorCircletop,
        -- separator
        icon2_group,
        paddedLine,
        icon3_group,
        paddedLine,
        iconf_grp
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
        bg = "#8c52ff"
    
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
        forced_width = 800, -- Adjust the width as needed
        forced_height = 40
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
        forced_width = 300, -- Adjust the width as needed
        forced_height = 40
    }
    
    local right_group = wibox.widget {
        {
            -- Your right-aligned content here
            wibox.container.place(widgets.bat_bar),
            layout = wibox.layout.align.horizontal
        },
        widget = wibox.container.background,
        shape = function(cr, w, h)
            gears.shape.rounded_rect(cr, w, h, 8)
        end,
        border_width = 2,
        border_color = "#8c52ff",
        forced_width = 400, -- Adjust the width as needed
        forced_height = 40
    }
    
    -- setup
    wb1:setup{
        layout = wibox.layout.fixed.horizontal,
        left_group,
        center_group,
        right_group
    }
    
    local speed_popup = awful.popup {
        widget = wibox.widget {
            layout = wibox.layout.fixed.vertical,
    
            {
                layout = wibox.container.margin,
                bottom = 20,
                {
                    widgets.inet_speed,
                    left = 30,
                    layout = wibox.container.margin
                },
                forced_height = 80,
                forced_width = 400
            },
            wibox.container.margin(widgets.separatorLine, 0, 0, 0, 5),
            {
                layout = wibox.container.margin,
                bottom = 20,
                {
                    widgets.ip_widget,
                    top = 0,
                    left = 30,
                    layout = wibox.container.margin
    
                },
                forced_height = 120,
                forced_width = 400
            }
        },
        border_width = 4,
        border_color = '#8c52ff',
        bg = '#00000000',
        ontop = false,
        shape = function(cr, w, h)
            gears.shape.rounded_rect(cr, w, h, 14)
        end
    }
    
    awful.placement.top_left(speed_popup, {
        margins = {
            top = 100,
            left = 100
        },
        parent = awful.screen.focused()
    })
    speed_popup.visible = true
    
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
    
    local bar_tb = wibox.widget.textbox()
    local bssid_tb = wibox.widget.textbox()
    local rate_tb = wibox.widget.textbox()
    local ssid_tb = wibox.widget.textbox()
    local nmcli_widget = wibox.widget {
        layout = wibox.layout.align.horizontal,
        expand = "none",
        {
            wibox.container.margin(bar_tb, 0, 10, 0, 0),   -- Adjust the left margin for bar_tb
            widget = wibox.container.background
        },
        {
            wibox.container.margin(bssid_tb, 0, 10, 0, 0),  -- Adjust the left margin for bssid_tb
            widget = wibox.container.background
        },
        {
            wibox.container.margin(rate_tb, 0, 10, 0, 0),   -- Adjust the left margin for rate_tb
            widget = wibox.container.background
        },
        {
            wibox.container.margin(ssid_tb, 0, 0, 0, 0),   -- No left margin for ssid_tb
            widget = wibox.container.background
        }
    }
    local function parse_output(output)
        local rows = {}
        for line in output:gmatch("[^\r\n]+") do
            local bar, bssid, rate, ssid = line:match("^(.-)%s+(.-)%s+(.-)%s+(.+)$")
            rows[#rows + 1] = {bar, bssid, rate, ssid}
        end
    
        return rows
    end
    
    local function update_textboxes(rows)
        local bar_text = ""
        local bssid_text = ""
        local rate_text = ""
        local ssid_text = ""
    
        for _, row in ipairs(rows) do
            bar_text = bar_text .. row[1] .. "\n"
            bssid_text = bssid_text .. row[2] .. "\n"
            rate_text = rate_text .. row[3] .. "\n"
            ssid_text = ssid_text .. row[4] .. "\n"
        end
    
        bar_tb:set_text(bar_text)
        bssid_tb:set_text(bssid_text)
        rate_tb:set_text(rate_text)
        ssid_tb:set_text(ssid_text)
    end
    
    awful.spawn.easy_async("nmcli -f bars,bssid,rate,ssid dev wifi", function(output)
        local rows = parse_output(output)
        update_textboxes(rows)
    end)
    
    local articles_widget = awful.popup {
        widget = wibox.widget {
            layout = wibox.layout.fixed.vertical,
    
            {
                layout = wibox.container.margin,
                bottom = 20,
                {
                    nmcli_widget,
                    left = 30,
                    layout = wibox.container.margin
                },
                forced_height = 200,
                forced_width = 400
            }
    
        },
        border_width = 4,
        border_color = '#8c52ff',
        bg = '#00000000',
        ontop = false,
        shape = function(cr, w, h)
            gears.shape.rounded_rect(cr, w, h, 14)
        end
    }
    
    awful.placement.bottom_left(articles_widget, {
        margins = {
            bottom = 260,
            left = 100
        },
        parent = awful.screen.focused()
    })
    articles_widget.visible = true
    
    awful.spawn("picom --config /home/spidey/.config/picom/picom.conf")
    gears.wallpaper.maximized("/home/spidey/Downloads/wall3.jpg", s)
    beautiful.useless_gap = 5
    beautiful.notification_font = "JetBrainsMono Nerd Font 10"
    beautiful.notification_bg = "#00000000"
    beautiful.notification_fg = "#b16286"
    beautiful.notification_border_width = 2
    beautiful.notification_border_color = "#04001e"
    beautiful.notification_shape = function(cr, w, h)
        gears.shape.rounded_rect(cr, w, h, 14)
    end
    naughty.config.defaults.position = "bottom_right"
    beautiful.notification_width = 300
    beautiful.notification_height = 100
    beautiful.border_width = 2
    beautiful.border_focus = "#8c52ff"
    