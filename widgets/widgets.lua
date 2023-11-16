local wibox = require("wibox")
local vicious = require("vicious")
local gears = require("gears")
local awful = require("awful")

-- vicious.register(volume_bar, function()
--     local vol = vicious.widgets.volume("$1", 0.3, "Master")
--     volume_bar:set_value(vol)
--   end, 5)

local battery_bar = wibox.widget {

    max_value = 1,
    forced_height = 20,
    forced_width = 50,
    paddings = 1,
    border_width = 0,
    border_color = "#ffffff",
    background_color = "#8c53ff",
    shape = function(cr, w, h)
        gears.shape.rounded_rect(cr, w, h, 4)
    end,
    bar_shape = function(cr, w, h)
        gears.shape.rounded_rect(cr, w, h, 4)
    end,
    widget = wibox.widget.progressbar,
    {
        widget = wibox.widget.textbox,
        text = "50% battery"
    },
    bg = "#8c52ff",
    color = "#5bf0ff"

}

vicious.register(battery_bar, vicious.widgets.bat, function(widget, args)
    local battery_level = tonumber(args[2])

    if battery_level < 30 then
        widget.color = "#FF7F7F"
    elseif battery_level < 50 then
        widget.color = "#FFD580"
    else
        widget.color = "#5bf0ff"
    end

    return args[2]
end, 2, "BAT1")

local cpu_bar = wibox.widget.textbox()
cpu_bar.font = "JetBrainsMono Nerd Font 15"
cpu_bar.fg = "#8c52ff"
vicious.register(cpu_bar, vicious.widgets.cpu, "<span color='#8c52ff'>󰻠 $1% |</span>", 2)

local ram_bar = wibox.widget.textbox()
ram_bar.font = "JetBrainsMono Nerd Font 15"

vicious.register(ram_bar, vicious.widgets.mem, "<span color='#8c52ff'> $2MB |</span>", 2)
local vol_bar = wibox.widget.textbox()
vol_bar.font = "JetBrainsMono Nerd Font 15"

local function update_volume(widget, delta)
    awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ " .. delta, false)
    awful.spawn.easy_async("pactl get-sink-volume @DEFAULT_SINK@", function(stdout)
        local volume = tonumber(stdout:match("(%d+)%%"))
        volume = math.min(volume, 100) -- Ensure volume doesn't exceed 100
        widget:set_markup_silently(string.format("<span color='#8c52ff'> %d%% |</span>", volume))
    end)
end

-- Add scrolling functionality
vol_bar:buttons(gears.table.join(awful.button({}, 4, function()
    update_volume(vol_bar, "+5%")
end), awful.button({}, 5, function()
    update_volume(vol_bar, "-5%")
end)))
vicious.register(vol_bar, vicious.widgets.volume, "<span color='#8c52ff'> $1% |</span>", 0.2, "Master")

local systemtray = wibox.widget.systray()
systemtray.opacity = 1

local info_container = wibox.widget {
    layout = wibox.layout.fixed.horizontal,
    spacing = 6,

    ram_bar,
    cpu_bar,
    vol_bar,
    wibox.container.margin(systemtray),
    wibox.container.place(battery_bar)
}
-- separator widgets

local separatorLine = wibox.widget {
    widget = wibox.widget.separator,
    shape = gears.shape.rounded_bar,
    color = "#8c52ff",
    forced_width = 0,
    forced_height = 3
}

local separatorCircle = wibox.widget {
    widget = wibox.widget.separator, -- adjust the width of the separator
    color = "#8c52ff", -- adjust the color of the separator
    shape = gears.shape.circle, -- use a circular shape for dots
    forced_height = 5
}

