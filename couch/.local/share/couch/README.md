# couch.py — sofa mode for Windows and Hyprland

One script that does the whole switch: wakes the LG TV, picks the PC input, moves the
picture to the TV, switches audio and opens Steam Big Picture — and back again.
The Stream Deck button and the controller's Xbox button both call it.

## 1. Install (once per OS)

```
pip install bscpylgtv pygame
```
On Linux, use a venv or `pipx`/`--user` as you prefer.

On the TV:
- **Settings → General → Devices → TV Management → Turn on via Wi-Fi** (wording varies by
  webOS version — search settings for "Turn on via"). Without it, Wake-on-LAN can't wake it.
- **Quick Start+** on, if your model has it.

## 2. Run setup (once per OS)

With the TV **on**:
```
python couch.py setup
```
It finds the TV's MAC address, pairs with the TV (accept the prompt on screen), lists the
TV's inputs, your monitors and audio devices, and writes `config.json` next to the script.
Re-run it any time to change something — Enter keeps the current value.

Then test:
```
python couch.py sofa
python couch.py desk
python couch.py status
```
Everything is logged to `couch.log` next to the script.

## 3. Hook it up

**Windows — Stream Deck**
Replace the whole Multi Action with one **Advanced Launcher** action:
- Application: `pythonw.exe`
- Arguments: `"C:\path\to\couch.py" toggle`

Keep the **Wave Link** step as a separate action if you still want it.

**Windows — controller listener at login**
Task Scheduler → Create Task → Trigger *At log on* → Action:
`pythonw.exe "C:\path\to\couch.py" listen`

Also turn off **Settings → Gaming → Xbox Game Bar → "Open Xbox Game Bar using this button
on a controller"**, so Game Bar doesn't grab the Xbox button.

**Hyprland**
```
exec-once = python ~/path/to/couch.py listen
```
For the Stream Deck in StreamController, a "Run command" action with
`python ~/path/to/couch.py toggle`.

## Controller

| Action | Result |
|---|---|
| Hold **both sticks pressed in (L3 + R3)** for 1.5 s - the controller buzzes, then let go | toggle sofa ↔ desk |
| Turn the controller on / short presses | nothing (so you can play at the desk) |
| Controller off for N minutes (if set in setup) | desk mode |

Change the button(s) with `listen_button` in config.json, e.g. `"back+start"` (View+Menu,
default), `"guide"` (Xbox button) or `"lb+rb+back"`. `python couch.py buttons` shows the
names as you press them. On Windows the controller is read through XInput, which works in
the background but can't see Share or the back paddles — map a paddle to a standard button
in 8BitDo Ultimate Software X if you want to use one. The hold time is
`listen_hold_seconds`.

Run `python couch.py listen` in a terminal once and switch the controller on: it prints the
controller's name. Put part of it in `listen_controller_match` so other controllers don't
trigger anything.

## Settings worth knowing (config.json)

| Key | What it does |
|---|---|
| `tv_on_desk` | `off`, `nothing`, or an input like `HDMI_1` (Apple TV) when going back to desk. If the TV was **already on** when sofa mode started, desk mode leaves it on and switches it back to whatever it was showing |
| `tv_wake_timeout` | how long to wait for the TV to wake (seconds) |
| `tv_extra_args` | extra bscpylgtv flags, e.g. `["-w"]` to connect without SSL if pairing fails |
| `display_settle_seconds` | pause after switching displays on Windows before Steam opens |
| `win_tv`, `win_desk` | the TV's and desk monitor's IDs (e.g. `GSM8394` — GSM is LG). Sofa mode extends to the TV (Win+P "Extend") and makes it primary using Windows' display API; desk mode makes the desk monitor primary and switches to "PC screen only". Set by `setup` |
| `win_keep_desk_on` | keep the desk monitor on in sofa mode (default) |
| `soundvolumeview` + `audio_sofa`/`audio_desk` | Windows audio switching via NirSoft SoundVolumeView |
| `hypr_disable_desk` | turn the desk monitor off in sofa mode on Hyprland |

## TV input

Sofa mode switches the TV to the PC input again once the PC is actually sending a picture,
and checks that it stays there. If the log says it couldn't keep the input, the Apple TV is
probably taking over over HDMI-CEC: on the Apple TV turn off
**Settings → Remotes and Devices → Control TVs and Receivers**.

## Safety

If the TV doesn't respond, sofa mode stops **before** touching the displays, so you never
end up with the picture sent to a screen that's off.
