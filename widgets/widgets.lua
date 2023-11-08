local wibox = require("wibox")
local vicious = require("vicious")
local gears = require("gears")
local awful = require("awful")

local volume_bar = wibox.widget {

    max_value        = 1,
    forced_height    = 30,
    forced_width     = 300,
    paddings         = 1,
    border_width     = 0,
    border_color     = "#ffffff",
    background_color = "#8c53ff",
    shape            = gears.shape.rounded_bar,
    bar_shape        = gears.shape.rounded_bar,
    widget           = wibox.widget.progressbar,
    bg               = "#8c52ff",
    color            = "#5bf0ff",

}

vicious.register(volume_bar, vicious.widgets.volume, "$1", 0.3, "Master")


local battery_bar = wibox.widget {

    max_value        = 1,
    forced_height    = 30,
    forced_width     = 300,
    paddings         = 1,
    border_width     = 0,
    border_color     = "#ffffff",
    background_color = "#8c53ff",
    shape            = gears.shape.rounded_bar,
    bar_shape        = gears.shape.rounded_bar,
    widget           = wibox.widget.progressbar,
    bg               = "#8c52ff",
    color            = "#5bf0ff",

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

local cpu_bar = wibox.widget {

    max_value        = 1,
    forced_height    = 30,
    forced_width     = 300,
    paddings         = 1,
    border_width     = 0,
    border_color     = "#ffffff",
    background_color = "#8c53ff",
    shape            = gears.shape.rounded_bar,
    bar_shape        = gears.shape.rounded_bar,
    widget           = wibox.widget.progressbar,
    bg               = "#8c52ff",
    color            = "#5bf0ff",

}

vicious.register(cpu_bar, vicious.widgets.cpufreq, "$1 GHz", 2, "cpu0")


local ram_bar = wibox.widget {

    max_value        = 1,
    forced_height    = 30,
    forced_width     = 300,
    paddings         = 1,
    border_width     = 0,
    border_color     = "#ffffff",
    background_color = "#8c53ff",
    shape            = gears.shape.rounded_bar,
    bar_shape        = gears.shape.rounded_bar,
    widget           = wibox.widget.progressbar,
    bg               = "#8c52ff",
    color            = "#5bf0ff",

}

vicious.register(ram_bar, vicious.widgets.mem, "RAM: $1% ($2MB/$3MB)", 13)

-- separator widgets

local separatorLine = wibox.widget {
    widget = wibox.widget.separator,
    shape = gears.shape.rounded_bar,
    color = "#8c52ff",
    forced_width = 0,
    forced_height = 3,
}

local separatorCircle = wibox.widget {
    widget = wibox.widget.separator, -- adjust the width of the separator
    color = "#8c52ff",               -- adjust the color of the separator
    shape = gears.shape.circle,      -- use a circular shape for dots
    forced_height = 5,
}


-- music button widget

local buttons_container = wibox.widget {
    bg = "#00000000",
    layout = wibox.layout.fixed.horizontal,
    {
        -- First button (play button)
        image = "/home/spidey/.config/awesome/iconion/prev2.png", -- Replace with the path to your play button icon
        widget = wibox.widget.imagebox,
        forced_width = 40,
        forced_height = 30,
    },
    {
        -- Second button (pause button)
        image = "/home/spidey/.config/awesome/iconion/pause.png", -- Replace with the path to your play button icon
        widget = wibox.widget.imagebox,
        forced_width = 40,
        forced_height = 30,
    },
    {
        -- Third button (stop button)
        image = "/home/spidey/.config/awesome/iconion/next2.png", -- Replace with the path to your play button icon
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


-- ip addresses here
local ip_widget = wibox.widget.textbox()
ip_widget.font = "JetBrainsMono Nerd Font 10" -- Set your desired font and size

local ip_container = wibox.layout.fixed.vertical()
-- Update function to fetch and update IP addresses
local function update_ip_widget()
    local interfaces = { "enp62s0", "eth0","lo", "ngrok0", "tun0","wlan0", "tun1", "wlp61s0", "docker0" }
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
        '<span color="#8c52ff">Download Speed\t : \t${wlan0 down_kb} KB/s ⬇️ \nUpload Speed\t : \t${wlan0 up_kb} KB/s ⬆️</span>'
    )
end


local speed_timer = timer({ timeout = 0.5 })
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
            left = 3,
        },
        widget = wibox.container.background,
        bg = "#00000000",
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
        bg = "#8c52ff00",
        shape = gears.shape.rounded_rect,
        forced_width = 35,
        forced_height = 65

    },
    halign = "center",
    valign = "center"
}
-- 

return {
    vol_bar = volume_bar,
    ram_bar = ram_bar,
    cpu_bar = cpu_bar,
    bat_bar = battery_bar,
    separatorLine = separatorLine,
    separatorCircle = separatorCircle,
    rounded_music_container = rounded_music_container,
    ip_widget = ip_widget,
    inet_speed = inet_speed,
    rounded_clock_container = rounded_clock_container,

}
