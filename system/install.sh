#!/usr/bin/env bash
# Root-owned config for this machine, kept as a mirror of / (etc/, usr/).
# Stow can't own these (root files, PAM must be real files), so they are copied.
#
#   system/install.sh           show which files differ from the live system (no changes)
#   system/install.sh --apply   copy them into place with sudo, then reload what they affect
#   system/install.sh --pull    copy the live files back into the repo (after editing in /etc)
#
# PAM files (etc/pam.d) gate sudo and login: keep a root shell open when applying a
# changed one, so a mistake can be undone.
set -euo pipefail
cd "$(dirname "$0")"

mapfile -t files < <(find etc usr -type f | sort)
changed=()
for f in "${files[@]}"; do
    if ! cmp -s "$f" "/$f" 2>/dev/null; then changed+=("$f"); fi
done

case "${1:-}" in
"")
    if [ ${#changed[@]} -eq 0 ]; then echo "all ${#files[@]} files match the system"; exit 0; fi
    for f in "${changed[@]}"; do
        if [ -e "/$f" ]; then diff -u "/$f" "$f" || true; else echo "new: /$f"; fi
    done
    echo "${#changed[@]} file(s) differ; run with --apply to install them"
    ;;
--apply)
    [ ${#changed[@]} -eq 0 ] && { echo "nothing to do"; exit 0; }
    for f in "${changed[@]}"; do
        mode=$(stat -c %a "$f")
        sudo install -D -m "$mode" -o root -g root "$f" "/$f"
        echo "installed /$f"
    done
    printf '%s\n' "${changed[@]}" | grep -q '^etc/udev/' && sudo udevadm control --reload && sudo udevadm trigger
    printf '%s\n' "${changed[@]}" | grep -q '^etc/systemd/' && sudo systemctl daemon-reload
    if printf '%s\n' "${changed[@]}" | grep -q -E '^etc/(modprobe.d|default/limine)'; then
        echo "kernel modules or cmdline changed: run 'sudo limine-update' and reboot"
    fi
    ;;
--pull)
    for f in "${files[@]}"; do cp -p "/$f" "$f"; done
    echo "pulled ${#files[@]} files from the system"
    ;;
*)
    echo "usage: system/install.sh [--apply|--pull]" >&2; exit 2 ;;
esac
