package planets

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
	{name = "Mercury", rad = 10.0, dis_from_sun = 0.39, colour = rl.RED},
	{name = "Venus", rad = 10.0, dis_from_sun = 0.72, colour = rl.ORANGE},
	{name = "Earth", rad = 10.0, dis_from_sun = 1.0, colour = rl.GREEN},
	{name = "Mars", rad = 10.0, dis_from_sun = 1.52, colour = rl.RED},
	{name = "Jupiter", rad = 10.0, dis_from_sun = 5.2, colour = rl.BLUE},
	{name = "Saturn", rad = 10.0, dis_from_sun = 9.58, colour = rl.BROWN},
	{name = "Uranus", rad = 10.0, dis_from_sun = 19.18, colour = rl.BLUE},
	{name = "Neptune", rad = 10.0, dis_from_sun = 30.07, colour = rl.BLUE},
}

main :: proc() {
	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Planets")

	for !rl.WindowShouldClose() {
		rl.BeginDrawing()

		update()

		rl.ClearBackground(rl.BLACK)
		render()

		rl.EndDrawing()
	}

	rl.CloseWindow()
}

render :: proc() {
	for b in celestial_bodies {
		rl.DrawCircleV(b.pos, b.rad, b.colour.rgba)
	}
}

update :: proc() {
	for b, i in celestial_bodies {
		if b.dis_from_sun > 0 {
			celestial_bodies[i].pos = {
				(WINDOW_WIDTH / 2) - b.rad,
				celestial_bodies[0].pos.y - b.dis_from_sun * 50.0,
			}
		}
	}
}

distance_in_pixels :: proc(distance_in_km: f32) -> f32 {
	// return distance_in_pixels * PIXELS_IN_AU
	return 20
}
