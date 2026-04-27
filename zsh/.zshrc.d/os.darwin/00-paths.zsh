# macOS-specific PATH and environment

# Homebrew (Apple Silicon)
export PATH="$PATH:/opt/homebrew/bin"

# Homebrew Ruby
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export PATH="/opt/homebrew/lib/ruby/gems/3.4.0/bin:$PATH"

# Homebrew Postgres
export PATH="/opt/homebrew/opt/postgresql@18/bin:$PATH"

# Java (uses macOS java_home helper)
export JAVA_HOME=$(/usr/libexec/java_home)
export PATH="$JAVA_HOME/bin:$PATH"
