local wibox = require("wibox")
local widgets = require("widgets.widgets")
local icon_tray = require("icon_tray.icon")
local awful = require("awful")
local gears = require("gears")
-- test
local naughty = require("naughty")

-- Define your sets of icons

local username = os.getenv("USER") or os.getenv("USERNAME")

local cmdList1 = {"rofi -show run"}

local icons1 = {"/home/" .. username .. "/.config/awesome/iconion/menu.png"}

local cmdList2 = {"discord", "firefox", "firefox --new-window https://github.com/",
                  "firefox --new-window https://www.reddit.com/", "spotify", "obsidian"}

local icons2 = {"/home/" .. username .. "/.config/awesome/iconion/Vector.png", "/home/" .. username .. "/.config/awesome/iconion/firefox.png",
                "/home/" .. username .. "/.config/awesome/iconion/github.png", "/home/" .. username .. "/.config/awesome/iconion/reddit.png",
                "/home/" .. username .. "/.config/awesome/iconion/spotify.png", "/home/" .. username .. "/.config/awesome/iconion/obsidian.png"}

local cmdList3 = {"virtualbox", "VBoxManage startvm ubuntu", "alacritty -e sudo docker run -it jerry_at_archlinux"}

local icons3 = {"/home/" .. username .. "/.config/awesome/iconion/vbox.png", "/home/" .. username .. "/.config/awesome/iconion/ubuntu.png",
                "/home/" .. username .. "/.config/awesome/iconion/docker.png"}

local cmdListf = {"shutdown now"}

local iconsf = {"/home/" .. username .. "/.config/awesome/iconion/power.png"}

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

local iconf_grp = wibox.container.margin(iconf_group, 0, 0, 0, 0)

-- tasklist here
local s1 = awful.screen.focused()

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



return {
    icon1_group = icon1_group,
    icon2_group = icon2_group,
    icon3_group = icon3_group,
    paddedLine = paddedLine,
    iconf_grp = iconf_grp,
    separatorCirclebottom = separatorCirclebottom,
    separatorCircletop = separatorCircletop,
    tasklist_buttons = tasklist_buttons
}
