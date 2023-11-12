local wibox = require("wibox")
local widgets = require("widgets.widgets")
local icon_tray = require("icon_tray.icon")

-- Define your sets of icons
local cmdList1 = {"rofi -show run"}

local icons1 = {"/home/spidey/.config/awesome/iconion/menu.png"}

local cmdList2 = {"discord", "firefox", "firefox --new-window https://github.com/",
                  "firefox --new-window https://www.reddit.com/", "spotify", "obsidian"}

local icons2 = {"/home/spidey/.config/awesome/iconion/Vector.png", "/home/spidey/.config/awesome/iconion/firefox.png",
                "/home/spidey/.config/awesome/iconion/github.png", "/home/spidey/.config/awesome/iconion/reddit.png",
                "/home/spidey/.config/awesome/iconion/spotify.png", "/home/spidey/.config/awesome/iconion/obsidian.png"}

local cmdList3 = {"virtualbox", "VBoxManage startvm ubuntu", "alacritty -e sudo docker run -it jerry_at_archlinux"}

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


return{
    icon1_group = icon1_group,
    icon2_group = icon2_group,
    icon3_group = icon3_group,
    paddedLine = paddedLine,
    iconf_grp = iconf_grp,
    separatorCirclebottom = separatorCirclebottom,
    separatorCircletop = separatorCircletop,


}