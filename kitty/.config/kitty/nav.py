# ctrl+h/j/k/l: focus the neighbouring kitty split; at the edge of the tab, hand
# focus to the neighbouring Hyprland window. Off Hyprland (macOS) it only moves
# between splits, like plain neighboring_window. nvim gets these keys itself
# (IS_NVIM mappings) and does the same through smart-splits' at_edge.
import os
import shutil
import subprocess

from kittens.tui.handler import result_handler


def main(args):
    pass


@result_handler(no_ui=True)
def handle_result(args, answer, target_window_id, boss):
    direction = args[1]
    tab = boss.active_tab
    if tab is not None:
        before = tab.active_window
        tab.neighboring_window(direction)
        if tab.active_window is not before:
            return
    if os.environ.get("HYPRLAND_INSTANCE_SIGNATURE") and shutil.which("hyprctl"):
        subprocess.Popen(
            ["hyprctl", "eval", f'hl.dispatch(hl.dsp.focus({{ direction = "{direction}" }}))'],
            stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
        )
