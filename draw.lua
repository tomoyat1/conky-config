require 'cairo'
require 'math'
require 'bit'

--config
-------------------------------------------------------------------------------
base = { 
    --todo: make this a constructor
    display_width = 2560,
    display_height = 1600,
    x = 0,
    y = 0,
    scale = 1,
    color = {
        normal = 0x87afff,
        dark = 0x444494,
        danger = 0xff78af,
        danger_dark = 0x984768,
    },
    ring = {},
    clock = {},
    a_clock = {},
    monitor = {},
    mpd = {},
}

base.ring = {
    x = base.display_width / 2,
    y = base.display_height / 2,
    font = "M+ 1mn light",
    font_size = 22 * base.scale,
    radius = 700 * base.scale,
    interval = 30 * base.scale,
}

base.a_clock = {
    s_length = base.ring.radius * base.scale,
    m_length = base.ring.radius * 0.8 * base.scale,
    h_length = base.ring.radius * 0.5 * base.scale,
    s_width = 2,
    m_width = 3,
    h_width = 4,
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
    x = 20,
    y = 20,
    font = "M+ 1mn light",
    font_size = 20 * base.scale,
}

base.monitor.bars = {
    x = 50,
    y = 400,
    font = "M+ 1mn light",
    font_size = 26 * base.scale,
    line_len = 800,
}


base.mpd = {
    x = base.monitor.x + 30 * base.scale,
    y = base.monitor.y + 50 * base.scale,
    font = "M+ 1mn light",
    font_size = 20 * base.scale,
    scroll_index = {
        artist = 0,
        album = 0,
        title = 0,
    },
}
--------------------------------------------------------------------------------
function draw_origin(cr)
    cairo_set_line_width(cr, 10)
    cairo_set_source_rgba(cr, 0, 0, 0, 1)
    cairo_move_to(cr, base.x, base.y)
    cairo_line_to(cr, base.x + 10, base.y)
    cairo_stroke(cr);
end
function draw_a_clock(cr)
    s = tonumber(conky_parse("${time %S}"))
    m = tonumber(conky_parse("${time %M}"))
    h = tonumber(conky_parse("${time %H}"))
    cairo_set_line_width(cr,base.a_clock.s_width)
    local r, g, b = color_convert(base.color.dark)
    cairo_set_source_rgba(cr, r, g, b, 1)
    if base.a_clock.fluid then
        cairo_move_to(cr, base.x + base.ring.x, base.y + base.ring.y)
        cairo_rel_line_to(cr, base.a_clock.s_length * math.cos(s / 60 * 2 * math.pi - math.pi / 2),
            base.a_clock.s_length * math.sin(s / 60 * 2 * math.pi - math.pi / 2))
        cairo_stroke(cr)

        cairo_set_line_width(cr,base.a_clock.m_width)
        cairo_move_to(cr, base.x + base.ring.x, base.y + base.ring.y)
        cairo_rel_line_to(cr, base.a_clock.m_length * math.cos((m / 60 + s / 3600) * 2 * math.pi - math.pi / 2),
            base.a_clock.m_length * math.sin((m / 60 + s / 3600) * 2 * math.pi - math.pi / 2))
        cairo_stroke(cr)
        cairo_set_line_width(cr,base.a_clock.h_width)
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
        cairo_move_to(cr, base.x + base.ring.x, base.y + base.ring.y)
        cairo_rel_line_to(cr, base.a_clock.m_length * math.cos(m / 60 * 2 * math.pi - math.pi / 2),
            base.a_clock.m_length * math.sin(m / 60 * 2 * math.pi - math.pi / 2))
        cairo_stroke(cr)

        cairo_set_line_width(cr,base.a_clock.h_width)
        cairo_move_to(cr, base.x + base.ring.x, base.y + base.ring.y)
        cairo_rel_line_to(cr, base.a_clock.h_length * math.cos(h / 60 * 2 * math.pi - math.pi / 2),
            base.a_clock.h_length * math.sin(h / 60 * 2 * math.pi - math.pi / 2))
        cairo_stroke(cr)
    end
