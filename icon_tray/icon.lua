local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")

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
        }
        local icon_with_margin = wibox.container.margin(icon_widget, 0, 0, 8, 4)

        -- Set the click event
        icon_widget:buttons(gears.table.join(
            awful.button({}, 1, function()
                awful.spawn(commandsList[i])
            end)
        ))

        icon_container:add(icon_with_margin)
    end

    return icon_container
end

return { createIconContainer = createIconContainer }