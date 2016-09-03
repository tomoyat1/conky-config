require 'cairo'

function conky_main()
    if conky_window == nil then
        return
    end
    local cs = cairo_xlib_surface_create(conky_window.display,
                                         conky_window.drawable,
                                         conky_window.visual,
                                         conky_window.height,
                                         conky_window.width)
    local cr = cairo_create(cs)
    -- I know, origin is bogus
    x_base = 700
    y_base = -30

    cairo_select_font_face(cr, "M+ 1mn thin", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL);
    cairo_set_source_rgba (cr,0.52734375,0.68359375,1,1)

    cairo_set_line_width (cr,5)
    cairo_set_source_rgba (cr,0.52734375,0.68359375,1,1)

    cpu_perc=tonumber(conky_parse("${cpu}"))
    mem_perc=tonumber(conky_parse("${memperc}"))
    bat_perc=tonumber(conky_parse("${battery_percent}"))

    if cpu_perc > 90 then
        cairo_set_source_rgba (cr,1,0.46875,0.68359375,1)
    end
    cairo_arc (cr, x_base + 250, y_base + 350, 250, - math.pi/2, - math.pi/2 + 2.7 * cpu_perc * (math.pi/180))
    cairo_stroke(cr)

    cairo_set_source_rgba (cr,0.52734375,0.68359375,1,1)
    if mem_perc > 87.5 then
        cairo_set_source_rgba (cr,1,0.46875,0.68359375,1)
    end
    cairo_arc (cr, x_base + 250, y_base + 350, 275, - math.pi/2, - math.pi/2 + 2.7 * mem_perc * (math.pi/180))
    cairo_stroke(cr)

    cairo_set_source_rgba (cr,0.52734375,0.68359375,1,1)
    if bat_perc < 20 then
        cairo_set_source_rgba (cr,1,0.46875,0.68359375,1)
    end
    --cairo_arc (cr, x_base + 250, y_base + 350, 300, - math.pi/2, - math.pi/2 + 2.7 * 100 * (math.pi/180))
    cairo_arc (cr, x_base + 250, y_base + 350, 300, - math.pi/2, - math.pi/2 + 2.7 * bat_perc * (math.pi/180))
    cairo_stroke(cr)

    x_clock_base = -250
    y_clock_base = 170
    cairo_set_source_rgba (cr,0.52734375,0.68359375,1,1)
    cairo_select_font_face(cr, "M+ 1mn light", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL);
    cairo_move_to(cr, x_base + x_clock_base, y_base + y_clock_base);
    cairo_set_font_size(cr, 36)
    cairo_show_text(cr, conky_parse("${time %a %b %d}"));
    cairo_stroke(cr)

    cairo_select_font_face(cr, "M+ 1mn thin", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL);
    cairo_move_to(cr, x_base + x_clock_base - 13, y_base + y_clock_base + 140)
    cairo_set_font_size(cr, 169)
    cairo_show_text(cr, conky_parse("${time %H:%M}"));
    cairo_stroke(cr)

    cairo_destroy(cr)
    cairo_surface_destroy(cs)
    cr=nil
end
