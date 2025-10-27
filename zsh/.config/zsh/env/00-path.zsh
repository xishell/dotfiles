# macOS Homebrew + Java + Go-style bin
typeset -Ug path
# Homebrew first
path=(/opt/homebrew/bin $path)
# Java
export JAVA_HOME="$(
    /usr/libexec/java_home 2>/dev/null || printf ''
)"
if [[ -n "$JAVA_HOME" ]]; then
    path=("$JAVA_HOME/bin" $path)
fi
# Your local bin
export GOBIN="$HOME/.local/bin"
path=("$GOBIN" $path)

export PATH
