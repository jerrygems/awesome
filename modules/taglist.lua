local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local rcnf = require("rice_config")

local taglist = awful.widget.taglist {
    screen = awful.screen.focused(),
    filter = function(t, args)
        if #t:clients() > 0 or t.selected then
            return true
        end
    end,

    style = {
        shape = gears.shape.powerline,
        shape_border_color = '#8c52ff',
        shape_border_width = 1,
        bg_focus = "#8c52ff",
        bg_occupied = "#00000000",
        bg_urgent = "#8c52ff",
        font = "" .. rcnf.vars.default_font .. " " .. rcnf.vars.font_size .. ""
    },
    layout = {
        spacing = -16,
        spacing_widget = {
            color = '#8c52ff',
            shape = gears.shape.powerline,
            widget = wibox.widget.separator
        },
        forced_height = 30,
        layout = wibox.layout.fixed.horizontal
    },
    widget_template = {
        {
            bg = "#8c52ff",
            {
                {
                    {

                        {
                            id = 'index_role',
                            widget = wibox.widget.textbox
                        },
                        margins = 4,
                        widget = wibox.container.margin
                    },
                    bg = '#00000000',
                    bg_focus = "#8c52ff",
                    shape = gears.shape.circle,
                    widget = wibox.container.background
                },
                {
                    {
                        id = 'icon_role',
                        widget = wibox.widget.imagebox
                    },
                    margins = 2,
                    widget = wibox.container.margin
                },
                {
                    id = 'text_role',
                    widget = wibox.widget.textbox
                },
                layout = wibox.layout.fixed.horizontal
            },
            left = 18,
            right = 18,
            widget = wibox.container.margin
        },
        id = 'background_role',
        widget = wibox.container.background,

        create_callback = function(self, c3, index, objects) 

            self:connect_signal('mouse::enter', function()
                if awful.tag.selected(mouse.screen) == c3 then
                    self.bg = '#8c52ff'
                else
                    self.bg = '#00000000'
                end
            end)
            self:connect_signal('mouse::leave', function()
                if self.has_backup then
                    self.bg = self.backup
                end
            end)
        end,
        update_callback = function(self, c3, index, objects) 
            self:get_children_by_id('index_role')[1].markup = '<b> ' .. ' </b>'
        end
    },
    buttons = taglist_buttons,
    awful.tag.add("󰋜 ", {
        icon = "",
        layout = awful.layout.suit.tile,
        master_fill_policy = "master_width_factor",
        gap_single_client = true,
        gap = 15,
        screen = s,
        selected = true

    }),
    awful.tag.add("󰜈 ", {
        icon = "",
        layout = awful.layout.suit.floating,
        master_fill_policy = "master_width_factor",
        gap_single_client = true,
        gap = 15,
        screen = s,
        selected = true

    }),
    awful.tag.add("󰜈 ", {
        icon = "",
        layout = awful.layout.suit.floating,
        master_fill_policy = "master_width_factor",
        gap_single_client = true,
        gap = 15,
        screen = s,
        selected = true

    }),
    awful.tag.add(" ", {
        icon = "",
        layout = awful.layout.suit.floating,
        master_fill_policy = "master_width_factor",
        gap_single_client = true,
        gap = 15,
        screen = s,
        selected = true

    }),
    awful.tag.add(" ", {
        icon = "",
        layout = awful.layout.suit.floating,
        master_fill_policy = "master_width_factor",
        gap_single_client = true,
        gap = 15,
        screen = s,
        selected = true

    }),
    awful.tag.add(" ", {
        icon = "",
        layout = awful.layout.suit.fair,
        master_fill_policy = "master_width_factor",
        gap_single_client = true,
        gap = 15,
        screen = s,
        selected = true

    }),
    awful.tag.add(" ", {
        icon = "",
        layout = awful.layout.suit.tile,
        master_fill_policy = "master_width_factor",
        gap_single_client = true,
        gap = 15,
        screen = s,
        selected = true

    }),
    awful.tag.add("󰎄 ", {
        icon = "",
        layout = awful.layout.suit.floating,
        master_fill_policy = "master_width_factor",
        gap_single_client = true,
        gap = 15,
        screen = s,
        selected = true

    }),
    awful.tag.add("󰭹 ", {
        icon = "",
        layout = awful.layout.suit.floating,
        master_fill_policy = "master_width_factor",
        gap_single_client = true,
        gap = 15,
        screen = s,
        selected = true

    })

}

return {
    taglist = taglist
}

