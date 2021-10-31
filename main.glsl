#define PI 3.1415926535897932384626433832795

precision mediump float;

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

vec2 unit = vec2(1.0, 0.0);
vec2 i = vec2(0.0, 1.0);

vec4 color_light = vec4(0.9, 0.9, 0.9, 1.0);
vec4 color_dark = vec4(0.4, 0.4, 0.4, 1.0);

float time() {
    return 1.0 + u_time / 10.0;
}

vec2 conj(vec2 a) {
    return vec2(a.x, - a.y);
}

vec2 mul(vec2 a, vec2 b) {
    return vec2(a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x);
}

vec2 div(vec2 a, vec2 b) {
    return mul(a, conj(b)) / dot(b, b);
}

vec2 Exp(vec2 a) {
    return exp(a.x) * vec2(cos(a.y), sin(a.y));
}

vec2 Log(vec2 a) {
    return vec2(log(length(a)), atan(a.y, a.x));
}

vec2 elliptic(vec2 a) {
    return mul(a, Exp(time() * i));
}

vec2 parabolic(vec2 a) {
    return a + time() * unit;
}

vec2 hyperbolic(vec2 a) {
    return mul(a, Exp(time() * unit));
}

vec2 loxodromic(vec2 a) {
    return mul(a, Exp(time() * (unit + i)));
}

// Mobius transformation with fixed points q1 and q2
vec2 M2(vec2 a, vec2 q1, vec2 q2) {
    return div(a - q1, a - q2);
}

// M2 inverse
vec2 M2i(vec2 a, vec2 q1, vec2 q2) {
    return div(mul(-q2, a) + q1, - a + unit);
}

// Mobius transformation with a fixed point q
vec2 M1(vec2 a, vec2 q) {
    return div(unit, a - q);
}

// M1 inverse
vec2 M1i(vec2 a, vec2 q) {
    return div(unit, a) + q;
}

vec2 toComplex(vec2 a) {
    vec2 z = a.xy / u_resolution.xy;
    z += vec2(-0.5, - 0.5);
    z *= 5.0;
    z.x *= u_resolution.x / u_resolution.y;
    
    return z;
}

vec4 checkerboard(vec2 a) {
    if (mod(floor(a.x) + floor(a.y), 2.0) > 0.0)
        return color_light;
    else
        return color_dark;
}

vec4 dartboard(vec2 a) {
    float r = 2.0 * log(length(a));
    float t = 8.0 * atan(a.y, a.x) / PI;
    
    if (mod(floor(r) + floor(t), 2.0) > 0.0)
        return color_light;
    else
        return color_dark;
}

void main() {
    vec2 z = toComplex(gl_FragCoord.xy);
    vec2 m = toComplex(u_mouse);
    
    vec2 w = M2(z, unit, - unit);
    w = loxodromic(w);
    
    gl_FragColor = dartboard(w);
}