-- music button widget
local playPauseToggle = false
local buttons_container = wibox.widget {
    bg = "#00000000",
    layout = wibox.layout.fixed.horizontal,
    {
        -- First button (play button)
        image = "/home/spidey/.config/awesome/iconion/prev2.png", -- Replace with the path to your play button icon
        widget = wibox.widget.imagebox,
        forced_width = 40,
        forced_height = 30,
        buttons = awful.button({}, 1, function()
            awful.spawn("playerctl prev")
            playPauseToggle = true
        end)
    },
    {
        -- Second button (pause button)
        image = "/home/spidey/.config/awesome/iconion/pause.png", -- Replace with the path to your play button icon
        widget = wibox.widget.imagebox,
        forced_width = 40,
        forced_height = 30,
        buttons = awful.button({}, 1, function()
            if playPauseToggle then
                awful.spawn("playerctl pause") -- Execute pause command
            else
                awful.spawn("playerctl play") -- Execute play command
            end
            playPauseToggle = not playPauseToggle -- Toggle the state
        end)
    },
    {
        -- Third button (stop button)
        image = "/home/spidey/.config/awesome/iconion/next2.png", -- Replace with the path to your play button icon
        widget = wibox.widget.imagebox,
        forced_width = 40,
        forced_height = 30,
        buttons = awful.button({}, 1, function()
            awful.spawn("playerctl next")
            playPauseToggle = true
        end)
    }
}

local inner_box = wibox.widget {
    {
        {
            layout = wibox.layout.flex.horizontal,
            wibox.container.margin(buttons_container, 13, 0, 0, 0),
            widget = wibox.container.margin
        },
        widget = wibox.container.background,
        bg = "#393D7600",
        shape = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, 16)
        end,
        forced_height = 30,
        forced_width = 135
    },
    layout = wibox.container.place,
    halign = "center",
    valign = "center"
}

local rounded_music_container = wibox.widget {
    layout = wibox.container.place,
    {
        inner_box,
        widget = wibox.container.background,
        bg = "#5BF0FF00",
        shape = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, 16)
        end,
        forced_height = 35,
        forced_width = 150
    },
    halign = "center",
    valign = "center"
}

-- ip addresses here
local ip_widget = wibox.widget.textbox()
ip_widget.font = "JetBrainsMono Nerd Font 10" -- Set your desired font and size

local ip_container = wibox.layout.fixed.vertical()
-- Update function to fetch and update IP addresses
local function update_ip_widget()
    local interfaces = {"enp62s0", "eth0", "lo", "ngrok0", "tun0", "wlan0", "tun1", "wlp61s0", "docker0"}
    local ip_text = ""
    ip_container:reset()
    for _, iface in ipairs(interfaces) do
        awful.spawn.easy_async("ip addr show " .. iface, function(stdout)
            local ip = string.match(stdout, "inet (%d+%.%d+%.%d+%.%d+)")
            if ip then
                local centered_ip_widget = wibox.container.place(ip_widget, "center", "center")
                ip_container:add(centered_ip_widget)
                ip_text = "<span color='#8c52ff' >" .. ip_text .. iface .. "\t\t:\t" .. ip .. " </span>\n"
            end
            ip_widget:set_text(ip_text:sub(1, -4))
            ip_widget:set_markup(ip_text)
        end)
    end
end

update_ip_widget()

-- inet speed here

local inet_speed = wibox.widget.textbox()
inet_speed.font = "JetBrainsMono Nerd Font 11"
local update_speed = function()
    -- Update inet_speed widget with vicious
    vicious.register(inet_speed, vicious.widgets.net,
        '<span color="#8c52ff">Download Speed\t : \t${wlan0 down_kb} KB/s ⬇️ \nUpload Speed\t : \t${wlan0 up_kb} KB/s ⬆️</span>')
end

local speed_timer = timer({
    timeout = 0.5
})
speed_timer:connect_signal("timeout", function()
    update_speed()
end)
speed_timer:start()

-- bordered clock 
-- Clock
local clock_format = "%H\n%M\n%S"
local clock_widget = wibox.widget.textclock(clock_format, 1)
clock_widget.font = "JetBrainsMono Nerd Font 10 bold"