end

function draw_monitor_ring(cr, state, label, perc, func)
    local r, g, b = color_convert(base.color.normal)
    cairo_set_source_rgba(cr, r, g, b, 1)
    if func(perc) then
        local r, g, b = color_convert(base.color.danger)
        cairo_set_source_rgba(cr, r, g, b, 1)
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

-- draw_monitor_bar(cr, x, y, label, perc, is_red)
-- cr: cairo context
-- x: absolute x coordinate of bar
-- y: absolute y coordinate of bar
-- label: label of bar
-- perc: percentage of bar
-- is_red: function to determine if perc is in red zone
function draw_monitor_bar(cr, x, y, label, perc, is_red)
    set_rgb_hex(cr, base.color.normal)

    cairo_move_to(cr, x, y + 8)
    cairo_select_font_face(cr, base.monitor.bars.font, CAIRO_FONT_SLANT_NORMAL,
        CAIRO_FONT_WEIGHT_NORMAL);
    cairo_set_font_size(cr, base.monitor.bars.font_size)
    cairo_show_text(cr, label)
    cairo_stroke(cr)

    if (is_red(perc)) then
        set_rgb_hex(cr, base.color.danger_dark)
    else
        set_rgb_hex(cr, base.color.dark)
    end
    cairo_move_to(cr, x + 50, y)
    cairo_set_line_width(cr, 10)
    cairo_rel_line_to(cr, base.monitor.bars.line_len, 0)
    cairo_stroke(cr)

    if (is_red(perc)) then
        set_rgb_hex(cr, base.color.danger)
    else
        set_rgb_hex(cr, base.color.normal)
    end
    cairo_move_to(cr, x + 50, y)
    cairo_rel_line_to(cr, base.monitor.bars.line_len * perc / 100, 0)
    cairo_stroke(cr)
end

function draw_monitor(cr)
    draw_monitor_bar(cr,
        base.monitor.bars.x + base.x,
        base.monitor.bars.y + base.y,
        "CPU",
        50,
        function (v)
            return (v > 90)
        end)
    draw_monitor_bar(cr,
        base.monitor.bars.x + base.x,
        base.monitor.bars.y + base.y + 40,
        "MEM",
        90,
        function (v)
            return (v > 87.5)
        end)
end

function inc_scroll_index()
    base.mpd.scroll_index.title = base.mpd.scroll_index.title + 1
    base.mpd.scroll_index.artist = base.mpd.scroll_index.artist + 1
    base.mpd.scroll_index.album = base.mpd.scroll_index.album + 1

    if base.mpd.scroll_index.title > conky_parse("${mpd_title}"):len() then
        base.mpd.scroll_index.title = 0
    end
    if base.mpd.scroll_index.artist > conky_parse("${mpd_artist}"):len() then
        base.mpd.scroll_index.artist = 0
    end
    if base.mpd.scroll_index.album > conky_parse("${mpd_album}"):len() then
        base.mpd.scroll_index.album = 0
    end

end

function color_convert(c)
    r = bit.rshift(c, 16)
    g = bit.rshift(c - bit.lshift(r, 16), 8)
    b = bit.rshift(c - bit.lshift(r, 16) - bit.lshift(g, 8), 0)
    return r / 256, g / 256, b / 256
end

