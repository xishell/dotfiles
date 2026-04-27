# Linux-specific PATH and environment

# Java — prefer Arch's archlinux-java helper, fall back to /usr/lib/jvm/default
if command -v archlinux-java >/dev/null 2>&1; then
    _java_default="$(archlinux-java get 2>/dev/null)"
    [ -n "$_java_default" ] && export JAVA_HOME="/usr/lib/jvm/$_java_default"
    unset _java_default
elif [ -d /usr/lib/jvm/default ]; then
    export JAVA_HOME="/usr/lib/jvm/default"
fi
[ -n "$JAVA_HOME" ] && export PATH="$JAVA_HOME/bin:$PATH"

# Linuxbrew — uncomment if installed
# eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
