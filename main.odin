package planets

import "core:fmt"
import rl "vendor:raylib"

Vec2f :: [2]f32

Body :: struct {
	name:         string,
	pos:          Vec2f,
	rad:          f32,
	colour:       rl.Color,
	dis_from_sun: f32,
}

WINDOW_WIDTH :: 1920
WINDOW_HEIGHT :: 1080

PIXELS_IN_AU :: f32(50.0)

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

scale: u8 = 50
celestial_bodies := []Body {
	{
		name = "Sun",
		pos = {(WINDOW_WIDTH / 2) - 10.0, (WINDOW_HEIGHT / 2) - 10.0},
		rad = 10.0,
		colour = rl.YELLOW,
	},
	{name = "Mercury", rad = 10.0, dis_from_sun = 0.39, colour = {169, 169, 169, 255}},
	{name = "Venus", rad = 10.0, dis_from_sun = 0.72, colour = {205, 186, 150, 255}},
	{name = "Earth", rad = 10.0, dis_from_sun = 1.0, colour = {58, 117, 196, 255}},
	{name = "Mars", rad = 10.0, dis_from_sun = 1.52, colour = {201, 81, 58, 255}},
	{name = "Jupiter", rad = 10.0, dis_from_sun = 5.2, colour = {218, 165, 105, 255}},
	{name = "Saturn", rad = 10.0, dis_from_sun = 9.58, colour = {216, 188, 126, 255}},
	{name = "Uranus", rad = 10.0, dis_from_sun = 19.18, colour = {173, 216, 230, 255}},
	{name = "Neptune", rad = 10.0, dis_from_sun = 30.07, colour = {46, 89, 162, 255}},
}

camera := rl.Camera2D {
	zoom   = 1,
	offset = {WINDOW_WIDTH / 2, WINDOW_HEIGHT / 2},
	target = celestial_bodies[0].pos,
}

main :: proc() {
	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Planets")

	for !rl.WindowShouldClose() {
		process_input()
		update()
		render()
	}

	rl.CloseWindow()
}

process_input :: proc() {
	camera.zoom += rl.GetMouseWheelMove() * 0.1
	camera.target = rl.GetMousePosition()
}

update :: proc() {
	dt := rl.GetFrameTime()

	for b, i in celestial_bodies {
		if b.dis_from_sun > 0 {
			celestial_bodies[i].pos = {
				(WINDOW_WIDTH / 2) - b.rad,
				celestial_bodies[0].pos.y - b.dis_from_sun * 50.0,
			}
		}
	}
}

render :: proc() {
	rl.BeginDrawing()
	rl.BeginMode2D(camera)
	rl.ClearBackground(rl.BLACK)

	for b in celestial_bodies {
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
	rl.EndDrawing()
}

distance_in_pixels :: proc(distance_in_km: f32) -> f32 {
	// return distance_in_pixels * PIXELS_IN_AU
	return 20
}
