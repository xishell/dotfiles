# ollama agent has no RunAtLoad/KeepAlive, so start it on first use
function ollama() {
    if ! curl -sf -m 1 http://127.0.0.1:11434/ >/dev/null; then
        launchctl kickstart "gui/$(id -u)/io.steffensens.ollama"
        # serve takes a moment to bind, give up after ~10s
        for _ in {1..20}; do
            curl -sf -m 1 http://127.0.0.1:11434/ >/dev/null && break
            sleep 0.5
        done
    fi
    command ollama "$@"
}

# stays loaded, just stops the process until next ollama call
function ollama-stop() {
    launchctl kill TERM "gui/$(id -u)/io.steffensens.ollama"
}
