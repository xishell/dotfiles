# tokyo-night-tmux status bar, rebuilt for kitty from the plugin's own formats
import os

from kitty.boss import get_boss
from kitty.fast_data_types import Screen
from kitty.tab_bar import DrawData, ExtraData, TabBarData, as_rgb

# tokyo-night-tmux night palette
BG = 0x1A1B26
FG = 0xA9B1D6
BLUE = 0x7AA2F7
GREEN = 0x73DACA
YELLOW = 0xE0AF68
BBLACK = 0x2A2F41
BRIGHT_WHITE = 0xC0CAF5

SESSION_IDLE = "\U000f0902"
SESSION_PREFIX = "\U000f0820"
TAB_ICON = ""
ACTIVE_TAB_ICON = ""
LAST_TAB = "\U000f006f"
PATH_ICON = ""
# @tokyo-night-tmux_window_id_style dsquare, pane ids in the default hsquare
DSQUARE = "\U000f03a2\U000f03a5\U000f03a8\U000f03ab\U000f03b2\U000f03af\U000f03b4\U000f03b7\U000f03ba\U000f03bd"
HSQUARE = "\U000f03a3\U000f03a6\U000f03a9\U000f03ac\U000f03ae\U000f03b0\U000f03b5\U000f03b8\U000f03bb\U000f03be"

PREFIX_MODE = "prefix"
HOME = os.path.expanduser("~")


def _set(screen: Screen, fg: int, bg: int, bold: bool = False, dim: bool = False) -> None:
    screen.cursor.fg = as_rgb(fg)
    screen.cursor.bg = as_rgb(bg)
    screen.cursor.bold = bold
    screen.cursor.dim = dim


def _number(n: int, digits: str) -> str:
    # custom-number.sh puts a space after every digit glyph
    return "".join(digits[int(d)] + " " for d in str(n))


def _kitty_tab(tab: TabBarData):
    return get_boss().tab_for_id(tab.tab_id)


def _pane_index(tab: TabBarData) -> int:
    kitty_tab = _kitty_tab(tab)
    return kitty_tab.windows.active_group_idx + 1 if kitty_tab else 1


def _is_last_tab(tab: TabBarData) -> bool:
    manager = get_boss().os_window_map.get(tab.os_window_id)
    history = manager.active_tab_history if manager else None
    return bool(history) and history[-1] == tab.tab_id


def _prefix_held() -> bool:
    mappings = getattr(get_boss(), "mappings", None)
    return getattr(mappings, "current_keyboard_mode_name", "") == PREFIX_MODE


def _reported_cwd(window) -> str:
    raw = window.screen.last_reported_cwd
    if not raw:
        return ""
    cwd = raw.decode("utf-8", "replace") if isinstance(raw, bytes) else str(raw)
    # osc 7 sends file://host/path, keep the path
    if cwd.startswith("file://"):
        cwd = "/" + cwd[len("file://"):].partition("/")[2]
    from urllib.parse import unquote
    return unquote(cwd)


def _active_cwd(tab: TabBarData) -> str:
    kitty_tab = _kitty_tab(tab)
    window = kitty_tab.active_window if kitty_tab else None
    if window is None:
        return ""
    # shell-reported cwd first, oldest process beats a child like an lsp server
    cwd = _reported_cwd(window) or window.get_cwd_of_child(oldest=True) or ""
    # path_format relative only swaps $HOME for ~
    return cwd.replace(HOME, "~", 1) if cwd.startswith(HOME) else cwd


def _draw_session(screen: Screen, tab: TabBarData) -> None:
    if not tab.session_name:
        return
    _set(screen, BBLACK, BLUE, bold=True)
    screen.draw(" ")
    if _prefix_held():
        screen.draw(SESSION_PREFIX + " ")
    else:
        _set(screen, BBLACK, BLUE, bold=True, dim=True)
        screen.draw(SESSION_IDLE + " ")
        _set(screen, BBLACK, BLUE, bold=True)
    screen.draw(tab.session_name + " ")


def _draw_right(screen: Screen, tab: TabBarData) -> None:
    path = _active_cwd(tab)
    if not path:
        return
    width = len(path) + 5
    start = screen.columns - width
    # no room left of the tabs, skip rather than overdraw them
    if start <= screen.cursor.x + 1:
        return
    screen.cursor.x = start
    _set(screen, BLUE, BG)
    screen.draw("░ " + PATH_ICON + " ")
    _set(screen, BRIGHT_WHITE, BG)
    screen.draw(path + " ")


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

    zoomed = tab.layout_name == "stack" and tab.num_windows > 1
    pane = _number(_pane_index(tab), DSQUARE if zoomed else HSQUARE)
    title = tab.title
    room = max(1, max_tab_length - 12)
    if len(title) > room:
        title = title[: room - 1] + "…"

    if tab.is_active:
        _set(screen, GREEN, BBLACK)
        screen.draw(" " + ACTIVE_TAB_ICON + "  ")
        _set(screen, FG, BBLACK, bold=True)
        screen.draw(_number(index, DSQUARE) + title)
        _set(screen, FG, BBLACK)
        screen.draw(" " + pane + " ")
    else:
        _set(screen, FG, BG)
        screen.draw(" " + TAB_ICON + "  " + _number(index, DSQUARE) + title)
        _set(screen, FG, BG, dim=True)
        screen.draw(" " + pane)
        _set(screen, YELLOW, BG, dim=True)
        screen.draw(LAST_TAB + "  " if _is_last_tab(tab) else " ")
    end = screen.cursor.x

    if is_last:
        _draw_right(screen, tab)
    return end
