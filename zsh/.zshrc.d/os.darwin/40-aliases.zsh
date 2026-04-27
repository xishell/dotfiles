# macOS-specific aliases

alias cf="caffeinate"

# IP via ifconfig + utun (macOS VPN interface naming)
alias vpnip='ifconfig | grep -A 2 "utun" | grep "inet " | awk "{print \$2}" | grep -v "127\." | tail -1'
alias htbip='ifconfig | grep -A 2 "utun" | grep "inet " | grep "10\.10\." | awk "{print \$2}" | head -1'
alias htbipc='htbip | pbcopy && htbip'

alias localip="ipconfig getifaddr en0"
