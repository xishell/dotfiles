#!/usr/bin/env python3
"""
couch.py - one tool for "sofa mode" on Windows and Hyprland (Linux).

  python couch.py setup    interactive setup: pairs the TV, finds inputs, displays
                           and audio devices, writes config.json next to this file
  python couch.py sofa     TV on -> PC input -> displays -> audio -> Steam Big Picture
  python couch.py desk     reverse it
  python couch.py toggle   sofa or desk depending on current mode
  python couch.py sofa soundbar|controller
                           sofa mode with that audio output (Linux + OpenXLR)
  python couch.py audio [soundbar|controller|toggle]
                           switch sofa audio now (or show it); in desk mode it
                           just picks the output for next time
  python couch.py trim [name [percent|+N|-N]]
                           fixed level per output (wave/controller/soundbar), so a
                           channel dial position sounds the same on each
  python couch.py tvvolume [N|+N|-N]
                           volume-up key presses for sofa mode (desk mode presses
                           down as many); in sofa mode applies the change at once
  python couch.py listen   background listener for the controller:
                             hold the listen_button combo -> toggle sofa / desk
  python couch.py buttons  show which controller buttons the PC sees (to pick listen_button)
  python couch.py status   show current mode and TV state

Needs Python 3.9+ and:  pip install bscpylgtv      (TV control)
                        pip install pygame         (only for `listen`)
"""
import argparse
import json
import os
import platform
import re
import shutil
import socket
import subprocess
import sys
import threading
import time
from pathlib import Path

# Data dir: config, state, log, prefs, TV pairing key and venv. Not __file__.resolve():
# this script is a stow symlink into ~/dotfiles, and runtime files must stay out of git.
HERE = Path(os.environ.get("COUCH_HOME", Path.home() / ".local" / "share" / "couch"))
CONFIG_FILE = HERE / "config.json"
STATE_FILE = HERE / "state.json"
LOCK_FILE = HERE / ".couch.lock"
LOG_FILE = HERE / "couch.log"
PREFS_FILE = HERE / "prefs.json"   # remembered choices (sofa audio output), survives mode changes
IS_WIN = platform.system() == "Windows"
NO_WINDOW = subprocess.CREATE_NO_WINDOW if IS_WIN else 0

DEFAULTS = {
    # --- TV (LG webOS) ---
    "tv_ip": "",
    "tv_mac": "",
    "tv_pc_input": "HDMI_2",
    "tv_on_desk": "off",          # "off", "nothing", or an input such as "HDMI_1"
    "tv_extra_args": [],          # extra bscpylgtv flags, e.g. ["-w"] to connect without SSL
    "tv_wake_timeout": 30,
    "tv_volume_steps_sofa": 0,    # volume-up key presses on entering sofa mode (desk mode presses
                                  # down the same number). Key presses reach a soundbar over
                                  # HDMI-CEC where setting an absolute TV volume doesn't, and
                                  # stay in step when another remote changes the volume.
                                  # Calibrate with `couch.py tvvolume +1` / `-1` in sofa mode.
    # --- displays ---
    "display_settle_seconds": 3,
    "win_tv": "",                 # TV's monitor id (e.g. GSM8394) - set by setup
    "win_desk": "",               # desk monitor's id
    "win_keep_desk_on": True,     # sofa mode: desk monitor stays on, TV becomes primary
    "hypr_tv": "",
    "hypr_tv_mode": "preferred,auto,1",
    "hypr_desk": "",
    "hypr_desk_mode": "preferred,auto,1",
    "hypr_disable_desk": False,     # classic config only; Lua configs use monitors.lua/sofa.lua
    "hypr_tv_workspace": "name:tv", # workspace pinned to the TV in sofa.lua
    # --- audio ---
    "audio_sofa": "",             # Linux: pactl sink name / Windows: device name
    "audio_desk": "",
    "soundvolumeview": "",        # Windows: path to NirSoft SoundVolumeView.exe
    # Linux with OpenXLR: switch the Monitor mix's outputs instead of the default sink.
    # Used when the OpenXLR daemon is running; audio_sofa/audio_desk are ignored then.
    "openxlr_sofa_outputs": {     # choice -> sinks; pick with `sofa soundbar` / `audio controller`
        "soundbar": [],
        "controller": [],
    },
    "openxlr_sofa_default": "soundbar",
    "openxlr_desk_outputs": [],
    # The TV's HDMI audio only exists while its port's card profile is active
    "hdmi_card": "",              # e.g. alsa_card.pci-0000_01_00.1
    "hdmi_profile_sofa": "",      # e.g. output:hdmi-stereo-extra1 (the TV's port)
    "hdmi_profile_desk": "",      # e.g. output:hdmi-stereo (back to the desk monitor's port)
    # Fixed per-output level (% on the sink) so the same channel dial position sounds
    # about as loud on every output; set with `couch.py trim <name> <percent|+N|-N>`
    "output_trims": {},           # name -> {"sink": "...", "percent": 100}
    # --- steam ---
    "steam": True,
    # --- controller listener ---
    "listen_controller_match": "",   # lowercase part of the controller name; "" = any
    "listen_button": "back+start",   # button(s) to hold: e.g. back+start (View+Menu), guide - see `couch.py buttons`
    "listen_hold_seconds": 1.5,
    "listen_auto_desk_minutes": 0,   # controller off this long -> desk mode (0 = off)
}


# ------------------------------------------------------------------ helpers
def log(msg):
    line = time.strftime("%Y-%m-%d %H:%M:%S ") + msg
    print(line, flush=True)          # no-op under pythonw
    try:
        with open(LOG_FILE, "a", encoding="utf-8") as f:
            f.write(line + "\n")
    except OSError:
        pass


def run(cmd, timeout=20):
    """Run a command quietly. Returns CompletedProcess, or None if it couldn't start."""
    try:
        return subprocess.run(cmd, capture_output=True, text=True, timeout=timeout,
                              cwd=HERE, creationflags=NO_WINDOW)
    except (OSError, subprocess.TimeoutExpired) as exc:
        log(f"  ! {cmd[0]}: {exc}")
        return None


def wait_for(predicate, timeout, interval=0.5):
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        if predicate():
            return True
        time.sleep(interval)
    return False


def load_config():
    if not CONFIG_FILE.exists():
        sys.exit(f"No config found. Run:  python {Path(__file__).name} setup")
    cfg = dict(DEFAULTS)
    cfg.update(json.loads(CONFIG_FILE.read_text(encoding="utf-8")))
    return cfg


def read_mode():
    try:
        return json.loads(STATE_FILE.read_text(encoding="utf-8")).get("mode", "desk")
    except (OSError, ValueError):
        return "desk"


def read_state():
    try:
        return json.loads(STATE_FILE.read_text(encoding="utf-8"))
    except (OSError, ValueError):
        return {}


def write_mode(mode, **extra):
    data = {"mode": mode, "since": time.time(), **extra}
    STATE_FILE.write_text(json.dumps(data), encoding="utf-8")
    bar_sync(mode)
    notify_mode(mode)
    night_light(mode)


def tv_mode():
    """The TV output as Hyprland runs it now, e.g. ("4K120 hdr", "HDMI-A-1 · 3840x2160@120 · hdr")."""
    tv = next((m for m in hypr_monitors() if m.get("name") == load_config().get("hypr_tv")), None)
    if not tv:
        return None
    hz = round(tv.get("refreshRate", 0))
    hdr = " hdr" if tv.get("colorManagementPreset") == "hdr" else ""
    res = "4K" if tv.get("width", 0) >= 3840 else f"{tv.get('height')}p"
    return f"{res}{hz}{hdr}", f"{tv['name']} · {tv.get('width')}x{tv.get('height')}@{hz}{' · hdr' if hdr else ''}"


def bar_sync(mode=None):
    """Ember rice: Ironbar's couch chip shows the mode through ironvars (desk chip vs the
    orange `couch · 4K120 hdr` chip). Linux only, and a no-op when Ironbar isn't running."""
    if IS_WIN or not shutil.which("ironbar"):
        return
    sofa = (mode or read_mode()) == "sofa"
    tv = tv_mode() if sofa else None
    label = f"couch · {tv[0]}" if tv else "couch"
    for key, value in (("couch_desk", "" if sofa else "true"),
                       ("couch_on", "true" if sofa else ""),
                       ("couch_label", label)):
        run(["ironbar", "var", "set", key, value], timeout=3)


