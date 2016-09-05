require 'cairo'

--config
-------------------------------------------------------------------------------
base = { 
    x = 440,
    y = 10,
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
    font = "M+ 1mn light",
    font_size = 22 * base.scale,
    radius = 250 * base.scale,
    interval = 30 * base.scale,
}

base.clock = {
    x = 310 * base.scale,
    y = 225 * base.scale,
    time_font = "M+ 1mn thin",
    time_font_size = 169 * base.scale,
    date_font_size = 36 * base.scale,
}
--------------------------------------------------------------------------------
function draw_monitor_ring(cr, state, label, perc, func)
    cairo_set_source_rgba(cr, base.color.r, base.color.g, base.color.b,
        base.color.a)
    if func(perc) then
        cairo_set_source_rgba(cr, 1, 0.46875, 0.68359375, 1)
    end
    cairo_arc(cr, base.x + base.monitor.x, base.y + base.monitor.y,
        base.monitor.radius + (base.monitor.interval * state.int_cnt), - math.pi/2,
        - math.pi/2 + 2.7 * perc * (math.pi/180))
    cairo_stroke(cr)

    cairo_move_to(cr, base.x + base.monitor.x - 40 * base.scale,
        base.y + base.monitor.y - (246 * base.scale + base.monitor.interval * state.int_cnt))
    cairo_select_font_face(cr, base.monitor.font, CAIRO_FONT_SLANT_NORMAL,
        CAIRO_FONT_WEIGHT_NORMAL);
    cairo_set_font_size(cr, base.monitor.font_size)
    cairo_show_text(cr, label)
    cairo_stroke(cr)
    state.int_cnt = state.int_cnt + 1
end

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
    local ring_state = {
        int_cnt = 0
    }

    --CPU
    draw_monitor_ring(cr, ring_state, "CPU", cpu_perc, function(v)
        return (v > 90)
    end)
    ---------------------------------------------------------------------------

    --Memory
    draw_monitor_ring(cr, ring_state, "MEM", mem_perc, function(v)
        return (v > 87.5)
    end)
    ---------------------------------------------------------------------------

    --Battery
    -- If bat_perc is 0, system is dead or doesn't have a battery
    if bat_perc > 0 then
        draw_monitor_ring(cr, ring_state, "BAT", bat_perc, function(v)
            return (v <= 20)
        end)
    end

    --Disk IO

    ---------------------------------------------------------------------------

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
        base.y + base.clock.y + 145 * base.scale)
    cairo_set_font_size(cr, base.clock.time_font_size)
    cairo_show_text(cr, conky_parse("${time %H:%M}"));
    cairo_stroke(cr)

    cairo_destroy(cr)
    cairo_surface_destroy(cs)
    cr=nil
end
