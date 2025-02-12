package planets

import "core:fmt"
import "core:math"
import "core:math/rand"
import rl "vendor:raylib"

WINDOW_WIDTH :: 1920
WINDOW_HEIGHT :: 1080
MAX_ZOOM :: 0.005

PIXELS_IN_AU :: f32(50.0)
SIM_YEAR :: f64(10.0) // 1 real year == 10sec
MAX_STARS :: 250

Vec2f :: [2]f32

Body :: struct {
	name:           string,
	pos:            Vec2f,
	rad:            f32,
	colour:         rl.Color,
	dis_from_sun:   f32,
	orbital_angle:  f64,
	orbital_period: f64,
}

BodyName :: enum {
	SUN,
	MERCURY,
	VENUS,
	EARTH,
	MARS,
	JUPITER,
	SATURN,
	URANUS,
	NEPTUNE,
}

celestial_bodies := make(map[BodyName]Body, 9)
stars := make([dynamic]Body, MAX_STARS)
distance_factor: f32 = 100.0
scale_factor: f32 = 10.0 / 6371.0 // Earth is 10 pixels and its real radius is 6371km

camera := rl.Camera2D {
	zoom   = 1.0,
	offset = {WINDOW_WIDTH / 2, WINDOW_HEIGHT / 2},
}
camera_focus: BodyName

panel_rect := rl.Rectangle{20, 20, 300, 530}
mouse_offset: rl.Vector2
dragging: bool
mouse_pos: rl.Vector2
real_sun_size: bool

main :: proc() {
	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Planets")
	defer rl.CloseWindow()
	rl.SetTargetFPS(60)
	rl.SetExitKey(.ESCAPE)

	rl.GuiLoadStyle("style_dark.rgs")

	setup()

	for !rl.WindowShouldClose() {
		process_input()
		update()
		render()
	}
}

sun_rad: f32 = 696340 * scale_factor

setup :: proc() {
	celestial_bodies[.SUN] = {
		name   = "Sun",
		pos    = {(WINDOW_WIDTH / 2) - sun_rad / 2, (WINDOW_HEIGHT / 2) - sun_rad / 2},
		rad    = sun_rad,
		colour = rl.YELLOW,
	}
	celestial_bodies[.MERCURY] = {
		name           = "Mercury",
		rad            = 2440.0 * scale_factor,
		dis_from_sun   = distance_factor * math.sqrt_f32(0.39),
		orbital_period = 88.0,
		colour         = {169, 169, 169, 255},
	}
	celestial_bodies[.VENUS] = {
		name           = "Venus",
		rad            = 6052 * scale_factor,
		dis_from_sun   = distance_factor * math.sqrt_f32(0.72),
		orbital_period = 255.0,
		colour         = {205, 186, 150, 255},
	}
	celestial_bodies[.EARTH] = {
		name           = "Earth",
		rad            = 6371.0 * scale_factor,
		dis_from_sun   = distance_factor * math.sqrt_f32(1.0),
		orbital_period = 365.0,
		colour         = {58, 117, 196, 255},
	}
	celestial_bodies[.MARS] = {
		name           = "Mars",
		rad            = 3390 * scale_factor,
		dis_from_sun   = distance_factor * math.sqrt_f32(1.52),
		orbital_period = 687.0,
		colour         = {201, 81, 58, 255},
	}
	celestial_bodies[.JUPITER] = {
		name           = "Jupiter",
		rad            = 69911 * scale_factor,
		dis_from_sun   = distance_factor * math.sqrt_f32(5.2),
		orbital_period = 4333.0,
		colour         = {218, 165, 105, 255},
	}
	celestial_bodies[.SATURN] = {
		name           = "Saturn",
		rad            = 58232 * scale_factor,
		dis_from_sun   = distance_factor * math.sqrt_f32(9.58),
		orbital_period = 10759.0,
		colour         = {216, 188, 126, 255},
	}
	celestial_bodies[.URANUS] = {
		name           = "Uranus",
		rad            = 25362 * scale_factor,
		dis_from_sun   = distance_factor * math.sqrt_f32(19.18),
		orbital_period = 30687.0,
		colour         = {173, 216, 230, 255},
	}
	celestial_bodies[.NEPTUNE] = {
		name           = "Neptune",
		rad            = 24622 * scale_factor,
		dis_from_sun   = distance_factor * math.sqrt_f32(30.07),
		orbital_period = 60190.0,
		colour         = {46, 89, 162, 255},
	}

	star_colours := []rl.Color{rl.LIGHTGRAY, rl.GRAY}
	for i in 0 ..< MAX_STARS {
		append(
			&stars,
			Body {
				rad = (f32(rand.int31_max(19)) + 1) / 10,
				colour = rand.choice(star_colours[:]),
				pos = Vec2f{f32(rand.int31_max(WINDOW_WIDTH)), f32(rand.int31_max(WINDOW_HEIGHT))},
			},
		)
	}

	camera_focus = .SUN
}

process_input :: proc() {
	camera.zoom += rl.GetMouseWheelMove() * 0.01
	if camera.zoom < MAX_ZOOM do camera.zoom = MAX_ZOOM

	mouse_pos = rl.GetMousePosition()

	if rl.IsMouseButtonDown(rl.MouseButton.LEFT) {
		title_bar := rl.Rectangle{panel_rect.x, panel_rect.y, panel_rect.width, 30}
		if rl.CheckCollisionPointRec(mouse_pos, title_bar) {
			dragging = true
			mouse_offset = rl.Vector2{mouse_pos.x - panel_rect.x, mouse_pos.y - panel_rect.y}
		}
	} else {
		dragging = false
	}
}

