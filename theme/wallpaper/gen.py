#!/usr/bin/env python3
# ember wallpaper generator, stdlib only, emits svg per resolution.
# Every colour comes from theme/palette.toml ([colors] tokens + [wallpaper] shades).
#   gen.py W H out.svg
import math, sys, tomllib
from pathlib import Path

PALETTE = tomllib.loads((Path(__file__).resolve().parent.parent / "palette.toml").read_text())
C, WP = PALETTE["colors"], PALETTE["wallpaper"]

def rgb(hex_):
    h = hex_.lstrip("#")
    return ",".join(str(int(h[i:i + 2], 16)) for i in (0, 2, 4))

STAR = C["fg_dim"]
SUN = C["orange"]
SUN_HI = WP["sun_hi"]
GLOW = rgb(C["orange"])
MAGENTA = rgb(C["magenta"])
SKY_TOP = WP["sky_top"]

def ridge_path(W, H, base_y, amp, freq, phase, seed):
    # top profile via summed sines, then close around the bottom
    pts = []
    n = 240
    for i in range(n + 1):
        t = i / n
        x = W * t
        y = base_y
        y += amp * math.sin(2 * math.pi * freq * t + phase)
        y += amp * 0.45 * math.sin(2 * math.pi * (freq * 2.3) * t + phase * 1.7 + seed)
        y += amp * 0.22 * math.sin(2 * math.pi * (freq * 4.7) * t + seed * 2.0)
        pts.append((x, y))
    d = "M {:.1f} {:.1f} ".format(pts[0][0], pts[0][1])
    for x, y in pts[1:]:
        d += "L {:.1f} {:.1f} ".format(x, y)
    d += "L {:.1f} {:.1f} L 0 {:.1f} Z".format(W, H, H)
    return d

def stars(W, H):
    # deterministic sparse field, upper area only
    out = []
    s = 1234567
    for _ in range(90):
        s = (1103515245 * s + 12345) & 0x7fffffff
        x = (s % 10000) / 10000 * W
        s = (1103515245 * s + 12345) & 0x7fffffff
        y = (s % 10000) / 10000 * (H * 0.46)
        s = (1103515245 * s + 12345) & 0x7fffffff
        r = 0.6 + (s % 100) / 100 * 1.1
        s = (1103515245 * s + 12345) & 0x7fffffff
        op = 0.12 + (s % 100) / 100 * 0.33
        out.append('<circle cx="{:.1f}" cy="{:.1f}" r="{:.2f}" fill="{}" opacity="{:.2f}"/>'.format(x, y, r, STAR, op))
    return "\n".join(out)

def svg(W, H):
    sun_x = W * 0.62
    sun_y = H * 0.50
    sun_r = H * 0.115
    horizon = H * 0.56
    # far to near, lighter and warmer in the distance
    ridges = [
        (horizon + H*0.00, H*0.045, 1.3, 0.4, 0.2, WP["ridges"][0]),
        (horizon + H*0.09, H*0.055, 1.7, 2.1, 1.1, WP["ridges"][1]),
        (horizon + H*0.20, H*0.065, 1.1, 4.0, 2.3, WP["ridges"][2]),
        (horizon + H*0.33, H*0.080, 0.9, 5.6, 3.7, WP["ridges"][3]),
    ]
    parts = []
    parts.append('<svg xmlns="http://www.w3.org/2000/svg" width="{}" height="{}" viewBox="0 0 {} {}">'.format(W, H, W, H))
    parts.append('''<defs>
  <linearGradient id="sky" x1="0" y1="0" x2="0" y2="1">
    <stop offset="0%" stop-color="{top}"/>
    <stop offset="38%" stop-color="{sky1}"/>
    <stop offset="62%" stop-color="{sky2}"/>
    <stop offset="82%" stop-color="{sky3}"/>
    <stop offset="100%" stop-color="{sky4}"/>
  </linearGradient>
  <radialGradient id="mag" cx="35%" cy="18%" r="60%">
    <stop offset="0%" stop-color="rgb({mag})" stop-opacity="0.07"/>
    <stop offset="100%" stop-color="rgb({mag})" stop-opacity="0"/>
  </radialGradient>
  <radialGradient id="glow" cx="50%" cy="50%" r="50%">
    <stop offset="0%" stop-color="rgb({glow})" stop-opacity="0.55"/>
    <stop offset="35%" stop-color="rgb({glow})" stop-opacity="0.22"/>
    <stop offset="100%" stop-color="rgb({glow})" stop-opacity="0"/>
  </radialGradient>
  <radialGradient id="disc" cx="50%" cy="42%" r="60%">
    <stop offset="0%" stop-color="{hi}"/>
    <stop offset="100%" stop-color="{sun}"/>
  </radialGradient>
  <linearGradient id="haze" x1="0" y1="0" x2="0" y2="1">
    <stop offset="0%" stop-color="rgb({glow})" stop-opacity="0.18"/>
    <stop offset="100%" stop-color="rgb({glow})" stop-opacity="0"/>
  </linearGradient>
</defs>'''.format(top=SKY_TOP, sky1=WP["sky"][0], sky2=WP["sky"][1], sky3=WP["sky"][2], sky4=WP["sky"][3], mag=MAGENTA, glow=GLOW, hi=SUN_HI, sun=SUN))
    parts.append('<rect width="{}" height="{}" fill="url(#sky)"/>'.format(W, H))
    parts.append('<rect width="{}" height="{}" fill="url(#mag)"/>'.format(W, H))
    parts.append(stars(W, H))
    gr = sun_r * 3.2
    parts.append('<circle cx="{:.1f}" cy="{:.1f}" r="{:.1f}" fill="url(#glow)"/>'.format(sun_x, sun_y, gr))
    parts.append('<circle cx="{:.1f}" cy="{:.1f}" r="{:.1f}" fill="url(#disc)"/>'.format(sun_x, sun_y, sun_r))
    # all ridges after the sun so the disc sits in sky and the nearest ridge occludes its base
    for by, amp, freq, phase, seed, col in ridges:
        parts.append('<path d="{}" fill="{}"/>'.format(ridge_path(W, H, by, amp, freq, phase, seed), col))
    parts.append('</svg>')
    return "\n".join(parts)

if __name__ == "__main__":
    W, H, out = int(sys.argv[1]), int(sys.argv[2]), sys.argv[3]
    open(out, "w").write(svg(W, H))
    print("wrote", out)
