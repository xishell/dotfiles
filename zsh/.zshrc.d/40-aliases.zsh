# Cross-platform aliases
# OS-specific aliases live in os.darwin/40-aliases.zsh and os.linux/40-aliases.zsh

# Navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

# eza
alias ls="eza -G --classify=auto --color=auto --icons=auto"
alias lst="eza -GT --group-directories-first --git-ignore --classify=auto --color=auto --icons=auto"
alias la="eza -Gla --classify=auto --color=auto --icons=auto"
alias lat="eza -GTa --classify=auto --color=auto --icons=auto"

# Tools
alias vim="nvim"
alias lg="lazygit"
alias nvx='NVIM_APPNAME=nvimx nvim'
alias cat="bat --paging=never"
alias find="fd"

# Dotfiles
alias zrc="vim ~/dotfiles/zsh/.zshrc"
alias orc="source ~/.zshrc"

# Git
alias gs="git status --short"
alias gl="git log --graph --all --pretty=format:'%C(magenta)%h %C(white) %an  %ar%C(auto)  %D%n%s%n'"

# Public IP
alias myip="curl -s ifconfig.me"

# System
alias brewup="brew update && brew upgrade && brew cleanup"
alias ports="lsof -i -P -n | grep LISTEN"
alias wx="curl 'wttr.in/?M'"

alias python=python3
