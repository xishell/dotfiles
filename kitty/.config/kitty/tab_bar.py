# session block, powerline tabs, active window's cwd on the right
import os
from urllib.parse import unquote

from kitty.boss import get_boss
from kitty.fast_data_types import Screen
from kitty.tab_bar import DrawData, ExtraData, TabBarData, as_rgb, color_as_int

# tokyonight night, same values as tokyonight_night.conf
DARK = 0x16161E
SESSION_BG = 0xBB9AF7
ACTIVE_BG = 0x7AA2F7
INACTIVE_BG = 0x292E42
INACTIVE_FG = 0x545C7E
PATH_FG = 0xA9B1D6
ACTIVITY_FG = 0xE0AF68
ALERT_FG = 0xF7768E

ARROW = ""
ARROW_LEFT = ""
HOME = os.path.expanduser("~")


def _set(screen: Screen, fg: int, bg: int, bold: bool = False) -> None:
    screen.cursor.fg = as_rgb(fg)
    screen.cursor.bg = as_rgb(bg)
    screen.cursor.bold = bold


def _tab_bg(tab: TabBarData) -> int:
    return ACTIVE_BG if tab.is_active else INACTIVE_BG


def _short_path(path: str) -> str:
    if path == HOME or path.startswith(HOME + os.sep):
        path = "~" + path[len(HOME):]
    parts = path.split(os.sep)
    # deep paths keep the last two dirs so the tabs keep their room
    return path if len(path) <= 40 else os.sep.join(["…", *parts[-2:]])


def _reported_cwd(window) -> str:
    raw = window.screen.last_reported_cwd
    if not raw:
        return ""
    cwd = raw.decode("utf-8", "replace") if isinstance(raw, bytes) else str(raw)
    # osc 7 sends file://host/path, keep the path
    if cwd.startswith("file://"):
        cwd = "/" + cwd[len("file://"):].partition("/")[2]
    return unquote(cwd)


def _active_cwd(tab: TabBarData) -> str:
    kitty_tab = get_boss().tab_for_id(tab.tab_id)
    window = kitty_tab.active_window if kitty_tab else None
    if window is None:
        return ""
    # shell-reported cwd first, oldest process beats a child like an lsp server
    cwd = _reported_cwd(window) or window.get_cwd_of_child(oldest=True)
    return _short_path(cwd) if cwd else ""


def _draw_session(screen: Screen, tab: TabBarData) -> None:
    name = tab.session_name
    if not name:
        return
    _set(screen, DARK, SESSION_BG, bold=True)
    screen.draw(f" {name} ")
    _set(screen, SESSION_BG, _tab_bg(tab))
    screen.draw(ARROW)


def _draw_right(screen: Screen, draw_data: DrawData, tab: TabBarData) -> None:
    text = _active_cwd(tab)
    if not text:
        return
    width = len(text) + 3
    start = screen.columns - width
    # no room left of the tabs, skip rather than overdraw them
    if start <= screen.cursor.x + 1:
        return
    screen.cursor.x = start
    _set(screen, INACTIVE_BG, color_as_int(draw_data.default_bg))
    screen.draw(ARROW_LEFT)
    _set(screen, PATH_FG, INACTIVE_BG)
    screen.draw(f" {text} ")


def draw_tab(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_tab_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
) -> int:
    if index == 1:
        _draw_session(screen, tab)

    bg = _tab_bg(tab)
    fg = DARK if tab.is_active else INACTIVE_FG
    marks = ""
    if tab.layout_name == "stack" and tab.num_windows > 1:
        marks += " ⤢"
    title = tab.title
    room = max(1, max_tab_length - len(str(index)) - len(marks) - 5)
    if len(title) > room:
        title = title[: room - 1] + "…"

    _set(screen, fg, bg, bold=tab.is_active)
    screen.draw(f" {index} {title}{marks}")
    if tab.needs_attention:
        _set(screen, ALERT_FG, bg, bold=True)
        screen.draw(" !")
    elif tab.has_activity_since_last_focus and not tab.is_active:
        _set(screen, ACTIVITY_FG, bg)
        screen.draw(" ●")
    _set(screen, fg, bg)
    screen.draw(" ")

    next_tab = extra_data.next_tab
    next_bg = _tab_bg(next_tab) if next_tab and not is_last else color_as_int(draw_data.default_bg)
    _set(screen, bg, next_bg)
    screen.draw(ARROW)
    end = screen.cursor.x

    if is_last:
        _draw_right(screen, draw_data, tab)
    return end
