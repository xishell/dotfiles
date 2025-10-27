# Keep this tiny; affects ALL zsh invocations
export ZDOTDIR="$HOME/.config/zsh"

: ${XDG_CACHE_HOME:=$HOME/.cache}
: ${XDG_DATA_HOME:=$HOME/.local/share}
export ZSH_CACHE_DIR="$XDG_CACHE_HOME/zsh"
