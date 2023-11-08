local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")


local icon1 = "/home/spidey/.config/awesome/iconion/house1.png"
local icon2 = "/home/spidey/.config/awesome/iconion/bash.png"
local icon3 = "/home/spidey/.config/awesome/iconion/bash.png"
local icon4 = "/home/spidey/.config/awesome/iconion/bash.png"
local icon5 = "/home/spidey/.config/awesome/iconion/browser.png"
local icon6 = "/home/spidey/.config/awesome/iconion/vm.png"
local icon7 = "/home/spidey/.config/awesome/iconion/code1.png"
local icon8 = "/home/spidey/.config/awesome/iconion/code1.png"
local icon9 = "/home/spidey/.config/awesome/iconion/chat.png"

local taglist = awful.widget.taglist {
    screen          = awful.screen.focused(),
    filter          = function(t, args)
        if #t:clients() > 0 or t.selected then
            return true
        end
    end,

    style           = {
        shape = gears.shape.powerline,
        shape_border_color = '#8c52ff',
        shape_border_width = 1,
        bg_focus = "#8c52ff",
        bg_occupied = "#00000000",
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
                    self.bg = '#8c52ff' -- Active tag background color
                else
                    self.bg = '#00000000' -- Inactive tag background color
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

return {
    taglist = taglist
}
