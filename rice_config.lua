local beautiful = require("beautiful")
local username = os.getenv("USER") or os.getenv("USERNAME")



local vars = {
    picom_conf_path = "/home/" .. username .. "/.config/picom/picom.conf", -- here you go for your picom config path
    wall="/home/" .. username .. "/wall3.jpg", -- Define your wallpaper here
    default_font = "JetBrainsMono Nerd Font",
    font_size = "10",
    notif_font_size = "10",
    notif_bg = "#00000000", 
    notif_fg = "#b16286",
    notif_border_width = 2,
    notfi_border_color = "#04001e",
    notif_box_radius = 14,
    notif_position = "bottom_right",
    notif_width = 300,
    notif_height = 100,
    window_border_focus = "#8c52ff",
    window_border_normal = "#5bf0ff",

    widget1_top = 100,
    widget1_left = 100,
    
    widget2_bottom = 260,
    widget2_left = 100,
    
    widget3_top = 200,
    widget3_right = 400,

    all_widget_radius=14,
    all_widget_border_width = 4,
    all_widget_background = '#00000000',
    all_widget_border_color = '#8c52ff',

    vertical_separator_line_color = '#8c52ff',
    vertical_separator_line_thickness = 3,

    separator_dots_color = '#8c52ff',
    separator_dots_height = 5,

    progress_inner_bar_color = '#8c52ff',
    progress_outer_bar_color = '#5bf0ff',


    speed_measure_on_interface = "eth0", -- OR you can use the eth0

    font_size_net_speed = 10,
    clock_font_size = 10,
}

return {
    vars = vars,
}
