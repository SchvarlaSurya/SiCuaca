#version 460 core
#include <flutter/runtime_effect.glsl>

// Bulan sisi dekat disinari dari arah matahari.
//
// Warna dari foto bulan NASA LRO (cakram ortografik), relief dari peta
// ketinggian NASA LOLA. Pencahayaan memakai hukum Lommel-Seeliger, yang
// menggambarkan permukaan bulan lebih baik daripada Lambert: bulan purnama
// tampak rata tanpa pengelapan di tepi, dan batas terang-gelap (terminator)
// meredup lembut dengan kawah yang berbayang.

uniform vec2 uUkuran;     // lebar dan tinggi area gambar (piksel lokal)
uniform vec2 uArah;       // arah matahari di bidang x-z: (sin e, -cos e)
uniform float uRelief;    // kekuatan relief
uniform float uCahayaBumi; // kecerahan sisi gelap (earthshine)
uniform sampler2D uWarna; // foto cakram, alpha = bentuk cakram
uniform sampler2D uPeta;  // kemiringan permukaan (dx, dy), 0.5 = datar

out vec4 fragColor;

void main() {
  vec2 uv = FlutterFragCoord().xy / uUkuran;
  vec4 foto = texture(uWarna, uv);
  if (foto.a <= 0.0) {
    fragColor = vec4(0.0);
    return;
  }

  vec2 p = uv * 2.0 - 1.0;
  float z = sqrt(max(1.0 - dot(p, p), 0.0));
  // Normal bola: x ke kanan, y ke utara (atas), z ke arah pengamat.
  vec3 n = vec3(p.x, -p.y, z);
  vec2 lereng = texture(uPeta, uv).rg * 2.0 - 1.0;
  // Permukaan miring menjauhi arah tanjakan.
  n = normalize(n - vec3(lereng.x, lereng.y, 0.0) * uRelief);

  vec3 cahaya = normalize(vec3(uArah.x, 0.0, uArah.y));
  float mu0 = max(dot(n, cahaya), 0.0);
  float mu = max(n.z, 0.03);
  // Lommel-Seeliger, dinormalkan supaya purnama tepat 1.0.
  float terang = clamp(2.0 * mu0 / (mu0 + mu), 0.0, 1.0);

  vec3 siang = foto.rgb * terang * 1.12;
  vec3 malam = foto.rgb * vec3(0.55, 0.66, 0.92) * uCahayaBumi;
  vec3 warna = siang + malam * (1.0 - terang);
  fragColor = vec4(min(warna, vec3(1.0)) * foto.a, foto.a);
}
