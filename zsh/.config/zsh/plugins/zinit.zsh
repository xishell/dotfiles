# Bootstrap zinit (zdharma-continuum)
if [[ ! -f ${XDG_DATA_HOME:-$HOME/.local/share}/zinit/bin/zinit.zsh ]]; then
    mkdir -p "${XDG_DATA_HOME:-$HOME/.local/share}/zinit" &&
        git clone --depth=1 https://github.com/zdharma-continuum/zinit.git \
            "${XDG_DATA_HOME:-$HOME/.local/share}/zinit/bin" >/dev/null 2>&1
fi
source "${XDG_DATA_HOME:-$HOME/.local/share}/zinit/bin/zinit.zsh"

# Caches and sensible timeouts
ZINIT[work_dir]="$ZSH_CACHE_DIR/zinit"
ZINIT[subscribe_timeout]=3

# Compinit support helpers available after first plugin load
autoload -Uz compinit
