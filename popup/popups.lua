local awful = require('awful')
local wibox = require('wibox')
local widgets = require('widgets.widgets')
local gears = require("gears")
local vicious = require("vicious")
local naughty = require("naughty")
local rcnf = require("rice_config")


naughty.notify({
    text = gears.animation
})

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
    border_width = rcnf.vars.all_widget_border_width,
    border_color = rcnf.vars.all_widget_border_color,
    bg = rcnf.vars.all_widget_background,
    ontop = false,
    shape = function(cr, w, h)
        gears.shape.rounded_rect(cr, w, h, rcnf.vars.all_widget_radius)
    end
}
awful.placement.top_left(speed_popup, {
    margins = {
        top = rcnf.vars.widget1_top,
        left = rcnf.vars.widget1_left
    },
    parent = awful.screen.focused()
})
speed_popup.visible = true
-- 

-- second pop-up
local net_devices_widget = awful.popup {
    widget = wibox.widget {
        layout = wibox.layout.fixed.vertical,

        {
            layout = wibox.container.margin,
            bottom = 20,
            {
                widgets.nmcli_widget,
                left = 30,
                layout = wibox.container.margin
            },
            forced_height = 200,
            forced_width = 400
        }
    },
    border_width = rcnf.vars.all_widget_border_width,
    border_color = rcnf.vars.all_widget_border_color,
    bg = rcnf.vars.all_widget_background,
    ontop = false,
    shape = function(cr, w, h)
        gears.shape.rounded_rect(cr, w, h, rcnf.vars.all_widget_radius)
    end
}

awful.placement.bottom_left(net_devices_widget, {
    margins = {
        bottom = rcnf.vars.widget2_bottom,
        left = rcnf.vars.widget2_left
    },
    parent = awful.screen.focused()
})
net_devices_widget.visible = true

-- 
-- 
-- 

local cpu_arc = wibox.widget {
    max_value = 100,
    thickness = 20,
    start_angle = 4.71238898,
    rounded_edge = true,
    bg = "#8c52ff",
    paddings = 2,
    colors = {"#5bf0ff"},
    text = "CPU",
    widget = wibox.container.arcchart,
    forced_height = 100
}
local cpu_widget = wibox.widget {
    cpu_arc,
    widget = wibox.container.place
}

vicious.register(cpu_widget, vicious.widgets.cpu, function(widget, args)
    cpu_arc:set_value(args[2])
    return args[2]
end, 1)

cpu_widget:buttons(awful.util.table.join(awful.button({}, 1, function()
    vicious.force({cpu_widget})
end)))

-- 
-- 
-- 
local memory_arc = wibox.widget {
    max_value = 100,
    thickness = 20,
    start_angle = 4.71238898,
    rounded_edge = true,
    bg = "#8c52ff",
    paddings = 2,
    colors = {"#5bf0ff"},
    text = "Memory",
    widget = wibox.container.arcchart,
    forced_height = 100
}

local memory_widget = wibox.widget {
    memory_arc,
    widget = wibox.container.place
}

vicious.register(memory_widget, vicious.widgets.mem, function(widget, args)
    memory_arc:set_value(args[1])
    return args[1]
end, 1)

memory_widget:buttons(awful.util.table.join(awful.button({}, 1, function()
    vicious.force({memory_widget})
end)))
-- 
-- 
-- 
local disk_usage_text = wibox.widget {
    text = "disk Usage: 0%",
    widget = wibox.widget.textbox
}

local disk_progressbar = wibox.widget {
    max_value = 100,
    value = 0,
    forced_height = 20,
    forced_width = 100,
    shape = function(cr, w, h)
        gears.shape.rounded_rect(cr, w, h, 14)
    end,
    color = "#8c52ff",
    background_color = "#5bf0ff",
    widget = wibox.widget.progressbar
}

local disk_widget = wibox.widget {
    {
        disk_usage_text,
        disk_progressbar,
        layout = wibox.layout.fixed.horizontal
    },
    margins = 5,
    widget = wibox.container.margin
}

local function update_disk_usage()
    awful.spawn.easy_async("df -h / | awk 'NR==2 {print $5}'", function(stdout)
        local disk_usage = tonumber(stdout:match("(%d+)%%"))
        disk_progressbar:set_value(disk_usage)
        disk_usage_text:set_text("disk Usage: " .. disk_usage .. "%")
    end)
end

update_disk_usage()
gears.timer.start_new(10, function()
    update_disk_usage()
    return true
end)

local another_popup = awful.popup {
    widget = wibox.widget {
        layout = wibox.layout.fixed.vertical,
        wibox.container.margin(cpu_arc,0,0,15,0),
        wibox.container.margin(disk_progressbar,10,10,0,0),
        wibox.container.margin(memory_arc,0,0,0,15),
        forced_height = 250,
        forced_width = 150
    },
    border_width = rcnf.vars.all_widget_border_width,
    border_color = rcnf.vars.all_widget_border_color,
    bg = rcnf.vars.all_widget_background,
    ontop = false,
    shape = function(cr, w, h)
        gears.shape.rounded_rect(cr, w, h, rcnf.vars.all_widget_radius)
    end,
    
}

awful.placement.top_right(another_popup, {
    margins = {
        top = 200,
        right = 400
    },
    parent = awful.screen.focused()
})
another_popup.visible = true

return {
    speed_popup = speed_popup
}
