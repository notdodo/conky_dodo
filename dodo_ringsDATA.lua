require 'cairo'


--------------------------------------------------------------------------------
--                                                                    gauge DATA
gauge = {
	{
		name='fs_used_perc',           arg='/',             max_value=80,
		x=70,                          y=72,
		graph_radius=52,
		txt_radius=68,
		caption=' root',
	},
	{
		name='fs_used_perc',           arg='/home',			max_value=80,
		x=70,                          y=72,
		graph_radius=42,
		txt_radius=30,
		caption='home',
	}
}

-------------------------------------------------------------------------------
--                                                                 rgb_to_r_g_b
-- converts color in hexa to decimal
--
function rgb_to_r_g_b(colour, alpha)
	return ((colour / 0x10000) % 0x100) / 255., ((colour / 0x100) % 0x100) / 255., (colour % 0x100) / 255., alpha
end

-------------------------------------------------------------------------------
--                                                            angle_to_position
-- convert degree to rad and rotate (0 degree is top/north)
--
function angle_to_position(start_angle, current_angle)
	local pos = current_angle + start_angle
	return ((pos * (2 * math.pi / 360)) - (math.pi / 2))
end


-------------------------------------------------------------------------------
--                                                              draw_gauge_ring
-- displays gauges
--
function draw_gauge_ring(display, data, value)
	local max_value = 80
	local x, y = data['x'], data['y']
	local graph_radius = data['graph_radius']
	local graph_thickness, graph_unit_thickness = 10, 2.7
	local graph_start_angle = 200
	local graph_unit_angle = 2.6
	local graph_bg_colour, graph_bg_alpha = 0xFFFFFF, 0.1
	local graph_fg_colour, graph_fg_alpha = 0xFFFFFF, 0.3
	local hand_fg_colour, hand_fg_alpha = 0xEF5A29, 1.0
	local graph_end_angle = (max_value * graph_unit_angle) % 360

	-- background ring
	cairo_arc(display, x, y, graph_radius, angle_to_position(graph_start_angle, 0), angle_to_position(graph_start_angle, graph_end_angle))
	cairo_set_source_rgba(display, rgb_to_r_g_b(graph_bg_colour, graph_bg_alpha))
	cairo_set_line_width(display, graph_thickness)
	cairo_stroke(display)

	-- arc of value
	local val = value * max_value / 100;
	local start_arc = 0
	local stop_arc = 0
	local i = 1
	while i <= val do
		start_arc = (graph_unit_angle * i) - graph_unit_thickness
		stop_arc = (graph_unit_angle * i)
		cairo_arc(display, x, y, graph_radius, angle_to_position(graph_start_angle, start_arc), angle_to_position(graph_start_angle, stop_arc))
		cairo_set_source_rgba(display, rgb_to_r_g_b(graph_fg_colour, graph_fg_alpha))
		cairo_stroke(display)
		i = i + 1
	end
	local angle = start_arc

	-- hand
	start_arc = (graph_unit_angle * val) - (graph_unit_thickness)
	stop_arc = (graph_unit_angle * val)
	cairo_arc(display, x, y, graph_radius, angle_to_position(graph_start_angle, start_arc), angle_to_position(graph_start_angle, stop_arc))
	cairo_set_source_rgba(display, rgb_to_r_g_b(hand_fg_colour, hand_fg_alpha))
	cairo_stroke(display)

	-- graduations marks
	local graduation_radius = 23
	local graduation_thickness, graduation_mark_thickness = 0, 2
	local graduation_unit_angle = 27
	local graduation_fg_colour, graduation_fg_alpha = 0xFFFFFF, 0.3
	if graduation_radius > 0 and graduation_thickness > 0 and graduation_unit_angle > 0 then
		local nb_graduation = graph_end_angle / graduation_unit_angle
		local i = 0
		while i < nb_graduation do
			cairo_set_line_width(display, graduation_thickness)
			start_arc = (graduation_unit_angle * i) - (graduation_mark_thickness / 2)
			stop_arc = (graduation_unit_angle * i) + (graduation_mark_thickness / 2)
			cairo_arc(display, x, y, graduation_radius, angle_to_position(graph_start_angle, start_arc), angle_to_position(graph_start_angle, stop_arc))
			cairo_set_source_rgba(display,rgb_to_r_g_b(graduation_fg_colour,graduation_fg_alpha))
			cairo_stroke(display)
			cairo_set_line_width(display, graph_thickness)
			i = i + 1
		end
	end

	-- text
	local txt_radius = data['txt_radius']
	local txt_weight, txt_size = 0, 9.0
	local txt_fg_colour, txt_fg_alpha = 0xEF5A29, 1.0
	local movex = txt_radius * math.cos(angle_to_position(graph_start_angle, angle))
	local movey = txt_radius * math.sin(angle_to_position(graph_start_angle, angle + 1))
	cairo_select_font_face (display, "Droid Sans", CAIRO_FONT_SLANT_NORMAL, txt_weight)
	cairo_set_font_size (display, txt_size)
	cairo_set_source_rgba (display, rgb_to_r_g_b(txt_fg_colour, txt_fg_alpha))
	cairo_move_to (display, x + movex - (txt_size / 2), y + movey + 3)
	cairo_show_text (display, value)
	cairo_stroke (display)

	-- caption
	local caption = data['caption']
	local caption_weight, caption_size = 1, 12.0
	local caption_fg_colour, caption_fg_alpha = 0xFFFFFF, 0.5
	local tox = graph_radius * (math.cos((graph_start_angle * 2 * math.pi / 360)-(math.pi/2)))
	local toy = graph_radius * (math.sin((graph_start_angle * 2 * math.pi / 360)-(math.pi/2)))
	cairo_select_font_face (display, "Droid Sans", CAIRO_FONT_SLANT_NORMAL, caption_weight);
	cairo_set_font_size (display, caption_size)
	cairo_set_source_rgba (display, rgb_to_r_g_b(caption_fg_colour, caption_fg_alpha))
	cairo_move_to (display, x + tox + 5, y + toy + 5)
	-- bad hack but not enough time !
	if graph_start_angle < 105 then
		cairo_move_to (display, x + tox - 30, y + toy + 1)
	end
	cairo_show_text (display, caption)
	cairo_stroke (display)
end


-------------------------------------------------------------------------------
--                                                               go_gauge_rings
-- loads data and displays gauges
--
function go_gauge_rings(display)
	local function load_gauge_rings(display, data)
		local str, value = '', 0
		str = string.format('${%s %s}',data['name'], data['arg'])
		str = conky_parse(str)
		value = tonumber(str)
		draw_gauge_ring(display, data, value)
	end

	for i in pairs(gauge) do
		load_gauge_rings(display, gauge[i])
	end
end

-------------------------------------------------------------------------------
--                                                                         MAIN
function conky_main()
	if conky_window == nil then
		return
	end

	local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height)
	local display = cairo_create(cs)

	go_gauge_rings(display)

	cairo_destroy(display)
	cairo_surface_destroy(cs)
	display=nil
end

