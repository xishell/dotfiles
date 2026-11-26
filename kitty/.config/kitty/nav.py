# kitty has no at-edge hook, so this kitten hands focus to hyprland past the last split
import os
import shutil
import subprocess

from kittens.tui.handler import result_handler

# tab.neighboring_window skips the action parser that maps up/down to top/bottom
KITTY_EDGE = {"left": "left", "right": "right", "up": "top", "down": "bottom"}


def main(args):
    pass


@result_handler(no_ui=True)
def handle_result(args, answer, target_window_id, boss):
    direction = args[1]
    tab = boss.active_tab
    if tab is not None:
        before = tab.active_window
        tab.neighboring_window(KITTY_EDGE[direction])
        if tab.active_window is not before:
            return
    if os.environ.get("HYPRLAND_INSTANCE_SIGNATURE") and shutil.which("hyprctl"):
        subprocess.Popen(
            ["hyprctl", "eval", f'hl.dispatch(hl.dsp.focus({{ direction = "{direction}" }}))'],
            stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
        )
