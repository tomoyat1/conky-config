require 'cairo'

--config
-------------------------------------------------------------------------------
base = { 
    x = 440,
    y = 0,
    scale = 1,
    font = "M+ 1mn thin",
    color = {
        r = 0.52734375,
        g = 0.68359375,
        b = 1,
        a = 1,
    },
    monitor = {},
    clock = {},
}

base.monitor = {
    x = 510 * base.scale,
    y = 320 * base.scale,
    radius = 250 * base.scale,
    interval = 25 * base.scale,

}

base.clock = {
    x = 10 * base.scale,
    y = 140 * base.scale,
    time_font = "M+ 1mn thin",
    time_font_size = 169 * base.scale,
    date_font_size = 36 * base.scale,
}

--main draw function
-------------------------------------------------------------------------------
function conky_main()
    if conky_window == nil then
        return
    end
    local cs = cairo_xlib_surface_create(conky_window.display,
        conky_window.drawable, conky_window.visual, conky_window.height,
        conky_window.width)
    local cr = cairo_create(cs)

    cairo_select_font_face(cr, base.font, CAIRO_FONT_SLANT_NORMAL,
        CAIRO_FONT_WEIGHT_NORMAL);
    cairo_set_source_rgba(cr,base.color.r, base.color.g, base.color.b,
        base.color.a)

    --System Monitor
    cairo_set_line_width(cr,5 * base.scale)
    cairo_set_source_rgba(cr,0.52734375,0.68359375,1,1)

    cpu_perc=tonumber(conky_parse("${cpu}"))
    mem_perc=tonumber(conky_parse("${memperc}"))
    bat_perc=tonumber(conky_parse("${battery_percent}"))

    if cpu_perc > 90 then
        cairo_set_source_rgba (cr,1,0.46875,0.68359375,1)
    end
    cairo_arc(cr, base.x + base.monitor.x, base.y + base.monitor.y,
        base.monitor.radius, - math.pi/2,
        - math.pi/2 + 2.7 * cpu_perc * (math.pi/180))
    cairo_stroke(cr)

    cairo_set_source_rgba (cr,0.52734375,0.68359375,1,1)
    if mem_perc > 87.5 then
        cairo_set_source_rgba (cr,1,0.46875,0.68359375,1)
    end
    cairo_arc(cr, base.x + base.monitor.x, base.y + base.monitor.y,
        base.monitor.radius + base.monitor.interval, - math.pi/2,
        - math.pi/2 + 2.7 * mem_perc * (math.pi/180))
    cairo_stroke(cr)

    cairo_set_source_rgba (cr,0.52734375,0.68359375,1,1)
    if bat_perc < 20 then
        cairo_set_source_rgba (cr,1,0.46875,0.68359375,1)
    end
    --[[cairo_arc(cr, base.x + base.monitor.x, base.y + base.monitor.y,
        base.monitor.radius + (base.monitor.interval * 2), - math.pi/2,
        - math.pi/2 + 2.7 * bat_perc * (math.pi/180))--]]
    cairo_arc(cr, base.x + base.monitor.x, base.y + base.monitor.y,
        base.monitor.radius + (base.monitor.interval * 2), - math.pi/2,
        - math.pi/2 + 2.7 * bat_perc * (math.pi/180))
    cairo_stroke(cr)

    --Clock
    cairo_set_source_rgba( cr,base.color.r, base.color.g, base.color.b,
        base.color.a)
    cairo_select_font_face(cr, base.font, CAIRO_FONT_SLANT_NORMAL,
        CAIRO_FONT_WEIGHT_NORMAL);
    cairo_move_to(cr, base.x + base.clock.x, base.y + base.clock.y);
    cairo_set_font_size(cr, base.clock.date_font_size)
    cairo_show_text(cr, conky_parse("${time %a %b %d}"));
    cairo_stroke(cr)

    cairo_select_font_face(cr, base.clock.time_font, CAIRO_FONT_SLANT_NORMAL,
        CAIRO_FONT_WEIGHT_NORMAL);
    cairo_move_to(cr, base.x + base.clock.x - 13 * base.scale,
        base.y + base.clock.y + 140 * base.scale)
    cairo_set_font_size(cr, base.clock.time_font_size)
    cairo_show_text(cr, conky_parse("${time %H:%M}"));
    cairo_stroke(cr)

    cairo_destroy(cr)
    cairo_surface_destroy(cs)
    cr=nil
end
