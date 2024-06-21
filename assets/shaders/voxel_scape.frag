#version 460 core

#include <flutter/runtime_effect.glsl>

#define PI 3.14159
#define RAY_DISTANCE 1000

precision highp float;

uniform float screen_x;
uniform float screen_y;
uniform float screen_width;
uniform float screen_height;
uniform float map_size;
uniform float map_scale;
uniform float player_pitch;
uniform float player_tilt;
uniform float player_angle;
uniform float player_height;
uniform float player_x;
uniform float player_y;

uniform sampler2D u_color_map;
uniform sampler2D u_height_map;

out vec4 fragColor;

const float fov = PI / 3.0;
const float h_fov = fov / 2.0;
float scale_height = screen_height;
float delta_angle = h_fov / screen_width * 2;

void main() {
    vec2 xy = FlutterFragCoord() - vec2(screen_x, screen_y);
    float tilt = player_tilt * (xy.x - screen_width / 2) / 8;
    float ray_angle = player_angle - h_fov + delta_angle * xy.x;
    float sin_a = sin(ray_angle);
    float cos_a = cos(ray_angle);
    vec2 map_uv = vec2(0.0, 0.0);
    for (int depth = 5; depth < RAY_DISTANCE; depth ++) {
        float x = player_x + depth * cos_a;
        float y = player_y + depth * sin_a;
        map_uv.x = mod(x / map_size, 1);
        map_uv.y = mod(y / map_size, 1);
        float hm = texture(u_height_map, map_uv).y * scale_height;
        float d_factor = 1 + depth * map_scale / RAY_DISTANCE;
        float d_step = cos(player_angle - ray_angle) * map_scale * d_factor;
        float d = depth * d_step;
        float height_on_screen = (player_height - hm) / d * scale_height * map_scale + player_pitch - tilt;
        if (height_on_screen < 0) height_on_screen = 0;
        if (height_on_screen > xy.y) continue;
        fragColor = texture(u_color_map, map_uv);
        break;
    }
}
