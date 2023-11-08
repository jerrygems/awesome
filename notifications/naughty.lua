local gears = require("gears")

local spyverse = {
    bg = "#ffffff",
    fg = "#ffffff",
    margin = 10,
    border_width = 1,
    border_color = "#ffffff",
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, 10)
    end
  }

  return {
    spyverse = spyverse
  }