local sofa = require("modules.couch_state")

-- Desk monitor: always on, also in sofa mode. LG UltraGear Nano IPS, about DCI-P3:
-- cm "edid" maps sRGB onto its real primaries (with "srgb" every colour is stretched
-- over the wide gamut and comes out oversaturated). 10-bit so the mapping doesn't band;
-- DP 1.4 carries 10-bit at 160 Hz on this panel (tested 2026-10-26).
hl.monitor({
    output   = "DP-1",
    mode     = "3440x1440@160",
    position = "0x0",
    scale    = 1,
    cm       = "edid",
    bitdepth = 10,
})

-- LG TV: only on in sofa mode (see sofa.lua). Right of the desk monitor so the two
-- never overlap. Scale 1: it only shows Steam Big Picture (which scales its own UI)
-- and games, which would otherwise render at 1080p under XWayland.
if sofa then
    hl.monitor({
        output   = "HDMI-A-1",
        mode     = "3840x2160@119.88",
        position = "3440x0",
        scale    = 1,
        -- HDR (experimental on NVIDIA): 10-bit + HDR colour management. 4K120 10-bit
        -- only gets a signal with nvidia_modeset hdmi_deepcolor=0
        -- (/etc/modprobe.d/nvidia-hdmi.conf); without it this falls back to 4K60.
        -- 119.88 is the TV's only 4K high-refresh mode (no 120.00 in its EDID).
        bitdepth = 10,
        cm       = "hdr",
    })
else
    hl.monitor({
        output   = "HDMI-A-1",
        disabled = true,
    })
end
