require 'cairo'
require 'math'
require 'bit'

--config
-------------------------------------------------------------------------------
base = { 
    --todo: make this a constructor
    display_width = 2560,
    display_height = 1600,
    scale = 1,
    x = 0,
    y = 0,
    color = {
        normal = 0x87afff,
        dark = 0x444494,
        danger = 0xff78af,
        danger_dark = 0x984768,
    },
    bat_present = true,
    ring = {},
    clock = {},
    a_clock = {},
    monitor = {},
    mpd = {},
    top = {},
}

base.ring = {
    x = base.display_width / 2,
    y = base.display_height / 2,
    font = "M+ 1mn light",
    font_size = 22 * base.scale,
    radius = 500 * base.scale,
    interval = 30 * base.scale,
}

base.a_clock = {
    s_length = base.ring.radius * 0.95,
    m_length = base.ring.radius * 0.8,
    h_length = base.ring.radius * 0.5,
    s_width = 2,
    m_width = 3,
    h_width = 4,
    fluid = true,
}

base.clock = {
    x = 50 * base.scale,
    y = 150 * base.scale,
    time_font = "M+ 1mn thin",
    date_font = "M+ 1mn thin",
    time_font_size = 200 * base.scale,
    date_font_size = 50 * base.scale,
}

base.monitor = {
    x = 20 * base.scale,
    y = 20 * base.scale,
    font = "M+ 1mn light",
    font_size = 20 * base.scale,
}

base.mpd = {
    x = 68 * base.scale,
    y = 400 * base.scale,
    font = "M+ 1mn light",
    font_size = 26 * base.scale,
    scroll_index = {
        artist = 0,
        album = 0,
        title = 0,
    },
}