function set_rgb_hex(cr, c)
    local r, g, b = color_convert(c)
    cairo_set_source_rgb(cr, r, g, b, 1)
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

    --draw_origin(cr)

    --Analog Clock
    draw_a_clock(cr)

    --Monitor
    draw_monitor(cr)

    ----------------------------------------------------------------------------


    --System Monitor
    --[[
    cairo_set_line_width(cr,5 * base.scale)
    local r, g, b = color_convert(base.color.normal)
    cairo_set_source_rgba(cr, r, g, b, 1)

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
    local r, g, b = color_convert(base.color.normal)
    cairo_set_source_rgba(cr, r, g, b, 1)
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
    local r, g, b = color_convert(base.color.normal)
    cairo_set_source_rgba(cr, r, g, b, 1)
    cairo_select_font_face(cr, base.monitor.font, CAIRO_FONT_SLANT_NORMAL,
        CAIRO_FONT_WEIGHT_NORMAL);
    cairo_set_font_size(cr, base.monitor.font_size)
    cairo_move_to(cr, base.x + base.monitor.x , base.y + base.monitor.y)
    cairo_show_text(cr, conky_parse("Read  ${diskio_read}"))
    cairo_move_to(cr, base.x + base.monitor.x, base.y + base.monitor.y + 20 * base.scale)
    cairo_show_text(cr, conky_parse("Write ${diskio_write}"))
    cairo_move_to(cr, base.x + base.monitor.x + 160 * base.scale, base.y + base.monitor.y)
    cairo_show_text(cr, conky_parse("Up    ${upspeed}"))
    cairo_move_to(cr, base.x + base.monitor.x + 160 * base.scale, base.y + base.monitor.y + 20 * base.scale)
    cairo_show_text(cr, conky_parse("Down  ${downspeed}"))

    --MPD
    if conky_parse("${mpd_status}") == "Playing" then
        local title_perc = tonumber(conky_parse("${mpd_percent}")) / 100
        cairo_move_to(cr, base.x + base.mpd.x, base.y + base.mpd.y)

        local str = conky_parse("${mpd_artist}")
        local artist
        str = conky_parse("${mpd_artist}")
        if str:len() > 27 then
            artist = string.sub(str,
                1 + base.mpd.scroll_index.artist,
                27 + base.mpd.scroll_index.artist)
        else
            artist = str
        end
        cairo_show_text(cr, artist)

        cairo_move_to(cr, base.x + base.mpd.x, base.y + base.mpd.y + 20 * base.scale)
        local album
        str = conky_parse("${mpd_album}")
        if str:len() > 27 then
            album = string.sub(str,
                1 + base.mpd.scroll_index.album,
                27 + base.mpd.scroll_index.album)
        else
            album = str
        end
        cairo_show_text(cr, album)

        cairo_move_to(cr, base.x + base.mpd.x, base.y + base.mpd.y + 40 * base.scale)
        local title
        str = conky_parse("${mpd_title}")
        if str:len() > 27 then
            title = string.sub(str,
                1 + base.mpd.scroll_index.title,
                27 + base.mpd.scroll_index.title)
        else
            title = str
        end
        cairo_show_text(cr, title)
        inc_scroll_index() 

        local r, g, b = color_convert(base.color.dark)
        cairo_set_source_rgba(cr, r, g, b, 1)
        cairo_move_to(cr, base.x + base.mpd.x, base.y + base.mpd.y + 55 * base.scale)
        cairo_set_line_width(cr, 5)
        cairo_rel_line_to(cr, 270 * base.scale, 0)
        cairo_stroke(cr)

        local r, g, b = color_convert(base.color.normal)
        cairo_set_source_rgba(cr, r, g, b, 1)
        cairo_move_to(cr, base.x + base.mpd.x, base.y + base.mpd.y + 55 * base.scale)
        cairo_set_line_width(cr, 5 * base.scale)
        cairo_rel_line_to(cr, 270 * base.scale * title_perc, 0)
        cairo_stroke(cr)
    else
        cairo_move_to(cr, base.x + base.mpd.x, base.y + base.mpd.y + 60 * base.scale)
        local r, g, b = color_convert(base.color.dark)
        cairo_set_source_rgba(cr, r, g, b, 1)
        cairo_show_text(cr, "MPD: Not playing")
        cairo_stroke(cr)

    end
    --]]
    ----------------------------------------------------------------------------
    cairo_destroy(cr)
    cairo_surface_destroy(cs)
    cr=nil
end
