# Cross-platform PATH and environment exports
# OS-specific paths live in os.darwin/ and os.linux/

export PATH="$HOME/.cargo/bin:$PATH"

export GOBIN="$HOME/.local/bin"
export PATH="$GOBIN:$PATH"

export PATH="$HOME/.bun/bin:$PATH"

export PATH="${PATH}:${HOME}/.local/bin/"

export EDITOR="nvim"
export VISUAL="nvim"

# syntax-highlight man pages via bat, col strips backspace overstrike
# plain style keeps the man look, paging=always routes through less for mouse scroll
export MANPAGER="sh -c 'col -bx | bat -l man --style=plain --paging=always'"
export MANROFFOPT="-c"
# bat pager, --mouse enables wheel scroll (shift/option-drag to select text)
export BAT_PAGER="less -R --mouse --wheel-lines=3"