update :: proc() {
	dt := rl.GetFrameTime()

	if real_sun_size {
		(&celestial_bodies[.SUN]).rad = sun_rad
		distance_factor = 40.0
	} else {
		(&celestial_bodies[.SUN]).rad = sun_rad * 0.2
		distance_factor = 10.0
	}

	for k, b in celestial_bodies {
		bptr := &celestial_bodies[k]
		if b.dis_from_sun > 0 {
			adj_orbital_period := (bptr.orbital_period / 365.0) * SIM_YEAR
			omega := (2.0 * math.PI) / adj_orbital_period // Angular speed
			bptr.orbital_angle += omega * f64(dt)
			bptr.pos.x =
				celestial_bodies[.SUN].pos.x +
				bptr.dis_from_sun * f32(math.cos(bptr.orbital_angle)) * distance_factor
			bptr.pos.y =
				celestial_bodies[.SUN].pos.y +
				bptr.dis_from_sun * f32(math.sin(bptr.orbital_angle)) * distance_factor
		}
	}

	camera.target = celestial_bodies[camera_focus].pos

	if dragging {
		panel_rect.x = mouse_pos.x - mouse_offset.x
		panel_rect.y = mouse_pos.y - mouse_offset.y
	}
}

render :: proc() {
	rl.BeginDrawing()
	rl.ClearBackground(rl.BLACK)

	for s in stars {
		rl.DrawCircleV(s.pos, s.rad, s.colour.rgba)
	}

	rl.BeginMode2D(camera)

	for k in BodyName {
		b := celestial_bodies[k]
		rl.DrawCircleV(b.pos, b.rad, b.colour.rgba)
		rl.DrawText(
			fmt.ctprint(b.name),
			i32(b.pos.x + b.rad * 1.5),
			i32(b.pos.y - b.rad * 0.5),
			i32(10 * camera.zoom),
			rl.LIGHTGRAY,
		)
	}

	rl.EndMode2D()

	render_ui()

	rl.EndDrawing()
}

render_ui :: proc() {
	panel_padding: f32 = 8
	panel_internal_width := panel_rect.width - (panel_padding * 2)
	panel_content_top: f32 = panel_rect.y + panel_padding + 10
	panel_content_left: f32 = panel_rect.x + panel_padding
	text_line_height: f32 = 5
	btn_height: f32 = 30

	rl.GuiPanel(panel_rect, "Planets")
	rl.GuiLabel(
		{
			panel_rect.x + panel_padding,
			panel_rect.y + panel_padding,
			panel_internal_width,
			panel_content_top + panel_padding * 2.5,
		},
		"Choose a planet to zoom to:",
	)

	if rl.GuiButton({panel_content_left, panel_content_top + (btn_height * 1 + (panel_padding * 1.1 * 1)), panel_internal_width, btn_height}, "Sun") do camera_focus = .SUN
	if rl.GuiButton({panel_content_left, panel_content_top + (btn_height * 2 + (panel_padding * 1.1 * 2)), panel_internal_width, btn_height}, "Mercury") do camera_focus = .MERCURY
	if rl.GuiButton({panel_content_left, panel_content_top + (btn_height * 3 + (panel_padding * 1.1 * 3)), panel_internal_width, btn_height}, "Venus") do camera_focus = .VENUS
	if rl.GuiButton({panel_content_left, panel_content_top + (btn_height * 4 + (panel_padding * 1.1 * 4)), panel_internal_width, btn_height}, "Earth") do camera_focus = .EARTH
	if rl.GuiButton({panel_content_left, panel_content_top + (btn_height * 5 + (panel_padding * 1.1 * 5)), panel_internal_width, btn_height}, "Mars") do camera_focus = .MARS
	if rl.GuiButton({panel_content_left, panel_content_top + (btn_height * 6 + (panel_padding * 1.1 * 6)), panel_internal_width, btn_height}, "Jupiter") do camera_focus = .JUPITER
	if rl.GuiButton({panel_content_left, panel_content_top + (btn_height * 7 + (panel_padding * 1.1 * 7)), panel_internal_width, btn_height}, "Saturn") do camera_focus = .SATURN
	if rl.GuiButton({panel_content_left, panel_content_top + (btn_height * 8 + (panel_padding * 1.1 * 8)), panel_internal_width, btn_height}, "Uranus") do camera_focus = .URANUS
	if rl.GuiButton({panel_content_left, panel_content_top + (btn_height * 9 + (panel_padding * 1.1 * 9)), panel_internal_width, btn_height}, "Neptune") do camera_focus = .NEPTUNE

	rl.GuiLabel(
		{
			panel_rect.x + panel_padding,
			panel_content_top + (btn_height * 10 + (panel_padding * 1.1 * 10)) - 10,
			panel_internal_width,
			panel_content_top + panel_padding * 2.5,
		},
		"Toggles:",
	)
	if rl.GuiButton(
		{
			panel_content_left,
			panel_content_top + (btn_height * 11 + (panel_padding * 1.1 * 11)),
			panel_internal_width,
			btn_height,
		},
		"Toggle sun size",
	) {
		real_sun_size = !real_sun_size
	}
	if rl.GuiButton(
		{
			panel_content_left,
			panel_content_top + (btn_height * 12 + (panel_padding * 1.1 * 12)),
			panel_internal_width,
			btn_height,
		},
		"Zoom out to sun",
	) {
		camera.zoom = camera.zoom == 1.0 ? 0.2 : 1.0
	}
	// rl.GuiMessageBox({20, 20, 200, 100}, "Message Box", "the content", "OK;Cancel")
}

distance_in_pixels :: proc(distance_in_km: f32) -> f32 {
	// return distance_in_pixels * PIXELS_IN_AU
	return 20
}
