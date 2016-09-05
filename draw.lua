require 'cairo'
require 'math'

--config
-------------------------------------------------------------------------------
base = { 
    x = 440,
    y = 10,
    scale = 1,
    color = {
        r = 0.52734375,
        g = 0.68359375,
        b = 1,
        a = 1,
    },
    ring = {},
    clock = {},
    a_clock = {},
    monitor = {},
}

base.ring = {
    x = 510 * base.scale,
    y = 320 * base.scale,
    font = "M+ 1mn light",
    font_size = 22 * base.scale,
    radius = 250 * base.scale,
    interval = 30 * base.scale,
}

base.a_clock = {
    s_length = base.ring.radius * base.scale,
    m_length = base.ring.radius * 0.8 * base.scale,
    h_length = base.ring.radius * 0.5 * base.scale,
    s_width = 1,
    m_width = 2,
    h_width = 3,
    fluid = true,
}

base.clock = {
    x = 310 * base.scale,
    y = 225 * base.scale,
    time_font = "M+ 1mn thin",
    date_font = "M+ 1mn thin",
    time_font_size = 169 * base.scale,
    date_font_size = 36 * base.scale,
}

base.monitor = {
    x = base.clock.x + 35 * base.scale,
    y = base.clock.y + 180 * base.scale,
    font = "M+ 1mn light",
    font_size = 20 * base.scale,
}
--------------------------------------------------------------------------------
function draw_monitor_ring(cr, state, label, perc, func)
    cairo_set_source_rgba(cr, base.color.r, base.color.g, base.color.b,
        base.color.a)
    if func(perc) then
        cairo_set_source_rgba(cr, 1, 0.46875, 0.68359375, 1)
    end
    cairo_arc(cr, base.x + base.ring.x, base.y + base.ring.y,
        base.ring.radius + (base.ring.interval * state.int_cnt), - math.pi/2,
        - math.pi/2 + 2.7 * perc * (math.pi/180))
    cairo_stroke(cr)

    cairo_move_to(cr, base.x + base.ring.x - 40 * base.scale,
        base.y + base.ring.y - (246 * base.scale + base.ring.interval * state.int_cnt))
    cairo_select_font_face(cr, base.ring.font, CAIRO_FONT_SLANT_NORMAL,
        CAIRO_FONT_WEIGHT_NORMAL);
    cairo_set_font_size(cr, base.ring.font_size)
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

    --Analog Clock
    s = tonumber(conky_parse("${time %S}"))
    m = tonumber(conky_parse("${time %M}"))
    h = tonumber(conky_parse("${time %H}"))
    cairo_set_line_width(cr,base.a_clock.s_width)
    cairo_set_source_rgba(cr,0.265625,00.265625,0.578125,1)
    if base.a_clock.fluid then
        cairo_move_to(cr, base.x + base.ring.x, base.y + base.ring.y)
        cairo_rel_line_to(cr, base.a_clock.s_length * math.cos(s / 60 * 2 * math.pi - math.pi / 2),
            base.a_clock.s_length * math.sin(s / 60 * 2 * math.pi - math.pi / 2))
        cairo_stroke(cr)

        cairo_set_line_width(cr,base.a_clock.m_width)
        cairo_set_source_rgba(cr,0.265625,00.265625,0.578125,1)
        cairo_move_to(cr, base.x + base.ring.x, base.y + base.ring.y)
        cairo_rel_line_to(cr, base.a_clock.m_length * math.cos((m / 60 + s / 3600) * 2 * math.pi - math.pi / 2),
            base.a_clock.m_length * math.sin((m / 60 + s / 3600) * 2 * math.pi - math.pi / 2))
        cairo_stroke(cr)
        cairo_set_line_width(cr,base.a_clock.h_width)
        cairo_set_source_rgba(cr,0.265625,00.265625,0.578125,1)
        cairo_move_to(cr, base.x + base.ring.x, base.y + base.ring.y)
        cairo_rel_line_to(cr, base.a_clock.h_length * math.cos((h / 60 + m / 3600) * 2 * math.pi - math.pi / 2),
            base.a_clock.h_length * math.sin((h / 60 + m / 3600) * 2 * math.pi - math.pi / 2))
        cairo_stroke(cr)
    else
        cairo_move_to(cr, base.x + base.ring.x, base.y + base.ring.y)
        cairo_rel_line_to(cr, base.a_clock.s_length * math.cos(s / 60 * 2 * math.pi - math.pi / 2),
            base.a_clock.s_length * math.sin(s / 60 * 2 * math.pi - math.pi / 2))
        cairo_stroke(cr)

        cairo_set_line_width(cr,base.a_clock.m_width)
        cairo_set_source_rgba(cr,0.265625,00.265625,0.578125,1)
        cairo_move_to(cr, base.x + base.ring.x, base.y + base.ring.y)
        cairo_rel_line_to(cr, base.a_clock.m_length * math.cos(m / 60 * 2 * math.pi - math.pi / 2),
            base.a_clock.m_length * math.sin(m / 60 * 2 * math.pi - math.pi / 2))
        cairo_stroke(cr)

        cairo_set_line_width(cr,base.a_clock.h_width)
        cairo_set_source_rgba(cr,0.265625,00.265625,0.578125,1)
        cairo_move_to(cr, base.x + base.ring.x, base.y + base.ring.y)
        cairo_rel_line_to(cr, base.a_clock.h_length * math.cos(h / 60 * 2 * math.pi - math.pi / 2),
            base.a_clock.h_length * math.sin(h / 60 * 2 * math.pi - math.pi / 2))
        cairo_stroke(cr)
    end


    ----------------------------------------------------------------------------


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
    --Memory
    draw_monitor_ring(cr, ring_state, "MEM", mem_perc, function(v)
        return (v > 87.5)
    end)
    --Battery
    -- If bat_perc is 0, system is dead or doesn't have a battery
    if bat_perc > 0 then
        draw_monitor_ring(cr, ring_state, "BAT", bat_perc, function(v)
            return (v <= 20)
        end)
    end
    ---------------------------------------------------------------------------

    --Clock
    cairo_set_source_rgba( cr,base.color.r, base.color.g, base.color.b,
        base.color.a)
    cairo_select_font_face(cr, base.clock.date_font, CAIRO_FONT_SLANT_NORMAL,
        CAIRO_FONT_WEIGHT_NORMAL);
    cairo_move_to(cr, base.x + base.clock.x + 30, base.y + base.clock.y);
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


    --Monitor
    cairo_set_source_rgba( cr,base.color.r, base.color.g, base.color.b,
        base.color.a)
    cairo_select_font_face(cr, base.monitor.font, CAIRO_FONT_SLANT_NORMAL,
        CAIRO_FONT_WEIGHT_NORMAL);
    cairo_set_font_size(cr, base.monitor.font_size)
    cairo_move_to(cr, base.x + base.monitor.x , base.y + base.monitor.y)
    cairo_show_text(cr, conky_parse("Read  ${diskio_read}"))
    cairo_move_to(cr, base.x + base.monitor.x, base.y + base.monitor.y + 20 * base.scale)
    cairo_show_text(cr, conky_parse("Write ${diskio_write}"))
    cairo_move_to(cr, base.x + base.monitor.x + 160 * base.scale, base.y + base.monitor.y)
    cairo_show_text(cr, conky_parse("Up    ${upspeed wlp7s0}"))
    cairo_move_to(cr, base.x + base.monitor.x + 160 * base.scale, base.y + base.monitor.y + 20 * base.scale)
    cairo_show_text(cr, conky_parse("Down  ${downspeed wlp7s0}"))

    cairo_stroke(cr)
    ----------------------------------------------------------------------------
    cairo_destroy(cr)
    cairo_surface_destroy(cs)
    cr=nil
end
