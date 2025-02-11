package planets

import "core:fmt"
import rl "vendor:raylib"

WINDOW_WIDTH :: 1920
WINDOW_HEIGHT :: 1080

PIXELS_IN_AU :: f32(50.0)

Vec2f :: [2]f32

Body :: struct {
	name:         string,
	pos:          Vec2f,
	rad:          f32,
	colour:       rl.Color,
	dis_from_sun: f32,
}

// 1 AU = 149.6 million km)
// 1 AU = 50 pixels (adjustable).
// Planet	Distance from Sun (AU)	Distance (million km)
// Mercury	0.39	57.9
// Venus	0.72	108.2
// Earth	1.00	149.6
// Mars	1.52	227.9
// Jupiter	5.20	778.6
// Saturn	9.58	1,433.5
// Uranus	19.18	2,872.5
// Neptune	30.07	4,495.1

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
scale: u8 = 50

camera := rl.Camera2D {
	zoom   = 1,
	offset = {WINDOW_WIDTH / 2, WINDOW_HEIGHT / 2},
}

panel_rect := rl.Rectangle{20, 20, 300, 300}
mouse_offset: rl.Vector2
dragging: bool
mouse_pos: rl.Vector2

main :: proc() {
	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Planets")
	defer rl.CloseWindow()
	rl.SetExitKey(.ESCAPE)

	rl.GuiLoadStyle("style_dark.rgs")

	camera.target = celestial_bodies[.SUN].pos

	setup()

	for !rl.WindowShouldClose() {
		process_input()
		update()
		render()
	}
}

setup :: proc() {
	celestial_bodies[.SUN] = {
		name   = "Sun",
		pos    = {(WINDOW_WIDTH / 2) - 10.0, (WINDOW_HEIGHT / 2) - 10.0},
		rad    = 10.0,
		colour = rl.YELLOW,
	}
	celestial_bodies[.MERCURY] = {
		name         = "Mercury",
		rad          = 10.0,
		dis_from_sun = 0.39,
		colour       = {169, 169, 169, 255},
	}
	celestial_bodies[.VENUS] = {
		name         = "Venus",
		rad          = 10.0,
		dis_from_sun = 0.72,
		colour       = {205, 186, 150, 255},
	}
	celestial_bodies[.EARTH] = {
		name         = "Earth",
		rad          = 10.0,
		dis_from_sun = 1.0,
		colour       = {58, 117, 196, 255},
	}
	celestial_bodies[.MARS] = {
		name         = "Mars",
		rad          = 10.0,
		dis_from_sun = 1.52,
		colour       = {201, 81, 58, 255},
	}
	celestial_bodies[.JUPITER] = {
		name         = "Jupiter",
		rad          = 10.0,
		dis_from_sun = 5.2,
		colour       = {218, 165, 105, 255},
	}
	celestial_bodies[.SATURN] = {
		name         = "Saturn",
		rad          = 10.0,
		dis_from_sun = 9.58,
		colour       = {216, 188, 126, 255},
	}
	celestial_bodies[.URANUS] = {
		name         = "Uranus",
		rad          = 10.0,
		dis_from_sun = 19.18,
		colour       = {173, 216, 230, 255},
	}
	celestial_bodies[.NEPTUNE] = {
		name         = "Neptune",
		rad          = 10.0,
		dis_from_sun = 30.07,
		colour       = {46, 89, 162, 255},
	}
}

process_input :: proc() {
	camera.zoom += rl.GetMouseWheelMove() * 0.1

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

	for k, b in celestial_bodies {
		if b.dis_from_sun > 0 {
			// celestial_bodies[k].pos = {
			// 	(WINDOW_WIDTH / 2) - b.rad,
			// 	celestial_bodies[0].pos.y - b.dis_from_sun * 50.0,
			// }
		}
	}

	if dragging {
		panel_rect.x = mouse_pos.x - mouse_offset.x
		panel_rect.y = mouse_pos.y - mouse_offset.y
	}
}

render :: proc() {
	rl.BeginDrawing()
	rl.ClearBackground(rl.BLACK)

	rl.BeginMode2D(camera)

	for k, b in celestial_bodies {
		rl.DrawCircleV(b.pos, b.rad, b.colour.rgba)
		rl.DrawText(
			fmt.ctprint(b.name),
			i32(b.pos.x + b.rad * 1.5),
			i32(b.pos.y - b.rad * 0.5),
			10,
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
	panel_first_content_line: f32 = panel_padding + 50
	text_line_height: f32 = 5
	btn_height: f32 = 30

	rl.GuiPanel(panel_rect, "Planets")
	rl.GuiLabel(
		{
			panel_rect.x + panel_padding,
			panel_rect.y + panel_padding,
			panel_internal_width,
			panel_first_content_line,
		},
		"Choose a planet to zoom to:",
	)

	if rl.GuiButton({panel_rect.x + panel_padding, panel_rect.y + panel_first_content_line - panel_padding + text_line_height, panel_internal_width, btn_height}, "Earth") do focus("earth")
	if rl.GuiButton({panel_rect.x + panel_padding, panel_rect.y + panel_first_content_line - panel_padding + text_line_height, panel_internal_width, btn_height}, "Mars") do focus("mars")
	// rl.GuiMessageBox({20, 20, 200, 100}, "Message Box", "the content", "OK;Cancel")
}

focus :: proc(s: string) {
	camera.target = rl.Vector2{(WINDOW_WIDTH / 2) - 10, (WINDOW_HEIGHT / 2) - 10.0 - 1 * 50.0}
	// TODO:(lukefilewalker) do some easing here
	camera.zoom = 2
}

distance_in_pixels :: proc(distance_in_km: f32) -> f32 {
	// return distance_in_pixels * PIXELS_IN_AU
	return 20
}