base.top = {
    x = 1700 * base.scale,
    y = 100 * base.scale,
    font = "M+ 1mn light",
    font_size = 26 * base.scale,
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
    h = tonumber(conky_parse("${time %H}")) % 12
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
        cairo_rel_line_to(cr, base.a_clock.h_length * math.cos((h / 12 + m / 1440) * 2 * math.pi - math.pi / 2),
            base.a_clock.h_length * math.sin((h / 12 + m / 1440) * 2 * math.pi - math.pi / 2))
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

function draw_clock(cr)
    local r, g, b = color_convert(base.color.normal)
    cairo_set_source_rgba(cr, r, g, b, 1)
    cairo_select_font_face(cr, base.clock.date_font, CAIRO_FONT_SLANT_NORMAL,
        CAIRO_FONT_WEIGHT_NORMAL);
    cairo_move_to(cr, base.x + base.clock.x + 235 * base.scale, base.y + base.clock.y);
    cairo_set_font_size(cr, base.clock.date_font_size)
    cairo_show_text(cr, conky_parse("${time %a %b %d}"));
    cairo_stroke(cr)

    cairo_select_font_face(cr, base.clock.time_font, CAIRO_FONT_SLANT_NORMAL,
        CAIRO_FONT_WEIGHT_NORMAL);
    cairo_move_to(cr, base.x + base.clock.x,
        base.y + base.clock.y + 175 * base.scale)
    cairo_set_font_size(cr, base.clock.time_font_size)
    cairo_show_text(cr, conky_parse("${time %H:%M}"));
    cairo_stroke(cr)
end

-- draw_monitor_ring(cr, x, y, r, rad_start, rad_end, label, perc, is_red)
-- cr: cairo context
-- x: absolute x coordinate of center
-- y: absolute y coordinate of center
-- r: radius of arc
-- rad_start: starting angle of arc in radians
-- rad_end: ending angle of arc in radians
-- label: label of bar
-- perc: percentage of bar
-- is_red: function to determine if perc is in red zone
function draw_monitor_ring(cr, x, y, r, rad_start, rad_end, label, perc, is_red, allow_zero)
    if perc == 0 and not allow_zero then
        return 0
end
    if is_red(perc) then
        set_rgb_hex(cr, base.color.danger_dark)
    else
        set_rgb_hex(cr, base.color.dark)
    end
    cairo_arc(cr, x, y, r, rad_start, rad_end)
    cairo_stroke(cr)

    if is_red(perc) then
        set_rgb_hex(cr, base.color.danger)
    else
        set_rgb_hex(cr, base.color.normal)
    end
    local rad_fill = (rad_end - rad_start) * (perc / 100) + rad_start
    cairo_arc(cr, x, y, r, rad_start, rad_fill)
    cairo_stroke(cr)

    --[[
    cairo_move_to(cr, base.x + base.ring.x - 40 * base.scale,
        base.y + base.ring.y - (246 * base.scale + base.ring.interval * state.int_cnt))
    cairo_select_font_face(cr, base.ring.font, CAIRO_FONT_SLANT_NORMAL,
        CAIRO_FONT_WEIGHT_NORMAL);
    cairo_set_font_size(cr, base.ring.font_size)
    cairo_show_text(cr, label)
    cairo_stroke(cr)
    state.int_cnt = state.int_cnt + 1
    --]]
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

    cairo_move_to(cr, x, y + 8 * base.scale)
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
    cairo_move_to(cr, x + 50 * base.scale, y)
    cairo_set_line_width(cr, 10 * base.scale)
    cairo_rel_line_to(cr, base.monitor.bars.line_len, 0)
    cairo_stroke(cr)

    if (is_red(perc)) then
        set_rgb_hex(cr, base.color.danger)
    else
        set_rgb_hex(cr, base.color.normal)
    end
    cairo_move_to(cr, x + 50 * base.scale, y)
    cairo_rel_line_to(cr, base.monitor.bars.line_len * perc / 100, 0)
    cairo_stroke(cr)
end

function draw_monitor(cr)
    cpu_perc=tonumber(conky_parse("${cpu}"))
    mem_perc=tonumber(conky_parse("${memperc}"))
    bat_perc=tonumber(conky_parse("${battery_percent}"))
    --[[
    draw_monitor_bar(cr,
        base.monitor.bars.x + base.x,
        base.monitor.bars.y + base.y,
        "CPU",
        cpu_perc,
        function (v)
            return (v > 90)
        end)
    draw_monitor_bar(cr,
        base.monitor.bars.x + base.x,
        base.monitor.bars.y + base.y + 40 * base.scale,
        "MEM",
        mem_perc,
        function (v)
            return (v > 87.5)
        end)
    if (bat_perc > 0) then
        draw_monitor_bar(cr,
            base.monitor.bars.x + base.x,
            base.monitor.bars.y + base.y + 80 * base.scale,
            "BAT",
            bat_perc,
            function (v)
                return (v <= 20)
            end)
    end
    --]]
    draw_monitor_ring(cr,
        base.x + base.ring.x,
        base.y + base.ring.y,
        base.ring.radius + 20 * base.scale,
        math.pi * 4 / 8,
        math.pi * 12 / 8,
        "CPU",
        cpu_perc,
        function (v) return (v > 90) end,
        true)
    draw_monitor_ring(cr,
        base.x + base.ring.x,
        base.y + base.ring.y,
        base.ring.radius + 40 * base.scale,
        math.pi * 3 / 8,
        math.pi * 11 / 8,
        "MEM",
        mem_perc,
        function (v) return (v > 87.5) end,
        true)
    draw_monitor_ring(cr,
        base.x + base.ring.x,
        base.y + base.ring.y,
        base.ring.radius + 60 * base.scale,
                math.pi * 2 / 8,
        math.pi * 10 / 8,
        "BAT",
        bat_perc,
        function (v) return (v <= 20) end,
        false)
end

function draw_mpd(cr)
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

    cairo_select_font_face(cr, base.mpd.font, CAIRO_FONT_SLANT_NORMAL,
        CAIRO_FONT_WEIGHT_NORMAL);
    cairo_set_font_size(cr, base.mpd.font_size)
    if conky_parse("${mpd_status}") == "Playing" then
        cairo_move_to(cr, base.x + base.mpd.x, base.y + base.mpd.y)

        local str = conky_parse("${mpd_artist}")
        local artist
        str = conky_parse("${mpd_artist}")
        if str:len() > 50 then
            artist = string.sub(str,
                1 + base.mpd.scroll_index.artist,
                50 + base.mpd.scroll_index.artist)
        else
            artist = str
        end
        cairo_show_text(cr, artist)

        cairo_move_to(cr, base.x + base.mpd.x, base.y + base.mpd.y + 30 * base.scale)
        local album
        str = conky_parse("${mpd_album}")
        if str:len() > 50 then
            album = string.sub(str,
                1 + base.mpd.scroll_index.album,
                50 + base.mpd.scroll_index.album)
        else
            album = str
        end
        cairo_show_text(cr, album)

        cairo_move_to(cr, base.x + base.mpd.x, base.y + base.mpd.y + 60 * base.scale)
        local title
        str = conky_parse("${mpd_title}")
        if str:len() > 50 then
            title = string.sub(str,
                1 + base.mpd.scroll_index.title,
                50 + base.mpd.scroll_index.title)
        else
            title = str
        end
        cairo_show_text(cr, title)
        inc_scroll_index() 
        cairo_stroke(cr)

        draw_monitor_ring(cr,
            base.x + base.ring.x,
            base.y + base.ring.y,
            base.ring.radius,
            math.pi * 5 / 8,
            math.pi * 13 / 8, "MPD",
            tonumber(conky_parse("${mpd_percent}")),
            function (v) return (false) end,
            true)

    else
        cairo_move_to(cr, base.x + base.mpd.x, base.y + base.mpd.y)
        set_rgb_hex(cr, base.color.dark)
        cairo_show_text(cr, "MPD: Not playing")
        cairo_stroke(cr)
    end
end

function draw_top(cr)
    set_rgb_hex(cr, base.color.normal)
    cairo_select_font_face(cr, base.top.font, CAIRO_FONT_SLANT_NORMAL,
        CAIRO_FONT_WEIGHT_NORMAL);
    cairo_set_font_size(cr, base.top.font_size)


    cairo_move_to(cr, base.x + base.top.x, base.y + base.top.y)
    cairo_show_text(cr, "PID")
    cairo_move_to(cr, base.x + base.top.x + 100 * base.scale, base.y + base.top.y)
    cairo_show_text(cr, "Process")
    cairo_move_to(cr, base.x + base.top.x + 500 * base.scale, base.y + base.top.y)
    cairo_show_text(cr, "CPU %")
    for i = 1, 5 do
        cairo_move_to(cr, base.x + base.top.x, base.y + base.top.y + 30 * i * base.scale)
        cairo_show_text(cr, conky_parse(string.format("${top pid %d}", i)))
        cairo_move_to(cr, base.x + base.top.x + 100 * base.scale, base.y + base.top.y + 30 * i * base.scale)
        cairo_show_text(cr, conky_parse(string.format("${top name %d}", i)))
        cairo_move_to(cr, base.x + base.top.x + 500 * base.scale, base.y + base.top.y + 30 * i * base.scale)
        local cpu_perc = tonumber(conky_parse(string.format("${top cpu %d}", i))) * 100
        cairo_show_text(cr, string.format("%d%%", cpu_perc))
    end
end

function color_convert(c)
    local r = bit.rshift(c, 16)
    local g = bit.rshift(c - bit.lshift(r, 16), 8)
    local b = bit.rshift(c - bit.lshift(r, 16) - bit.lshift(g, 8), 0)
    return r / 256, g / 256, b / 256
end

function color_convert_a(c)
    local r = bit.rshift(c, 24)
    local g = bit.rshift(c - bit.lshift(r, 24), 16)
    local b = bit.rshift(c - bit.lshift(r, 24) - bit.lshift(g, 16), 8)
    local a = bit.rshift(c - bit.lshift(r, 24) - bit.lshift(g, 16) - bit.lshift(b, 8), 0)
    return r / 256, g / 256, b / 256
end

function set_rgb_hex(cr, c)
    local r, g, b = color_convert(c)
    cairo_set_source_rgb(cr, r, g, b)
end

function set_rgba_hex(cr, c)
    local r, g, b, a = color_convert_a(c)
    cairo_set_source_rgba(cr, r, g, b ,a)
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

    ----------------------------------------------------------------------------
    --draw_origin(cr)

    --Analog Clock
    draw_a_clock(cr)
    --Digital Clock
    draw_clock(cr)


    --Monitor
    draw_monitor(cr)

    --MPD
    draw_mpd(cr)

    --top
    draw_top(cr)

    ----------------------------------------------------------------------------
    cairo_destroy(cr)
    cairo_surface_destroy(cs)
    cr=nil
end
