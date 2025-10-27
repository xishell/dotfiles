# Initialize direnv before instant prompt
eval "$(direnv hook zsh)"

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-$USER.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-$USER.zsh"
fi

# Exports
export PATH="$PATH:/opt/homebrew/bin"
# Add Homebrew Ruby to PATH
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export PATH="/opt/homebrew/lib/ruby/gems/3.4.0/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export JAVA_HOME=$(/usr/libexec/java_home)
export PATH="$JAVA_HOME/bin:$PATH"
export GOBIN="$HOME/.local/bin"
export PATH="$GOBIN:$PATH"
export EDITOR="nvim"
# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ] && command -v git >/dev/null 2>&1; then
   mkdir -p "$(dirname "$ZINIT_HOME")"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
if [ -s "${ZINIT_HOME}/zinit.zsh" ]; then
  source "${ZINIT_HOME}/zinit.zsh"
fi

# Add in powerlevel10k
zinit ice depth=1; zinit light romkatv/powerlevel10k

#eval "$(oh-my-posh init zsh --config $HOME/.config/ohmyposh/zen.toml)"
export PATH="${PATH}:${HOME}/.local/bin/"
# Add in zsh plugins (ensure highlighting loads last)
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab
zinit light zsh-users/zsh-syntax-highlighting

# Add in snippets
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::command-not-found

# Ensure HTB script is discoverable
export PATH="$HOME/htb/tools:$PATH"

# Add homebrew completions to fpath (must be before compinit)
if type brew &>/dev/null; then
  fpath=(/opt/homebrew/share/zsh/site-functions $fpath)
fi

# Add custom completions to fpath BEFORE compinit
fpath=($HOME/htb/completions $fpath)

# Load completions (use cached compdump when possible)
autoload -Uz compinit && compinit

# Register htb completion mapping after compinit
autoload -Uz _htb 2>/dev/null && compdef _htb htb

# Let zinit replay its queued completions AFTER compinit
zinit cdreplay -q

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

setopt EXTENDED_GLOB
# Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --color=always --icons=always $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza --color=always --icons=always $realpath'

# Aliases

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

alias ls="eza -G --classify=auto --color=always --icons=always"
alias lst="eza -GT --classify=auto --color=always --icons=always"
alias la="eza -Gla --classify=auto --color=always --icons=always"
alias lat="eza -GlaT --classify=auto --color=always --icons=always"
alias vim="nvim"
alias lg="lazygit"
alias nvx='NVIM_APPNAME=nvimx nvim'
alias cat="bat --paging=never"
alias find="fd"
# dotfile aliases
alias zrc="vim ~/dotfiles/zsh/.zshrc"
alias orc="source ~/.zshrc"

# git aliases
alias gs="git status --short"
alias gl="git log --graph --all --pretty=format:'%C(magenta)%h %C(white) %an  %ar%C(auto)  %D%n%s%n'"

# mac specific aliases
alias cf="caffeinate"

# IP aliases
alias vpnip='ifconfig | grep -A 2 "utun" | grep "inet " | awk "{print \$2}" | grep -v "127\." | tail -1'  # generic VPN IP
alias htbip='ifconfig | grep -A 2 "utun" | grep "inet " | grep "10\.10\." | awk "{print \$2}" | head -1'  # HTB specific
alias htbipc='htbip | pbcopy && htbip'
alias myip="curl -s ifconfig.me"
alias localip="ipconfig getifaddr en0"

# System
alias brewup="brew update && brew upgrade && brew cleanup"
alias ports="lsof -i -P -n | grep LISTEN"
alias wx="curl 'wttr.in/?M'"

# Auto run Todo app
function show_git_todos() {
  if git rev-parse --show-toplevel >/dev/null 2>&1; then
    local root
    root=$(git rev-parse --show-toplevel 2>/dev/null)
    local reponame
    reponame=$(basename "$root")
    if [[ -f "$root/todos.json" ]]; then
      echo "📋 Todos for repo: $reponame"
      godo --list "$root/todos.json"
      echo
    fi
  fi
}

autoload -U add-zsh-hook
add-zsh-hook chpwd show_git_todos

show_git_todos

# use y with yazi
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# Shell integrations
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"

# Auto-start tmux
if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
    exec tmux
fi
