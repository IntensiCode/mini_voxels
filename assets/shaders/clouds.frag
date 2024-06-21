#version 460 core

#include <flutter/runtime_effect.glsl>

precision highp float;

// Author: Tim Gerritsen
// Title: Fluffy clouds

#define PI 3.1415926536
#define MAX_CLOUD_DEPTH 12
#define MAX_NOISE_ITERATION 5

uniform vec2 iResolution;
uniform float x_off;
uniform float y_off;
uniform float z_off;
uniform float x_rot;
uniform float y_rot;
uniform float z_rot;

out vec4 fragColor;

struct Ray
{
    vec3 origin;
    vec3 direction;
};

float rand(vec3 p)
{
    return fract(sin(dot(p, vec3(1210.3, 303.9, 909.234234))) * 1337.127213);
}

mat3 rotX(float a) { return mat3(1, 0, 0, 0, cos(a), -sin(a), 0, sin(a), cos(a)); }
mat3 rotY(float a) { return mat3(cos(a), 0, sin(a), 0, 1, 0, -sin(a), 0, cos(a)); }
mat3 rotZ(float a) { return mat3(cos(a), -sin(a), 0, sin(a), cos(a), 0, 0, 0, 1); }

const mat3 m3 = mat3(0.00, 0.80, 0.60, -0.80, 0.36, -0.48, -0.60, -0.48, 0.64);
const mat3 m3i = mat3(0.00, -0.80, -0.60, 0.80, 0.36, -0.48, 0.60, -0.48, 0.64);

vec4 noised(in vec3 x)
{
    vec3 p = floor(x);
    vec3 w = fract(x);
    vec2 o = vec2(0.0, 1.0);

    vec3 u = w * w * w * (w * (w * 6.0 - 15.0) + 10.0);
    vec3 du = 30.0 * w * w * (w * (w - 2.0) + 1.0);

    float a = rand(p + o.xxx);
    float b = rand(p + o.yxx);
    float c = rand(p + o.xyx);
    float d = rand(p + o.yyx);
    float e = rand(p + o.xxy);
    float f = rand(p + o.yxy);
    float g = rand(p + o.xyy);
    float h = rand(p + o.yyy);

    float k0 = a;
    float k1 = b - a;
    float k2 = c - a;
    float k3 = e - a;
    float k4 = a - b - c + d;
    float k5 = a - c - e + g;
    float k6 = a - b - e + f;
    float k7 = -a + b + c - d + e - f - g + h;

    return vec4((k0 + k1 * u.x + k2 * u.y + k3 * u.z + k4 * u.x * u.y + k5 * u.y * u.z + k6 * u.z * u.x + k7 * u.x * u.y * u.z),
                2.0 * du * vec3(k1 + k4 * u.y + k6 * u.z + k7 * u.y * u.z,
                                k2 + k5 * u.z + k4 * u.x + k7 * u.z * u.x,
                                k3 + k6 * u.x + k5 * u.y + k7 * u.x * u.y));
}

vec4 fbm(in vec3 x, int octaves)
{
    float f = 2.;
    float s = 0.5;
    float a = 0.0;
    float b = 0.5;
    vec3 d = vec3(0.0);
    vec2 o = vec2(0.0, 1.0);
    mat3 m = mat3(o.yxx, o.xyx, o.xxy);
    for (int i = 0; i < MAX_NOISE_ITERATION; i++) {
        vec4 n = noised(x);
        a += b * n.x;
        d += b * m * n.yzw;
        b *= s;
        x = f * m3 * x;
        m = f * m3i * m;
    }
    return vec4(a, d);
}

vec3 camRay(float fov, vec2 screenSize, vec2 uv)
{
    vec2 xy = uv - screenSize / 2.0;
    float z = screenSize.y / tan(radians(fov) / 2.0);
    return normalize(vec3(xy, -z));
}

Ray initCamera(vec2 uv, vec2 resolution)
{
    //    vec3 camPosition = vec3(0, 0, 0);
    vec3 camPosition = vec3(x_off, y_off, z_off);
    vec3 camRotation = vec3(x_rot, y_rot, z_rot);
    float camFov = 75.;

    vec3 forward = vec3(0.0, 0.0, 1.0);
    vec3 up = vec3(0.0, 1.0, 0.0);
    forward = normalize((rotY(-camRotation.y) * rotX(camRotation.x)) * forward);

    vec3 normal = normalize(cross(forward, up));
    up = normalize(cross(normal, forward));
    vec3 ray = camRay(camFov, resolution, uv * resolution);
    vec3 rayDirection = normalize(mat3(normal, up, -forward) * ray);

    return Ray(camPosition, rayDirection);
}

void main()
{
    vec2 fragCoord = FlutterFragCoord();
    vec2 uv = fragCoord.xy / iResolution.xy;
    uv.y = 1 - uv.y;
    uv.y -= (uv.x - 0.5) * z_rot * 2;
    Ray ray = initCamera(uv.xy, iResolution.xy);

    vec3 up = vec3(0.0, 50. - ray.origin.y, 0.0);
    float cosalpha = abs(dot(ray.direction, normalize(up)));
    float lengthToCloud = up.y / cosalpha;
    float cloudStep = 1.5 / cosalpha;
    vec3 forward = ray.direction * lengthToCloud;

    vec4 colorSkyFront = vec4(0.243, 0.51, 0.804, 1);
    vec4 colorSkyBack = vec4(0.667, 0.753, 0.812, 0.003);
    vec4 colorGroundFront = vec4(0, 0.3, 0, 1);
    vec4 colorGroundBack = vec4(0, 0.14, 0, 0.001);
    vec3 skyColor = mix(colorSkyFront.rgb, colorSkyBack.rgb, clamp(lengthToCloud * colorSkyBack.w, 0.0, 1.0)).rgb;
    vec3 groundColor = mix(colorGroundFront.rgb, colorGroundBack.rgb, clamp(lengthToCloud * colorGroundBack.w, 0.0, 1.0)).rgb;

    float pointingToAir = step(0.0, ray.origin.y + forward.y);
    vec3 color = groundColor * (1.0 - pointingToAir);
    float cloudness = 0.0;
    float invCloudSize = .1 / 5.;
    if (pointingToAir > 0.0) {
        float depth = lengthToCloud;
        ray.origin.xz += vec2(0, 0);
        //        ray.origin.xz += vec2(-x_off, -y_off);

        int lod = 0;
        float lodDistance = 5.;
        for (int i = 0; i < MAX_CLOUD_DEPTH; i++) {
            vec3 p = (ray.origin + ray.direction * depth);
            lod = int(floor((depth - 50.0) / lodDistance * 10.0 / lengthToCloud));
            int noiseIteration = 5 - lod;
            float noise = fbm(p.xzy * invCloudSize, noiseIteration).x;

            cloudness += noise;
            color += mix(vec3(0.1), vec3(1), float(i) / 30.) * noise * 0.45;
            depth += cloudStep;
        }

        cloudness *= smoothstep(3., 15., cloudness);
        color = mix(color, skyColor, clamp(1.0 - cloudness, 0.0, 1.0));
        color = mix(color, skyColor, clamp(lengthToCloud * .001 * 0.003, 0.0, 1.0));

        float a = sqrt(uv.y);
        fragColor = vec4(color, a);
        fragColor.x *= a;
        fragColor.y *= a;
        fragColor.z *= a;
    }
}