local rect_angle = wibox.widget {
    {
        {
            clock_widget,
            widget = wibox.container.margin,
            left = 3
        },
        widget = wibox.container.background,
        bg = "#00000000",
        fg = "#8c52ff",
        shape = gears.shape.rounded_rect,
        forced_width = 28,
        forced_height = 65
    },
    layout = wibox.container.place,
    halign = "center", -- Center horizontally
    valign = "center" -- Center vertically
}

local rounded_clock_container = wibox.widget {
    layout = wibox.container.place,
    {
        rect_angle,
        widget = wibox.container.background,
        bg = "#8c52ff00",
        shape = gears.shape.rounded_rect,
        forced_width = 35,
        forced_height = 65
    },
    halign = "center",
    valign = "center"
}
-- 

local layoutBox = awful.widget.layoutbox()
layoutBox.font = "JetBrainsMono Nerd Font 5 bold"

layoutBox:buttons(gears.table.join(awful.button({}, 1, function()
    awful.layout.inc(1)
end), awful.button({}, 3, function()
    awful.layout.inc(-1)
end), awful.button({}, 4, function()
    awful.layout.inc(1)
end), awful.button({}, 5, function()
    awful.layout.inc(-1)
end)))
-- 
-- 
-- the nmcli widget stuff
local bar_tb = wibox.widget.textbox()
bar_tb.font = "JetBrainsMono Nerd Font 10"
local bssid_tb = wibox.widget.textbox()
bssid_tb.font = "JetBrainsMono Nerd Font 10"
local ssid_tb = wibox.widget.textbox()
ssid_tb.font = "JetBrainsMono Nerd Font 10"

local nmcli_widget = wibox.widget {
    layout = wibox.layout.align.horizontal,
    expand = "none",
    {
        wibox.container.margin(bar_tb, 0, 20, 0, 0), -- Adjust the left margin for bar_tb
        widget = wibox.container.background
    },
    {
        wibox.container.margin(bssid_tb, 0, 120, 0, 0), -- Adjust the left margin for bssid_tb
        widget = wibox.container.background
    },
    {
        wibox.container.margin(ssid_tb, -140, 0, 0, 0), -- No left margin for ssid_tb
        widget = wibox.container.margin
    }
}
local function parse_output(output)
    local rows = {}
    for line in output:gmatch("[^\r\n]+") do
        local bar, bssid, ssid = line:match("^(.-)%s+(.-)%s+(.+)$")
        rows[#rows + 1] = {bar, bssid, ssid}
    end

    return rows
end

local function update_textboxes(rows)
    local bar_text = ""
    local bssid_text = ""
    local ssid_text = ""

    for _, row in ipairs(rows) do
        -- You can customize the colors based on your preferences
        bar_text = bar_text .. string.format("<span color='#8c52ff'>%s</span>\n", row[1])
        bssid_text = bssid_text .. string.format("<span color='#8c52ff'>%s</span>\n", row[2])
        ssid_text = ssid_text .. string.format("<span color='#8c52ff'>%s</span>\n", row[3])
    end

    bar_tb:set_markup(bar_text)
    bssid_tb:set_markup(bssid_text)
    ssid_tb:set_markup(ssid_text)
end

awful.spawn.easy_async("nmcli -f bars,bssid,ssid dev wifi", function(output)
    local rows = parse_output(output)
    update_textboxes(rows)
end)

-- local graph_popup = wibox.widget.textbox()

return {
    layoutBox = layoutBox,
    info_container = info_container,
    bat_bar = battery_bar,
    separatorLine = separatorLine,
    separatorCircle = separatorCircle,
    rounded_music_container = rounded_music_container,
    ip_widget = ip_widget,
    inet_speed = inet_speed,
    rounded_clock_container = rounded_clock_container,
    nmcli_widget = nmcli_widget
}
