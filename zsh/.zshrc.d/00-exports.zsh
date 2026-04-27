# Cross-platform PATH and environment exports
# OS-specific paths live in os.darwin/ and os.linux/

export PATH="$HOME/.cargo/bin:$PATH"

export GOBIN="$HOME/.local/bin"
export PATH="$GOBIN:$PATH"

export PATH="$HOME/.bun/bin:$PATH"

export PATH="${PATH}:${HOME}/.local/bin/"

export PATH="$HOME/htb/tools:$PATH"

export EDITOR="nvim"
export VISUAL="nvim"