def night_light(mode):
    """Ember rice: hyprsunset off in sofa mode (its gamma ramp would skew the TV's HDR),
    back on in desk mode, where hyprsunset.conf picks the profile for the time of day."""
    if IS_WIN or not shutil.which("hyprsunset"):
        return
    running = run(["pgrep", "-x", "hyprsunset"], timeout=3)
    if mode == "sofa":
        run(["pkill", "-x", "hyprsunset"], timeout=3)
    elif running is not None and running.returncode != 0:
        subprocess.Popen(["hyprsunset"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
                         start_new_session=True)


def notify_mode(mode):
    """Ember rice: a mako card (app "couch", orange border) when the mode switches."""
    if IS_WIN or not shutil.which("notify-send"):
        return
    if mode == "sofa":
        tv = tv_mode()
        audio = read_prefs().get("sofa_audio", "soundbar")
        body = f"{tv[1] if tv else 'TV'}\naudio → {audio} · desk stays live"
        run(["notify-send", "-a", "couch", "-i", "video-display", "Couch mode on", body], timeout=3)
    else:
        run(["notify-send", "-a", "couch", "-i", "video-display", "Desk mode", "TV back to its own input"], timeout=3)


def read_prefs():
    try:
        return json.loads(PREFS_FILE.read_text(encoding="utf-8"))
    except (OSError, ValueError):
        return {}


def write_prefs(**changes):
    PREFS_FILE.write_text(json.dumps({**read_prefs(), **changes}), encoding="utf-8")


class Lock:
    """Stops the Stream Deck and the controller listener running at the same time."""
    def __enter__(self):
        if LOCK_FILE.exists() and time.time() - LOCK_FILE.stat().st_mtime < 120:
            raise RuntimeError("another switch is already running")
        LOCK_FILE.write_text(str(os.getpid()))
        return self

    def __exit__(self, *exc):
        try:
            LOCK_FILE.unlink()
        except OSError:
            pass


# ------------------------------------------------------------------ TV
KEY_FILE = HERE / ".lgtv-keys.sqlite"   # TV pairing key, stored next to this script


def python_exe():
    """python.exe rather than pythonw.exe, so output can be captured."""
    exe = Path(sys.executable)
    if exe.name.lower() == "pythonw.exe" and (exe.parent / "python.exe").exists():
        return str(exe.parent / "python.exe")
    return str(exe)


def have_bscpylgtv():
    import importlib.util
    return importlib.util.find_spec("bscpylgtv") is not None


def tv_cmd(cfg, *args, timeout=10, quiet=False, fast=False):
    """Run a bscpylgtv command. Returns its output, or None on failure."""
    if not have_bscpylgtv():
        log("  ! bscpylgtv isn't installed - run: pip install bscpylgtv")
        return None
    # Call the library's CLI through this Python, so PATH and the command's name don't matter
    cli = [python_exe(), "-c", "from bscpylgtv.utils import bscpylgtvcommand as m; m()",
           "--log", "ERROR", "-p", str(KEY_FILE)]
    if fast:   # one quick attempt - for "is the TV even on?" checks
        cli += ["--timeout_connect", "1", "--connect_retry_attempts", "1"]
    p = run([*cli, *cfg["tv_extra_args"], cfg["tv_ip"], *args], timeout=timeout)
    if p is None:
        return None
    out = (p.stdout + p.stderr).strip()
    if p.returncode != 0 or re.search(r"traceback|exception|refused|timed out", out, re.I):
        if not quiet:
            last = out.splitlines()[-1] if out else f"exit code {p.returncode}"
            log(f"  ! TV {args[0] if args else ''}: {last[:200]}")
        return None
    return p.stdout.strip()


def wake_on_lan(mac, ip=""):
    raw = bytes.fromhex(re.sub(r"[^0-9a-fA-F]", "", mac))
    if len(raw) != 6:
        log(f"  ! invalid MAC address: {mac}")
        return
    packet = b"\xff" * 6 + raw * 16
    targets = {"255.255.255.255"}
    if ip.count(".") == 3:
        targets.add(ip.rsplit(".", 1)[0] + ".255")
    with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as s:
        s.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
        for addr in targets:
            try:
                s.sendto(packet, (addr, 9))
            except OSError:
                pass


def input_app_id(name):
    """'HDMI_2' -> 'hdmi2' (webOS reports the current input as com.webos.app.hdmi2)."""
    return name.lower().replace("_", "")


def tv_current_input(cfg):
    return tv_cmd(cfg, "get_input", timeout=6)


def tv_on_pc_input(cfg):
    current = tv_cmd(cfg, "get_input", timeout=6, quiet=True)
    return bool(current) and input_app_id(cfg["tv_pc_input"]) in current.lower()


TV_OFF_STATES = {"Power Off", "Suspend", "Active Standby"}


def tv_power_state(cfg):
    """'Active', 'Screen Off', 'Active Standby', ... or None if the TV doesn't answer (off)."""
    out = tv_cmd(cfg, "get_power_state", timeout=6, quiet=True, fast=True)
    m = re.search(r"['\"]state['\"]\s*:\s*['\"]([^'\"]+)", out or "")
    return m.group(1) if m else None


def tv_snapshot(cfg):
    """Before sofa mode: was the TV already on, and what was it showing?"""
    if not cfg["tv_ip"]:
        return {}
    # A few seconds of retries: a TV that just changed input (remote, an earlier switch)
    # can miss one quick check - and then desk mode would switch it off instead of back
    state = tv_power_state_patient(cfg, timeout=4)
    if state is None or state in TV_OFF_STATES:
        log(f"TV: off before sofa mode ({state or 'no answer'})")
        return {"tv_was_on": False}
    app = tv_cmd(cfg, "get_input", timeout=6, quiet=True, fast=True) or ""
    app = app.strip().strip("'\"")
    log(f"TV: already on ({app or 'unknown input'}) - will leave it on in desk mode")
    return {"tv_was_on": True, "tv_prev_app": app}


def tv_sofa(cfg):
    """Wake the TV and wait until it accepts commands."""
    if not cfg["tv_ip"]:
        return True
    log("TV: waking")
    deadline = time.monotonic() + cfg["tv_wake_timeout"]
    while time.monotonic() < deadline:
        if cfg["tv_mac"]:
            wake_on_lan(cfg["tv_mac"], cfg["tv_ip"])
        # While booting, webOS answers "Try Again Later" - keep quiet and retry
        state = tv_power_state(cfg)
        if state in ("Active Standby", "Suspend"):
            # standby with Quick Start+: it answers the network but needs a power-on
            tv_cmd(cfg, "power_on", timeout=6, quiet=True)
        elif state is not None and state not in TV_OFF_STATES:
            log("TV: awake")
            tv_cmd(cfg, "set_input", cfg["tv_pc_input"], timeout=8, quiet=True)
            return True
        time.sleep(1)
    log("TV: no response - check 'Wake on LAN' (and maybe 'Network IP Control') on the TV")
    return False


def tv_ensure_pc_input(cfg, timeout=20):
    """Switch to the PC input and check it stuck. Run once the PC is sending a picture:
    webOS may ignore an input with no signal, and the Apple TV can grab it over HDMI-CEC."""
    if not cfg["tv_ip"]:
        return
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        if not tv_on_pc_input(cfg):           # only switch if it isn't there already
            tv_cmd(cfg, "set_input", cfg["tv_pc_input"], timeout=8, quiet=True)
            time.sleep(0.75)
            if not tv_on_pc_input(cfg):
                continue
        # on the right input - check once more in case the Apple TV grabs it over CEC
        time.sleep(1.5)
        if tv_on_pc_input(cfg):
            log("TV: on " + cfg["tv_pc_input"])
            return
    log(f"TV: couldn't keep it on {cfg['tv_pc_input']} - see README (Apple TV / SIMPLINK)")


def tv_restore(cfg, app):
    """Put the TV back on what it showed before sofa mode (an HDMI input or an app)."""
    m = re.search(r"hdmi(\d)", app or "", re.I)
    if m:
        tv_cmd(cfg, "set_input", f"HDMI_{m.group(1)}")
    elif app:
        tv_cmd(cfg, "launch_app", app)


def tv_volume_keys(cfg, steps):
    """Press the TV's volume key `steps` times (negative = down)."""
    key = "volume_up" if steps > 0 else "volume_down"
    for _ in range(abs(steps)):
        tv_cmd(cfg, key, timeout=8, quiet=True)
        time.sleep(0.25)


def tv_volume_sofa(cfg, before):
    """Turn the soundbar up for the PC (its signal is quieter than e.g. the Apple TV's)."""
    steps = int(cfg["tv_volume_steps_sofa"] or 0)
    if not cfg["tv_ip"] or not steps or before.get("tv_volume_steps", 0):
        return                       # off, or already applied by an earlier sofa run
    log(f"TV: volume {'+' if steps > 0 else ''}{steps}")
    tv_volume_keys(cfg, steps)
    before["tv_volume_steps"] = steps


def tv_volume_restore(cfg, before):
    steps = (before or {}).get("tv_volume_steps", 0)
    if cfg["tv_ip"] and steps and tv_power_state_patient(cfg) not in (None, *TV_OFF_STATES):
        log(f"TV: volume {-steps:+d} (back to before sofa mode)")
        tv_volume_keys(cfg, -steps)


def tvvolume(cfg, value=None):
    """`couch.py tvvolume [N|+N|-N]` - show / set the sofa volume-up steps. In sofa mode
    the change is applied straight away, so you can calibrate by ear."""
    steps = int(cfg["tv_volume_steps_sofa"] or 0)
    if not value:
        print(f"Sofa volume steps: {steps:+d}")
        return
    try:
        new = steps + int(value) if value[0] in "+-" else int(value)
    except ValueError:
        sys.exit("Use a number of steps, e.g. 6, +1 or -1")
    raw = json.loads(CONFIG_FILE.read_text(encoding="utf-8"))
    raw["tv_volume_steps_sofa"] = new
    raw.pop("tv_volume_sofa", None)
    CONFIG_FILE.write_text(json.dumps(raw, indent=2), encoding="utf-8")
    if read_mode() == "sofa":
        state = read_state()
        applied = state.get("tv_volume_steps", 0)
        tv_volume_keys(cfg, new - applied)
        state["tv_volume_steps"] = new
        STATE_FILE.write_text(json.dumps(state), encoding="utf-8")
    print(f"Sofa volume steps: {new:+d}")


def tv_power_state_patient(cfg, timeout=6):
    """Like tv_power_state, but keeps asking for a few seconds - a TV that just lost or
    changed its input can miss one quick check."""
    found = []
    wait_for(lambda: found.append(tv_power_state(cfg)) or found[-1] is not None, timeout, 1)
    return found[-1] if found else None


def tv_desk(cfg, before=None):
    action = cfg["tv_on_desk"]
    if not cfg["tv_ip"] or action == "nothing":
        return
    state = tv_power_state_patient(cfg)
    if state is None or state in TV_OFF_STATES:
        log("TV: already off")
        return
    before = before or {}
    if before.get("tv_was_on"):
        prev = before.get("tv_prev_app", "")
        if prev and input_app_id(cfg["tv_pc_input"]) not in prev.lower():
            log(f"TV: was on before sofa mode - back to {prev}")
            tv_restore(cfg, prev)
        else:
            log("TV: was on before sofa mode - leaving it on")
        return
    if action == "off":
        log("TV: power off")
        tv_cmd(cfg, "power_off")
    else:
        log("TV: switching to " + action)
        tv_cmd(cfg, "set_input", action)


# ------------------------------------------------------------------ displays
def hyprctl(*args):
    """hyprctl, finding the running Hyprland when started outside its session (systemd)."""
    if not os.environ.get("HYPRLAND_INSTANCE_SIGNATURE"):
        base = Path(os.environ.get("XDG_RUNTIME_DIR", f"/run/user/{os.getuid()}")) / "hypr"
        socks = sorted(base.glob("*/.socket.sock"), key=lambda s: s.stat().st_mtime)
        if socks:
            os.environ["HYPRLAND_INSTANCE_SIGNATURE"] = socks[-1].parent.name
    return run(["hyprctl", *args])


def hypr_lua():
    """A Lua config (hyprland.lua) rejects `hyprctl keyword`; it needs `hyprctl eval`."""
    cfg_home = Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config"))
    return (cfg_home / "hypr" / "hyprland.lua").exists()


def _lua_str(s):
    return '"' + str(s).replace("\\", "\\\\").replace('"', '\\"') + '"'


def hypr_monitor_on(name, mode):
    """mode is the classic 'resolution@hz,position,scale' string, e.g. 'preferred,auto,1'."""
    if not hypr_lua():
        return hyprctl("keyword", "monitor", f"{name},{mode}")
    res, pos, scale = (mode.split(",") + ["auto", "1"])[:3]
    try:
        scale_lua = str(float(scale)).rstrip("0").rstrip(".")
    except ValueError:
        scale_lua = _lua_str(scale)    # "auto"
    return hyprctl("eval", f"hl.monitor({{ output = {_lua_str(name)}, mode = {_lua_str(res)}, "
                           f"position = {_lua_str(pos)}, scale = {scale_lua}, disabled = false }})")


def hypr_monitor_off(name):
    if not hypr_lua():
        return hyprctl("keyword", "monitor", f"{name},disable")
    return hyprctl("eval", f"hl.monitor({{ output = {_lua_str(name)}, disabled = true }})")


def hypr_focus_monitor(name):
    if not hypr_lua():
        return hyprctl("dispatch", "focusmonitor", name)
    return hyprctl("dispatch", f"hl.dsp.focus({{ monitor = {_lua_str(name)} }})")


def hypr_monitors(all_=False):
    p = hyprctl("monitors", "all", "-j") if all_ else hyprctl("monitors", "-j")
    try:
        return json.loads(p.stdout) if p else []
    except ValueError:
        return []


def hypr_active(name):
    return any(m.get("name") == name and not m.get("disabled") for m in hypr_monitors())


# --- Windows: native display API (same calls BarRaider's Win Tools uses) ---
def _win_api():
    import ctypes
    from ctypes import wintypes as w

    class POINTL(ctypes.Structure):
        _fields_ = [("x", w.LONG), ("y", w.LONG)]

    class DEVMODEW(ctypes.Structure):          # display variant of the union, 220 bytes
        _fields_ = [
            ("dmDeviceName", w.WCHAR * 32), ("dmSpecVersion", w.WORD), ("dmDriverVersion", w.WORD),
            ("dmSize", w.WORD), ("dmDriverExtra", w.WORD), ("dmFields", w.DWORD),
            ("dmPosition", POINTL), ("dmDisplayOrientation", w.DWORD), ("dmDisplayFixedOutput", w.DWORD),
            ("dmColor", ctypes.c_short), ("dmDuplex", ctypes.c_short), ("dmYResolution", ctypes.c_short),
            ("dmTTOption", ctypes.c_short), ("dmCollate", ctypes.c_short), ("dmFormName", w.WCHAR * 32),
            ("dmLogPixels", w.WORD), ("dmBitsPerPel", w.DWORD), ("dmPelsWidth", w.DWORD),
            ("dmPelsHeight", w.DWORD), ("dmDisplayFlags", w.DWORD), ("dmDisplayFrequency", w.DWORD),
            ("dmICMMethod", w.DWORD), ("dmICMIntent", w.DWORD), ("dmMediaType", w.DWORD),
            ("dmDitherType", w.DWORD), ("dmReserved1", w.DWORD), ("dmReserved2", w.DWORD),
            ("dmPanningWidth", w.DWORD), ("dmPanningHeight", w.DWORD)]

    class DISPLAY_DEVICEW(ctypes.Structure):
        _fields_ = [("cb", w.DWORD), ("DeviceName", w.WCHAR * 32), ("DeviceString", w.WCHAR * 128),
                    ("StateFlags", w.DWORD), ("DeviceID", w.WCHAR * 128), ("DeviceKey", w.WCHAR * 128)]

    return ctypes, ctypes.WinDLL("user32"), DEVMODEW, DISPLAY_DEVICEW


ATTACHED, PRIMARY = 0x1, 0x4
ENUM_CURRENT_SETTINGS = -1
DM_POSITION = 0x20
CDS_UPDATEREGISTRY, CDS_SET_PRIMARY, CDS_NORESET = 0x1, 0x10, 0x10000000


def win_displays():
    """Displays attached to the desktop: name, monitor id/name, position, size, primary."""
    ctypes, user32, DEVMODEW, DISPLAY_DEVICEW = _win_api()
    out, i = [], 0
    while True:
        dd = DISPLAY_DEVICEW()
        dd.cb = ctypes.sizeof(dd)
        if not user32.EnumDisplayDevicesW(None, i, ctypes.byref(dd), 0):
            break
        i += 1
        if not dd.StateFlags & ATTACHED:
            continue
        mon = DISPLAY_DEVICEW()
        mon.cb = ctypes.sizeof(mon)
        user32.EnumDisplayDevicesW(dd.DeviceName, 0, ctypes.byref(mon), 0)
        dm = DEVMODEW()
        dm.dmSize = ctypes.sizeof(dm)
        user32.EnumDisplaySettingsW(dd.DeviceName, ENUM_CURRENT_SETTINGS, ctypes.byref(dm))
        parts = mon.DeviceID.split("\\")       # MONITOR\GSM8394\{guid}\0004
        out.append({
            "device": dd.DeviceName,                       # \\.\DISPLAY2
            "hwid": parts[1] if len(parts) > 1 else "",    # GSM8394 (GSM = LG)
            "monitor": mon.DeviceString,
            "x": dm.dmPosition.x, "y": dm.dmPosition.y,
            "w": dm.dmPelsWidth, "h": dm.dmPelsHeight, "hz": dm.dmDisplayFrequency,
            "primary": bool(dd.StateFlags & PRIMARY),
        })
    return out


def win_find(match):
    for d in win_displays():
        if match and match.lower() in (d["hwid"].lower(), d["device"].lower()):
            return d
    return None


def _ccd_api():
    """Structures for the CCD display API (QueryDisplayConfig / SetDisplayConfig)."""
    import ctypes
    U32, I32, U16 = ctypes.c_uint32, ctypes.c_int32, ctypes.c_uint16

    class LUID(ctypes.Structure):
        _fields_ = [("LowPart", U32), ("HighPart", I32)]

    class RATIONAL(ctypes.Structure):
        _fields_ = [("Numerator", U32), ("Denominator", U32)]

    class PATH_SOURCE(ctypes.Structure):
        _fields_ = [("adapterId", LUID), ("id", U32), ("modeInfoIdx", U32), ("statusFlags", U32)]

    class PATH_TARGET(ctypes.Structure):
        _fields_ = [("adapterId", LUID), ("id", U32), ("modeInfoIdx", U32), ("outputTechnology", U32),
                    ("rotation", U32), ("scaling", U32), ("refreshRate", RATIONAL),
                    ("scanLineOrdering", U32), ("targetAvailable", I32), ("statusFlags", U32)]

    class PATH(ctypes.Structure):                      # DISPLAYCONFIG_PATH_INFO, 72 bytes
        _fields_ = [("sourceInfo", PATH_SOURCE), ("targetInfo", PATH_TARGET), ("flags", U32)]

    class POINTL(ctypes.Structure):
        _fields_ = [("x", I32), ("y", I32)]

    class SOURCE_MODE(ctypes.Structure):
        _fields_ = [("width", U32), ("height", U32), ("pixelFormat", U32), ("position", POINTL)]

    class MODE_UNION(ctypes.Union):
        _fields_ = [("sourceMode", SOURCE_MODE), ("raw", ctypes.c_ubyte * 48)]

    class MODE(ctypes.Structure):                      # DISPLAYCONFIG_MODE_INFO, 64 bytes
        _fields_ = [("infoType", U32), ("id", U32), ("adapterId", LUID), ("u", MODE_UNION)]

    class HEADER(ctypes.Structure):
        _fields_ = [("type", U32), ("size", U32), ("adapterId", LUID), ("id", U32)]

    class SOURCE_NAME(ctypes.Structure):               # DISPLAYCONFIG_SOURCE_DEVICE_NAME
        _fields_ = [("header", HEADER), ("viewGdiDeviceName", ctypes.c_wchar * 32)]

    return ctypes, ctypes.WinDLL("user32"), PATH, MODE, SOURCE_NAME


QDC_ONLY_ACTIVE_PATHS = 0x2
MODE_SOURCE = 1
GET_SOURCE_NAME = 1
SDC_APPLY, SDC_USE_SUPPLIED, SDC_SAVE, SDC_ALLOW_CHANGES = 0x80, 0x20, 0x200, 0x400


def _set_primary_ccd(gdi_name):
    """Move every source so `gdi_name` (e.g. \\\\.\\DISPLAY2) is at (0,0) - that is what makes
    it primary - and apply it the way the Settings app does. Returns the Windows result code."""
    ctypes, user32, PATH, MODE, SOURCE_NAME = _ccd_api()
    n_paths, n_modes = ctypes.c_uint32(), ctypes.c_uint32()
    rc = user32.GetDisplayConfigBufferSizes(QDC_ONLY_ACTIVE_PATHS, ctypes.byref(n_paths), ctypes.byref(n_modes))
    if rc:
        return rc
    paths, modes = (PATH * n_paths.value)(), (MODE * n_modes.value)()
    rc = user32.QueryDisplayConfig(QDC_ONLY_ACTIVE_PATHS, ctypes.byref(n_paths), paths,
                                   ctypes.byref(n_modes), modes, None)
    if rc:
        return rc
    origin = None
    for p in paths[:n_paths.value]:
        name = SOURCE_NAME()
        name.header.type, name.header.size = GET_SOURCE_NAME, ctypes.sizeof(name)
        name.header.adapterId, name.header.id = p.sourceInfo.adapterId, p.sourceInfo.id
        if user32.DisplayConfigGetDeviceInfo(ctypes.byref(name)) == 0 \
                and name.viewGdiDeviceName.lower() == gdi_name.lower():
            idx = p.sourceInfo.modeInfoIdx
            if idx < n_modes.value:
                pos = modes[idx].u.sourceMode.position
                origin = (pos.x, pos.y)
            break
    if origin is None:
        return -2
    if origin == (0, 0):
        return 0
    for m in modes[:n_modes.value]:
        if m.infoType == MODE_SOURCE:
            m.u.sourceMode.position.x -= origin[0]
            m.u.sourceMode.position.y -= origin[1]
    return user32.SetDisplayConfig(n_paths, paths, n_modes, modes,
                                   SDC_APPLY | SDC_USE_SUPPLIED | SDC_SAVE | SDC_ALLOW_CHANGES)


def _set_primary_legacy(target):
    """Older ChangeDisplaySettingsEx route - fallback if the CCD API refuses."""
    ctypes, user32, DEVMODEW, _ = _win_api()
    dx, dy = target["x"], target["y"]
    for d in win_displays():
        dm = DEVMODEW()
        dm.dmSize = ctypes.sizeof(dm)
        user32.EnumDisplaySettingsW(d["device"], ENUM_CURRENT_SETTINGS, ctypes.byref(dm))
        dm.dmPosition.x -= dx
        dm.dmPosition.y -= dy
        dm.dmFields = DM_POSITION
        flags = CDS_UPDATEREGISTRY | CDS_NORESET
        if d["device"] == target["device"]:
            flags |= CDS_SET_PRIMARY
        user32.ChangeDisplaySettingsExW(d["device"], ctypes.byref(dm), None, flags, None)
    return user32.ChangeDisplaySettingsExW(None, None, None, 0, None)


def win_set_primary(match, attempts=4):
    """Make a display primary, check that it worked, retry if the driver was still busy."""
    for attempt in range(1, attempts + 1):
        target = win_find(match)
        if not target:
            log(f"  ! display '{match}' not found")
            return False
        if target["primary"]:
            if attempt > 1:
                log(f"Displays: {match} is now primary")
            return True
        rc = _set_primary_ccd(target["device"])
        if rc != 0:
            log(f"  ! SetDisplayConfig returned {rc}, trying the older API")
            _set_primary_legacy(target)
        time.sleep(1.5)
    ok = bool(win_find(match) and win_find(match)["primary"])
    log(f"Displays: {match} is now primary" if ok else f"  ! couldn't make {match} primary")
    return ok


def win_displays_sofa(cfg):
    tv = cfg["win_tv"]
    log("Displays: extend to the TV")
    run(["DisplaySwitch.exe", "/extend"])
    if not tv:
        time.sleep(cfg["display_settle_seconds"])
        return
    if not wait_for(lambda: win_find(tv) is not None, 15, interval=1):
        log("  ! the TV didn't show up as a display - leaving the desk monitor as primary")
        return
    time.sleep(1)                       # let Windows finish the mode change
    primary_ok = win_set_primary(tv)
    if not cfg["win_keep_desk_on"]:
        run(["DisplaySwitch.exe", "/external"])
    # win_set_primary already waited for and confirmed the change, so a short pause is enough
    time.sleep(0.5 if primary_ok and cfg["win_keep_desk_on"] else cfg["display_settle_seconds"])


def win_displays_desk(cfg):
    if cfg["win_desk"] and win_find(cfg["win_desk"]):
        win_set_primary(cfg["win_desk"])
        time.sleep(1)
    log("Displays: PC screen only")
    run(["DisplaySwitch.exe", "/internal"])
    time.sleep(cfg["display_settle_seconds"])


def hypr_focus_workspace(name):
    if not hypr_lua():
        return hyprctl("dispatch", "workspace", name)
    return hyprctl("dispatch", f"hl.dsp.focus({{ workspace = {_lua_str(name)} }})")


def hypr_reclaim_workspaces(tv, desk, keep):
    """Move workspaces other than `keep` off the TV - Hyprland can hand a newly
    enabled monitor an existing workspace (windows and all)."""
    p = hyprctl("workspaces", "-j")
    try:
        stray = [w["name"] for w in json.loads(p.stdout)
                 if w.get("monitor") == tv and w.get("name") != keep.removeprefix("name:")]
    except (AttributeError, ValueError):
        return
    for name in stray:
        log(f"Displays: workspace {name} back to {desk}")
        hyprctl("dispatch", f"hl.dsp.workspace.move({{ workspace = {_lua_str(name)}, "
                            f"monitor = {_lua_str(desk)} }})")


def hypr_clients():
    p = hyprctl("clients", "-j")
    try:
        return json.loads(p.stdout)
    except (AttributeError, ValueError):
        return []


def hypr_steam_workspace():
    """Workspace of Steam's main window before sofa mode, to put it back afterwards."""
    for c in hypr_clients():
        if c.get("class") == "steam" and c.get("title") == "Steam":
            return c.get("workspace", {}).get("name")
    return None


def hypr_rehome_tv_windows(cfg, before):
    """Desk mode: windows left on the TV workspace (Steam after Big Picture closes, a game
    still running) would sit on a workspace no key reaches. Put Steam back where it was,
    everything else on the workspace in front of you."""
    tv_ws = cfg["hypr_tv_workspace"].removeprefix("name:")
    mons = hypr_monitors()
    here = next((m["activeWorkspace"]["name"] for m in mons if m.get("focused")), None) \
        or (mons[0]["activeWorkspace"]["name"] if mons else "1")
    for c in hypr_clients():
        if c.get("workspace", {}).get("name") != tv_ws:
            continue
        dest = (before or {}).get("steam_ws") if c.get("class") == "steam" else None
        dest = dest if dest and dest != tv_ws else here
        log(f"Displays: {c.get('title') or c.get('class')} -> workspace {dest}")
        hyprctl("dispatch", f"hl.dsp.window.move({{ workspace = {_lua_str(dest)}, "
                            f"window = {_lua_str('address:' + c['address'])} }})")


def hypr_big_picture_open():
    p = hyprctl("clients", "-j")
    try:
        return any(c.get("title") == "Steam Big Picture Mode" for c in json.loads(p.stdout))
    except (AttributeError, ValueError):
        return False


def hypr_reload_layout(mon):
    """Lua config: monitors.lua / sofa.lua read state.json, so a reload applies the
    whole layout (screens, the TV workspace and its window rules) in one go."""
    hyprctl("reload")
    return wait_for(lambda: hypr_active(mon), 10)


def displays_sofa(cfg):
    if IS_WIN:
        return win_displays_sofa(cfg)
    tv, desk = cfg["hypr_tv"], cfg["hypr_desk"]
    if not tv:
        return
    if hypr_lua():                      # state.json already says "sofa" (see sofa())
        log(f"Displays: reload layout - {tv} on, workspace {cfg['hypr_tv_workspace']}")
        if not hypr_reload_layout(tv):
            log(f"  ! {tv} did not come up")
            return
        hypr_focus_workspace(cfg["hypr_tv_workspace"])
        time.sleep(1)
        return
    log(f"Displays: enable {tv}")
    hypr_monitor_on(tv, cfg["hypr_tv_mode"])
    if not wait_for(lambda: hypr_active(tv), 10):
        log(f"  ! {tv} did not come up - keeping desk monitor on")
        return
    if cfg["hypr_disable_desk"] and desk:
        log(f"Displays: disable {desk}")
        hypr_monitor_off(desk)
    hypr_focus_monitor(tv)
    time.sleep(1)


def displays_desk(cfg):
    if IS_WIN:
        return win_displays_desk(cfg)
    tv, desk = cfg["hypr_tv"], cfg["hypr_desk"]
    if hypr_lua() and desk:
        write_mode("desk")              # so the reload applies the desk layout
        log(f"Displays: reload layout - {tv} off")
        hypr_reload_layout(desk)
        hypr_focus_monitor(desk)
        return
    if desk:
        log(f"Displays: enable {desk}")
        hypr_monitor_on(desk, cfg["hypr_desk_mode"])
        wait_for(lambda: hypr_active(desk), 10)
        hypr_focus_monitor(desk)
    if tv:
        log(f"Displays: disable {tv}")
        hypr_monitor_off(tv)


# ------------------------------------------------------------------ audio
def set_audio(cfg, device):
    if not device:
        return
    log("Audio: " + device)
    if IS_WIN:
        svv = cfg["soundvolumeview"]
        if not svv:
            log("  ! set 'soundvolumeview' in config.json to switch audio on Windows")
            return
        run([svv, "/SetDefault", device, "all"])
    else:
        run(["pactl", "set-default-sink", device])


# --- Linux: OpenXLR (Wave Link replacement) owns the routing when it's running ---
def _openxlr_token():
    base = os.environ.get("XDG_RUNTIME_DIR") or os.environ.get("XDG_CONFIG_HOME") \
        or str(Path.home() / ".config")
    try:
        return (Path(base) / "openxlr" / "token").read_text(encoding="utf-8").strip()
    except OSError:
        return ""


def openxlr(cmd, **fields):
    """Send one command to the OpenXLR daemon. True on success, None if it isn't running."""
    import urllib.request
    token = _openxlr_token()
    if IS_WIN or not token:
        return None
    req = urllib.request.Request(
        "http://127.0.0.1:37890/api/v1/commands",
        data=json.dumps({"cmd": cmd, **fields}).encode(),
        headers={"Authorization": f"Bearer {token}", "Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(req, timeout=5) as r:
            reply = json.loads(r.read() or b"{}")
    except (OSError, ValueError):
        return None
    for m in reply.get("messages", []):
        if m.get("type") == "error":
            log(f"  ! OpenXLR {cmd}: {m.get('message')}")
    return bool(reply.get("ok"))


def openxlr_outputs(devices):
    """Point OpenXLR's monitor mix at these sinks (ones not plugged in yet are linked
    as soon as they appear - e.g. the controller headset)."""
    if openxlr("setMonitorOutputs", devices=devices) is None:
        return False
    for d in devices:
        openxlr("setMonitorFeed", device=d, mix="monitor")
    return True


def sinks():
    p = run(["pactl", "list", "short", "sinks"])
    return [l.split("\t")[1] for l in (p.stdout.splitlines() if p else []) if "\t" in l]


def hdmi_profile(cfg, profile):
    if not IS_WIN and cfg["hdmi_card"] and profile:
        log(f"Audio: HDMI card -> {profile}")
        run(["pactl", "set-card-profile", cfg["hdmi_card"], profile])


def sofa_audio_choice(cfg, choice=None):
    choices = cfg["openxlr_sofa_outputs"]
    choice = choice or read_prefs().get("sofa_audio") or cfg["openxlr_sofa_default"]
    return choice if choice in choices else next(iter(choices), "")


def audio_sofa(cfg, choice=None):
    choice = sofa_audio_choice(cfg, choice)
    devices = cfg["openxlr_sofa_outputs"].get(choice, [])
    if not IS_WIN and devices and _openxlr_token():
        hdmi_profile(cfg, cfg["hdmi_profile_sofa"])
        hdmi = [d for d in devices if d.startswith("alsa_output.pci")]
        if hdmi and not wait_for(lambda: all(d in sinks() for d in hdmi), 8):
            log(f"  ! {hdmi[0]} didn't appear - is the TV on and showing the PC?")
        apply_trims(cfg, devices)
        log(f"Audio: sofa -> {choice}")
        if openxlr_outputs(devices):
            write_prefs(sofa_audio=choice)
            return
        log("  ! OpenXLR isn't answering - falling back to the default sink")
    set_audio(cfg, cfg["audio_sofa"])


def audio_desk(cfg):
    if not IS_WIN and cfg["openxlr_desk_outputs"] and _openxlr_token():
        log("Audio: desk")
        apply_trims(cfg, cfg["openxlr_desk_outputs"])
        if openxlr_outputs(cfg["openxlr_desk_outputs"]):
            hdmi_profile(cfg, cfg["hdmi_profile_desk"])
            return
    set_audio(cfg, cfg["audio_desk"])
    hdmi_profile(cfg, cfg["hdmi_profile_desk"])


def notify(msg):
    """Desktop notification (Linux) - the Stream Deck keys have no other feedback."""
    if not IS_WIN and shutil.which("notify-send"):
        run(["notify-send", "-a", "couch", "-t", "2500", msg])


def apply_trims(cfg, devices):
    """Set each present output in `devices` to its calibrated level."""
    present = sinks()
    for name, t in cfg["output_trims"].items():
        if t.get("sink") in devices and t["sink"] in present:
            run(["pactl", "set-sink-volume", t["sink"], f"{int(t['percent'])}%"])


def trim(cfg, name=None, value=None):
    """`couch.py trim [name [percent|+N|-N]]` - show or set an output's fixed level."""
    trims = cfg["output_trims"]
    if not name:
        for n, t in trims.items():
            here = "" if t["sink"] in sinks() else "   (not connected)"
            print(f"{n:12} {int(t['percent']):3d}%{here}")
        return
    if name not in trims:
        sys.exit(f"Unknown output {name!r} - use one of: {', '.join(trims)}")
    t = trims[name]
    if value:
        try:
            pct = t["percent"] + int(value) if value[0] in "+-" else int(value.rstrip("%"))
        except ValueError:
            sys.exit(f"Not a level: {value!r} - use e.g. 70, +5 or -5")
        t["percent"] = max(0, min(150, pct))
        raw = json.loads(CONFIG_FILE.read_text(encoding="utf-8"))
        raw.setdefault("output_trims", {})[name] = t
        CONFIG_FILE.write_text(json.dumps(raw, indent=2), encoding="utf-8")
        if t["sink"] in sinks():
            run(["pactl", "set-sink-volume", t["sink"], f"{int(t['percent'])}%"])
    print(f"{name}: {int(t['percent'])}%")


def audio(cfg, choice=None):
    """`couch.py audio [soundbar|controller|toggle]` - switch sofa audio, or show it."""
    choices = list(cfg["openxlr_sofa_outputs"])
    current = sofa_audio_choice(cfg)
    if choice == "toggle" and choices:
        choice = choices[(choices.index(current) + 1) % len(choices)] if current in choices else choices[0]
    if not choice:
        print(f"Sofa audio:  {current}   (choices: {', '.join(choices)})")
        return
    if choice not in choices:
        sys.exit(f"Unknown audio choice {choice!r} - use one of: {', '.join(choices)}, toggle")
    if in_sofa_now(cfg):
        audio_sofa(cfg, choice)
        notify(f"Sofa audio: {choice}")
    else:
        write_prefs(sofa_audio=choice)
        log(f"Audio: sofa mode will use {choice} next time")
        notify(f"Sofa audio next time: {choice}")


# ------------------------------------------------------------------ steam
def steam_running():
    if IS_WIN:
        p = run(["tasklist", "/FI", "IMAGENAME eq steam.exe", "/NH"])
        return bool(p and "steam.exe" in p.stdout.lower())
    p = run(["pgrep", "-x", "steam"])
    return bool(p and p.returncode == 0)


def steam_url(url):
    if IS_WIN:
        os.startfile(url)  # noqa: S606 - opens via the registered steam:// handler
    else:
        exe = shutil.which("steam") or shutil.which("xdg-open")
        if exe:
            subprocess.Popen([exe, url], stdout=subprocess.DEVNULL,
                             stderr=subprocess.DEVNULL, start_new_session=True)


# ------------------------------------------------------------------ modes
def sofa(cfg, choice=None):
    with Lock():
        log("=== sofa mode ===")
        before = tv_snapshot(cfg)      # remember if the TV was already on, and on what
        saved = read_state()
        if (input_app_id(cfg["tv_pc_input"]) in before.get("tv_prev_app", "").lower()
                and saved.get("mode") == "sofa" and "tv_was_on" in saved):
            # Sofa mode again while already in it (e.g. displays were reset under us):
            # the TV is on the PC because of us - keep what it showed before the first run.
            before = {k: saved[k] for k in ("tv_was_on", "tv_prev_app", "tv_volume_steps", "steam_ws") if k in saved}
            log(f"TV: already in sofa mode - keeping {before.get('tv_prev_app') or 'TV off'} for desk mode")
        if not tv_sofa(cfg):
            log("Stopping: switching displays to a TV that isn't on would leave you without a screen")
            return
        if not IS_WIN and hypr_lua() and "steam_ws" not in before:
            ws = hypr_steam_workspace()
            if ws:
                before["steam_ws"] = ws
            log(f"Steam: main window on workspace {ws or '(none found)'}")
        write_mode("sofa", **before)   # monitors.lua / sofa.lua read this on the reload
        displays_sofa(cfg)
        # Start Big Picture right away (it opens on the new primary display) and fix the
        # TV input at the same time - Steam takes a few seconds to draw anyway.
        if cfg["steam"]:
            log("Steam: Big Picture")
            steam_url("steam://open/bigpicture")
        audio_sofa(cfg, choice)
        tv_ensure_pc_input(cfg)        # now the PC is sending a picture to the TV
        if not IS_WIN and cfg["hypr_tv"] and hypr_lua():
            # Big Picture lands on the TV workspace by window rule; show that workspace
            # once the window exists (focusing it earlier doesn't stick)
            if cfg["steam"]:
                wait_for(lambda: hypr_big_picture_open(), 15)
            hypr_focus_workspace(cfg["hypr_tv_workspace"])
            hypr_reclaim_workspaces(cfg["hypr_tv"], cfg["hypr_desk"], cfg["hypr_tv_workspace"])
        tv_volume_sofa(cfg, before)
        write_mode("sofa", **before)
        log("=== sofa mode ready ===")


def desk(cfg):
    with Lock():
        log("=== desk mode ===")
        before = read_state() if read_mode() == "sofa" else {}
        if cfg["steam"] and steam_running():
            log("Steam: close Big Picture")
            steam_url("steam://close/bigpicture")
            if not IS_WIN and hypr_lua():
                wait_for(lambda: not hypr_big_picture_open(), 5)
            time.sleep(1)
        # TV first, while it still shows the PC: right after its input loses the signal
        # webOS can be too busy to answer, and we'd wrongly conclude it's off
        tv_volume_restore(cfg, before)
        tv_desk(cfg, before)
        displays_desk(cfg)
        if not IS_WIN and hypr_lua():
            hypr_rehome_tv_windows(cfg, before)
        audio_desk(cfg)
        write_mode("desk")
        desk_mon = cfg["hypr_desk"]
        if not IS_WIN and desk_mon and not wait_for(lambda: hypr_active(desk_mon), 4):
            # The monitor can drop into standby while it has no signal and not come back
            # (Hyprland shows a FALLBACK output). A reload re-applies monitors.lua, which
            # reads state.json - so this must come after write_mode("desk").
            log(f"  ! {desk_mon} didn't come back - reloading Hyprland's monitor layout")
            hyprctl("reload")
            wait_for(lambda: hypr_active(desk_mon), 8)
        log("=== desk mode ready ===")


def in_sofa_now(cfg):
    """Look at the real state instead of trusting state.json, which can drift."""
    try:
        if IS_WIN and cfg["win_tv"]:
            tv = win_find(cfg["win_tv"])
            return bool(tv and tv["primary"])
        if not IS_WIN and cfg["hypr_tv"]:
            return hypr_active(cfg["hypr_tv"])
    except Exception as exc:        # fall back to the saved mode
        log(f"  ! couldn't read display state ({exc})")
    return read_mode() == "sofa"


def toggle(cfg):
    sofa_now = in_sofa_now(cfg)
    log(f"Toggle: currently in {'sofa' if sofa_now else 'desk'} mode")
    (desk if sofa_now else sofa)(cfg)


def status(cfg):
    print(f"Mode:        {read_mode()}")
    if cfg["tv_ip"]:
        current = tv_current_input(cfg)
        print(f"TV input:    {current or 'off / unreachable'}")
        if current:
            on_pc = input_app_id(cfg["tv_pc_input"]) in current.lower()
            print(f"TV on PC:    {'yes' if on_pc else 'no'}")
    if not IS_WIN and cfg["hypr_tv"]:
        print(f"Hypr TV:     {'active' if hypr_active(cfg['hypr_tv']) else 'off'}")
    if not IS_WIN and cfg["openxlr_sofa_outputs"]:
        print(f"Sofa audio:  {sofa_audio_choice(cfg)}   "
              f"(OpenXLR {'running' if _openxlr_token() else 'not running'})")
    print(f"Config:      {CONFIG_FILE}")
    print(f"Log:         {LOG_FILE}")


# ------------------------------------------------------------------ controller listener
# SDL's standard controller buttons, in SDL's own numbering
SDL_BUTTONS = ["a", "b", "x", "y", "back", "guide", "start", "leftstick", "rightstick",
               "leftshoulder", "rightshoulder", "dpup", "dpdown", "dpleft", "dpright",
               "misc1", "paddle1", "paddle2", "paddle3", "paddle4", "touchpad"]
BUTTON_HINTS = {"back": "View (two squares)", "start": "Menu (three lines)", "guide": "Xbox button",
                "misc1": "Share", "paddle1": "back paddle", "paddle2": "back paddle",
                "paddle3": "back paddle", "paddle4": "back paddle"}


def _sdl():
    import faulthandler
    try:                                  # print where it died if SDL crashes natively
        faulthandler.enable(open(LOG_FILE, "a", encoding="utf-8") if sys.stderr is None else sys.stderr)
    except Exception:
        pass
    os.environ["SDL_JOYSTICK_ALLOW_BACKGROUND_EVENTS"] = "1"
    os.environ.setdefault("SDL_VIDEODRIVER", "dummy")
    os.environ["PYGAME_HIDE_SUPPORT_PROMPT"] = "1"
    try:
        import pygame
        from pygame._sdl2 import controller
    except ImportError:
        sys.exit("pygame is needed for this:  pip install pygame")
    pygame.display.init()
    pygame.joystick.init()
    controller.init()
    return pygame, controller


def button_name(kind, num):
    if kind == "ctrl" and 0 <= num < len(SDL_BUTTONS):
        return SDL_BUTTONS[num]
    return f"joy:{num}"


def parse_button(spec):
    """'back+start', 'guide', 'misc1' ... or 'joy:12' -> set of (kind, number)."""
    out = set()
    for part in (spec or "back+start").strip().lower().replace(" ", "").split("+"):
        part = {"view": "back", "menu": "start", "xbox": "guide", "share": "misc1"}.get(part, part)
        if part.startswith("joy:"):
            out.add(("joy", int(part[4:])))
        elif part in SDL_BUTTONS:
            out.add(("ctrl", SDL_BUTTONS.index(part)))
    return out or {("ctrl", SDL_BUTTONS.index("back")), ("ctrl", SDL_BUTTONS.index("start"))}


class Pads:
    """Tracks connected controllers / joysticks and their names."""
    def __init__(self, pygame, controller):
        self.pg, self.ctl, self.names, self.objs = pygame, controller, {}, {}

    def handle(self, ev):
        pg = self.pg
        if ev.type == pg.CONTROLLERDEVICEADDED:
            pad = self.ctl.Controller(ev.device_index)
            iid = pad.as_joystick().get_instance_id()
            # pygame has controller.name_forindex(); pygame-ce only the Controller.name attribute
            name_for = getattr(self.ctl, "name_forindex", None)
            self.objs[iid], self.names[iid] = pad, name_for(ev.device_index) if name_for else pad.name
            return f"controller connected: {self.names[iid]!r}"
        if ev.type == pg.JOYDEVICEADDED:
            # Devices SDL knows as game controllers are opened above - opening the same
            # device twice can crash some SDL builds on Windows, so only open the others.
            try:
                if self.ctl.is_controller(ev.device_index):
                    return None
            except Exception:
                return None
            js = pg.joystick.Joystick(ev.device_index)
            iid = js.get_instance_id()
            self.objs.setdefault(iid, js)
            self.names.setdefault(iid, js.get_name())
            return None
        if ev.type in (pg.CONTROLLERDEVICEREMOVED, pg.JOYDEVICEREMOVED):
            name = self.names.pop(ev.instance_id, None)
            self.objs.pop(ev.instance_id, None)
            return f"controller disconnected: {name!r}" if name else None
        return None

    def button_event(self, ev):
        """(kind, number, pressed, instance_id) for button events, else None."""
        pg = self.pg
        if ev.type in (pg.CONTROLLERBUTTONDOWN, pg.CONTROLLERBUTTONUP):
            return ("ctrl", ev.button, ev.type == pg.CONTROLLERBUTTONDOWN, ev.instance_id)
        if ev.type in (pg.JOYBUTTONDOWN, pg.JOYBUTTONUP):
            return ("joy", ev.button, ev.type == pg.JOYBUTTONDOWN, ev.instance_id)
        return None


def buttons_sdl(cfg):
    """Print every button press the PC sees, to pick a trigger button."""
    pygame, controller = _sdl()
    pads = Pads(pygame, controller)
    print(f"SDL {'.'.join(map(str, pygame.get_sdl_version()))}, pygame {pygame.version.ver}")
    print("Press the controller's buttons one at a time (Ctrl+C to stop).")
    print("Use the name shown as  listen_button  in config.json.\n")
    shown_count = False
    t0 = time.monotonic()
    while True:
        for ev in pygame.event.get():
            msg = pads.handle(ev)
            if msg:
                print(msg)
            b = pads.button_event(ev)
            if b and b[2]:
                kind, num, _, iid = b
                name = button_name(kind, num)
                hint = BUTTON_HINTS.get(name, "")
                src = "mapped " if kind == "ctrl" else "raw    "
                print(f"  {src} {name:14} {hint:22} ({pads.names.get(iid, '?')})")
        if not shown_count and time.monotonic() - t0 > 2:
            shown_count = True
            if not pads.names:
                print("No controllers found yet - switch it on / check the dongle. "
                      f"(SDL sees {pygame.joystick.get_count()} joystick devices)")
        time.sleep(0.01)


def listen_sdl(cfg):
    pygame, controller = _sdl()
    pads = Pads(pygame, controller)
    match = cfg["listen_controller_match"].lower()
    hold = cfg["listen_hold_seconds"]
    want = parse_button(cfg["listen_button"])
    label = "+".join(sorted(button_name(*w) for w in want))
    held = set()
    auto_desk = cfg["listen_auto_desk_minutes"] * 60
    down_at = None
    last_seen = time.monotonic()
    busy = threading.Event()

    def matching(iid):
        return match in (pads.names.get(iid) or "").lower()

    def trigger(fn, reason):
        if busy.is_set():
            return
        log(f"Listener: {reason}")

        def work():
            busy.set()
            try:
                # A fresh process per switch: this listener runs for the whole session, and
                # calling fn() here would keep using the couch.py it loaded at login
                subprocess.run([python_exe(), str(Path(__file__).resolve()), fn.__name__],
                               cwd=HERE, timeout=180)
            except Exception as exc:  # keep the listener alive whatever happens
                log(f"  ! {exc}")
            finally:
                busy.clear()
        threading.Thread(target=work, daemon=True).start()

    log(f"Listener: started - hold '{label}' for {hold:g} s to toggle")
    while True:
        for ev in pygame.event.get():
            if ev.type == pygame.QUIT:      # SDL turns SIGTERM/SIGINT into this event
                log("Listener: stopped")
                return
            msg = pads.handle(ev)
            if msg:
                log("Listener: " + msg)
                if "disconnected" in msg:
                    down_at = None
            b = pads.button_event(ev)
            if b and (b[0], b[1]) in want and matching(b[3]):
                (held.add if b[2] else held.discard)((b[0], b[1]))
                if held >= want:
                    down_at = down_at or time.monotonic()
                else:
                    down_at = None                              # released early: ignored

        now = time.monotonic()
        if down_at is not None and now - down_at >= hold:
            down_at = None
            # Buzz so you know to let go - holding on can trip the controller's own combos
            # (on the 8BitDo Ultimate 3, View+Menu held longer switches its USB mode).
            for iid, obj in pads.objs.items():
                if matching(iid) and hasattr(obj, "rumble"):
                    try:
                        obj.rumble(0.6, 0.6, 250)
                    except Exception:
                        pass
            trigger(toggle, f"'{label}' held {hold:g} s - toggling")

        if any(matching(i) for i in pads.names):
            last_seen = now
        elif auto_desk and read_mode() == "sofa" and now - last_seen > auto_desk:
            last_seen = now
            trigger(desk, f"controller off for {cfg['listen_auto_desk_minutes']} min")

        time.sleep(0.02)


# --- Windows: read Xbox controllers through XInput (works in the background) ---
XI_BUTTONS = {"dpup": 0x0001, "dpdown": 0x0002, "dpleft": 0x0004, "dpright": 0x0008,
              "start": 0x0010, "back": 0x0020, "leftstick": 0x0040, "rightstick": 0x0080,
              "leftshoulder": 0x0100, "rightshoulder": 0x0200, "guide": 0x0400,
              "a": 0x1000, "b": 0x2000, "x": 0x4000, "y": 0x8000}
XI_ALIASES = {"view": "back", "menu": "start", "xbox": "guide", "lb": "leftshoulder",
              "rb": "rightshoulder", "ls": "leftstick", "rs": "rightstick"}
XI_HINTS = {"back": "View (two squares)", "start": "Menu (three lines)", "guide": "Xbox button"}


def _xinput():
    """Returns get_state(pad) -> (connected, buttons). Uses the hidden GetStateEx (ordinal 100)
    so the Xbox button is included; falls back to plain XInputGetState."""
    import ctypes
    from ctypes import wintypes as w

    class GAMEPAD(ctypes.Structure):
        _fields_ = [("wButtons", w.WORD), ("bLeftTrigger", ctypes.c_ubyte), ("bRightTrigger", ctypes.c_ubyte),
                    ("sThumbLX", ctypes.c_short), ("sThumbLY", ctypes.c_short),
                    ("sThumbRX", ctypes.c_short), ("sThumbRY", ctypes.c_short)]

    class STATE(ctypes.Structure):
        _fields_ = [("dwPacketNumber", w.DWORD), ("Gamepad", GAMEPAD)]

    fn = None
    for dll in ("xinput1_4", "xinput1_3", "xinput9_1_0"):
        try:
            lib = ctypes.WinDLL(dll)
        except OSError:
            continue
        try:
            fn = lib[100]                         # XInputGetStateEx
        except (AttributeError, OSError):
            fn = lib.XInputGetState
        break
    if fn is None:
        sys.exit("XInput isn't available on this PC")
    fn.argtypes, fn.restype = [w.DWORD, ctypes.POINTER(STATE)], w.DWORD

    def get_state(pad):
        st = STATE()
        if fn(pad, ctypes.byref(st)) != 0:
            return False, 0
        return True, st.Gamepad.wButtons
    return get_state


def parse_combo(spec):
    """'back+start', 'view+menu', 'guide' ... -> XInput bit mask."""
    mask = 0
    for part in (spec or "back+start").lower().replace(" ", "").split("+"):
        part = XI_ALIASES.get(part, part)
        if part not in XI_BUTTONS:
            log(f"  ! unknown button '{part}' in listen_button - using View+Menu")
            return XI_BUTTONS["back"] | XI_BUTTONS["start"]
        mask |= XI_BUTTONS[part]
    return mask


def combo_name(mask):
    return "+".join(n for n, bit in XI_BUTTONS.items() if mask & bit)


def buttons_win(cfg):
    get_state = _xinput()
    print("Reading Xbox controllers through XInput. Press buttons (Ctrl+C to stop).")
    print("Hold several at once to see a combination. Put the name in  listen_button.\n")
    last = {}
    while True:
        for pad in range(4):
            ok, btn = get_state(pad)
            prev = last.get(pad)
            if ok and prev is None:
                print(f"controller {pad + 1} connected")
            elif not ok and prev is not None:
                print(f"controller {pad + 1} disconnected")
            if ok and btn != (prev or 0) and btn:
                names = combo_name(btn)
                hints = ", ".join(XI_HINTS[n] for n in names.split("+") if n in XI_HINTS)
                print(f"  controller {pad + 1}: {names}" + (f"   ({hints})" if hints else ""))
            last[pad] = btn if ok else None
        time.sleep(0.02)


def listen_win(cfg):
    get_state = _xinput()
    want = parse_combo(cfg["listen_button"])
    label, hold = combo_name(want), cfg["listen_hold_seconds"]
    auto_desk = cfg["listen_auto_desk_minutes"] * 60
    busy = threading.Event()
    down_at, fired, connected = None, False, set()
    last_seen = time.monotonic()

    def trigger(fn, reason):
        if busy.is_set():
            return
        log(f"Listener: {reason}")

        def work():
            busy.set()
            try:
                fn(load_config())
            except Exception as exc:
                log(f"  ! {exc}")
            finally:
                busy.clear()
        threading.Thread(target=work, daemon=True).start()

    log(f"Listener: started (XInput) - hold {label} for {hold:g} s to toggle")
    while True:
        held_now = False
        for pad in range(4):
            ok, btn = get_state(pad)
            if ok and pad not in connected:
                connected.add(pad)
                log(f"Listener: controller {pad + 1} connected")
            elif not ok and pad in connected:
                connected.discard(pad)
                log(f"Listener: controller {pad + 1} disconnected")
            if ok and (btn & want) == want:
                held_now = True
        now = time.monotonic()
        if held_now:
            if down_at is None:
                down_at, fired = now, False
            elif not fired and now - down_at >= hold:
                fired = True                       # once per hold
                trigger(toggle, f"{label} held {hold:g} s - toggling")
        else:
            down_at = None
        if connected:
            last_seen = now
        elif auto_desk and read_mode() == "sofa" and now - last_seen > auto_desk:
            last_seen = now
            trigger(desk, f"controller off for {cfg['listen_auto_desk_minutes']} min")
        time.sleep(0.02)


def buttons(cfg):
    return buttons_win(cfg) if IS_WIN else buttons_sdl(cfg)


def listen(cfg):
    return listen_win(cfg) if IS_WIN else listen_sdl(cfg)


# ------------------------------------------------------------------ setup wizard
def ask(prompt, default=""):
    hint = f" [{default}]" if default != "" else ""
    answer = input(f"{prompt}{hint}: ").strip()
    return answer or default


def ask_yes(prompt, default=True):
    answer = ask(prompt + " (y/n)", "y" if default else "n").lower()
    return answer.startswith("y")


def find_mac(ip):
    run(["ping", "-n", "1", "-w", "1000", ip] if IS_WIN else ["ping", "-c", "1", "-W", "1", ip])
    p = run(["arp", "-a", ip] if IS_WIN else ["ip", "neigh", "show", ip])
    if not p:
        return ""
    m = re.search(r"([0-9a-fA-F]{2}[:-]){5}[0-9a-fA-F]{2}", p.stdout)
    return m.group(0).replace("-", ":").upper() if m else ""


def setup():
    cfg = dict(DEFAULTS)
    if CONFIG_FILE.exists():
        cfg.update(json.loads(CONFIG_FILE.read_text(encoding="utf-8")))
        print(f"Updating existing config ({CONFIG_FILE}). Press Enter to keep a value.\n")

    print("== TV ==")
    print("Turn the TV on and make sure it's on the same network as this PC.")
    cfg["tv_ip"] = ask("TV IP address", cfg["tv_ip"] or "192.168.1.50")
    mac = cfg["tv_mac"] or find_mac(cfg["tv_ip"])
    cfg["tv_mac"] = ask("TV MAC address (for Wake-on-LAN)", mac)

    if have_bscpylgtv():
        print("\nConnecting to the TV - accept the pairing prompt on the TV if it appears...")
        inputs = tv_cmd(cfg, "get_inputs", timeout=60)
        if inputs:
            print("\nInputs reported by the TV:")
            try:
                import ast
                for i in ast.literal_eval(inputs):
                    plugged = "connected" if i.get("connected") else "empty"
                    print(f"  {i.get('id', '?'):8} {i.get('label', ''):20} ({plugged})")
            except (ValueError, SyntaxError):
                print(inputs)
            print()
        else:
            print("  Couldn't reach the TV. Check the IP, that it's on, and try again.")
            print("  Last error is in couch.log next to this script.\n")
    else:
        print("\n  bscpylgtv isn't installed - run: pip install bscpylgtv  (then setup again)\n")

    cfg["tv_pc_input"] = ask("Input the PC is on (e.g. HDMI_2)", cfg["tv_pc_input"])
    cfg["tv_on_desk"] = ask("In desk mode, the TV should: off / nothing / an input like HDMI_1",
                            cfg["tv_on_desk"])

    print("\n== Displays ==")
    if IS_WIN:
        print("Sofa mode extends to the TV and makes it the primary display; the desk")
        print("monitor stays on. Turn the TV on and press Win+P -> Extend now, so both are listed.")
        input("Press Enter when both screens show a picture... ")
        mons = win_displays()
        for n, d in enumerate(mons, 1):
            print(f"  {n}. {d['monitor'] or '?':28} {d['hwid']:10} {d['w']}x{d['h']}@{d['hz']}"
                  f"{'  (primary)' if d['primary'] else ''}")

        def pick(prompt, current):
            cur = next((str(i) for i, d in enumerate(mons, 1) if current and current == d["hwid"]), "")
            ans = ask(prompt, cur)
            if ans.isdigit() and 1 <= int(ans) <= len(mons):
                return mons[int(ans) - 1]["hwid"] or mons[int(ans) - 1]["device"]
            return current

        if len(mons) >= 2:
            cfg["win_tv"] = pick("Which number is the TV", cfg["win_tv"])
            cfg["win_desk"] = pick("Which number is your desk monitor", cfg["win_desk"])
            cfg["win_keep_desk_on"] = ask_yes("Keep the desk monitor on in sofa mode?",
                                              cfg["win_keep_desk_on"])
        else:
            print("  Only one display found - run setup again with the TV extended.")
    else:
        mons = hypr_monitors(all_=True)
        for m in mons:
            print(f"  {m.get('name'):12} {m.get('description', '')}")
        if not mons:
            print("  (couldn't list monitors - is Hyprland running?)")
        cfg["hypr_tv"] = ask("TV output name", cfg["hypr_tv"] or "HDMI-A-1")
        cfg["hypr_tv_mode"] = ask("TV mode (resolution@hz,position,scale)", cfg["hypr_tv_mode"])
        cfg["hypr_desk"] = ask("Desk monitor output name", cfg["hypr_desk"] or "DP-1")
        cfg["hypr_desk_mode"] = ask("Desk monitor mode", cfg["hypr_desk_mode"])
        cfg["hypr_disable_desk"] = ask_yes("Turn the desk monitor off in sofa mode?",
                                           cfg["hypr_disable_desk"])

    print("\n== Audio ==")
    if IS_WIN:
        print("Audio switching on Windows uses NirSoft SoundVolumeView (free).")
        cfg["soundvolumeview"] = ask("Path to SoundVolumeView.exe (blank = don't switch audio)",
                                     cfg["soundvolumeview"])
        if cfg["soundvolumeview"]:
            print("Use the device names shown in Windows Sound settings.")
            cfg["audio_sofa"] = ask("Sofa audio device (TV or controller headset)", cfg["audio_sofa"])
            cfg["audio_desk"] = ask("Desk audio device", cfg["audio_desk"])
    else:
        p = run(["pactl", "list", "short", "sinks"])
        if p and p.stdout.strip():
            for line in p.stdout.strip().splitlines():
                parts = line.split("\t")
                if len(parts) > 1:
                    print("  " + parts[1])
        cfg["audio_sofa"] = ask("Sofa audio sink (blank = don't switch)", cfg["audio_sofa"])
        cfg["audio_desk"] = ask("Desk audio sink", cfg["audio_desk"])

    print("\n== Steam & controller ==")
    cfg["steam"] = ask_yes("Open Steam Big Picture in sofa mode?", cfg["steam"])
    cfg["listen_controller_match"] = ask(
        "Only react to controllers whose name contains (blank = any; run `listen` once to see names)",
        cfg["listen_controller_match"]).lower()
    cfg["listen_auto_desk_minutes"] = int(ask(
        "Return to desk mode when the controller has been off for N minutes (0 = never)",
        str(cfg["listen_auto_desk_minutes"])))

    CONFIG_FILE.write_text(json.dumps(cfg, indent=2), encoding="utf-8")
    me = Path(__file__).resolve()
    print(f"\nSaved {CONFIG_FILE}\n\nTry it:  python \"{me}\" sofa   then   python \"{me}\" desk")
    if IS_WIN:
        print(f"Stream Deck (Advanced Launcher):  pythonw.exe  \"{me}\" toggle")
    else:
        print(f"Hyprland autostart:  exec-once = python \"{me}\" listen")


# ------------------------------------------------------------------ main
def main():
    commands = ["setup", "sofa", "desk", "toggle", "audio", "trim", "tvvolume", "listen", "buttons", "status",
                "barsync"]
    # Log how we were started, so a mis-typed Stream Deck argument shows up in couch.log
    given = [a.strip().strip('"').lower() for a in sys.argv[1:]]
    command = next((a for a in given if a in commands), None)
    if command is None:
        log(f"! Unknown arguments {sys.argv[1:]} - use one of: {', '.join(commands)}")
        sys.exit(2)
    # `sofa soundbar`, `audio controller`, `audio toggle`: the word after the command
    rest = given[given.index(command) + 1:]
    args = argparse.Namespace(command=command, choice=rest[0] if rest else None)

    if args.command == "setup":
        return setup()
    cfg = load_config()
    try:
        if args.command in ("sofa", "audio"):
            return {"sofa": sofa, "audio": audio}[args.command](cfg, args.choice)
        if args.command == "trim":
            return trim(cfg, *rest[:2])
        if args.command == "tvvolume":
            return tvvolume(cfg, *rest[:1])
        if args.command == "barsync":   # Ironbar just started: show the current mode
            return bar_sync()
        {"desk": desk, "toggle": toggle,
         "listen": listen, "buttons": buttons, "status": status}[args.command](cfg)
    except RuntimeError as exc:
        log(f"Skipped: {exc}")
    except KeyboardInterrupt:
        pass


if __name__ == "__main__":
    main()
