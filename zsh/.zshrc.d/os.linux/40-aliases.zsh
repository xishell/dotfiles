# Linux-specific aliases / functions

# Clipboard: prefer wl-copy (Wayland), fall back to xclip (X11)
if command -v wl-copy >/dev/null 2>&1; then
    alias clip='wl-copy'
elif command -v xclip >/dev/null 2>&1; then
    alias clip='xclip -selection clipboard'
fi

# IP via `ip` — functions for cleaner quoting than aliases
vpnip()  { ip -4 -o addr show 2>/dev/null | awk '/tun[0-9]+/ {split($4,a,"/"); print a[1]; exit}'; }
htbip()  { ip -4 -o addr show 2>/dev/null | awk '/tun[0-9]+/ && /10\.10\./ {split($4,a,"/"); print a[1]; exit}'; }
htbipc() { local ip; ip="$(htbip)"; [ -n "$ip" ] && printf '%s' "$ip" | clip; printf '%s\n' "$ip"; }
localip() { ip route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="src"){print $(i+1); exit}}'; }
