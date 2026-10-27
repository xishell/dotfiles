# macOS-specific PATH and environment

# Homebrew (Apple Silicon)
export PATH="$PATH:/opt/homebrew/bin"

# Homebrew Ruby + gem-installed binaries (evil-winrm etc)
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
# glob the newest gems bin so a ruby version bump doesn't strand gem executables
_gembin=(/opt/homebrew/lib/ruby/gems/*/bin(Nn))
(( ${#_gembin} )) && export PATH="${_gembin[-1]}:$PATH"
unset _gembin

# Homebrew Postgres
export PATH="/opt/homebrew/opt/postgresql@18/bin:$PATH"

# Java (uses macOS java_home helper)
export JAVA_HOME=$(/usr/libexec/java_home)
export PATH="$JAVA_HOME/bin:$PATH"

# .NET global tools (ilspycmd etc.)
export PATH="$PATH:$HOME/.dotnet/tools"

# STM32CubeMX for stm32 cmake toolchains
export STM32CubeMX_PATH=/Applications/STMicroelectronics/STM32CubeMX.app/Contents/Resources
