# verimark

Kensington VeriMark Desktop (`047d:00f2`) on Linux. Stock libfprint doesn't support it: this builds a patched libfprint with the `synatlsmoc` driver and points fprintd at it.

Used by: sudo, polkit, greetd (`pam_fprintd`), hyprlock.

## Install

```sh
cd ~/.local/share/verimark
./build.sh          # as user: clone pinned source, verify + apply patches → dist/
sudo ./install.sh   # copy lib, fprintd drop-in, udev rule
sudo fprintd-enroll elliot   # first open pairs the reader with this OS
fprintd-verify
```

Build output (`src/`, `dist/`) lands in `~/.local/share/verimark/`, outside the repo. `./build.sh --clean` rebuilds from scratch.

## Manage

```sh
sudo ./install.sh --status      # what's installed / paired
sudo ./install.sh --uninstall   # back to stock libfprint (keeps pairing)
sudo ./install.sh --purge       # also delete pairing
```

## Installed paths

| Path | What |
|---|---|
| `/usr/local/lib64/verimark-synatlsmoc/` | patched `libfprint-2.so` |
| `/etc/systemd/system/fprintd.service.d/10-verimark-synatlsmoc.conf` | `LD_LIBRARY_PATH` + pairing file for fprintd |
| `/var/lib/fprint/verimark/047d-00f2/libfprint-persistent.bin` | pairing keys (root, 0600) |
| `/usr/lib/udev/rules.d/60-verimark.rules` | device access |

## Files

| File | What |
|---|---|
| `versions.env` | pinned upstream commit, patch checksum, expected trees |
| `0001-Add-Kensington-…patch` | Kensington match-in-sensor support (Uriziel01) |
| `0002-verimark-self-pairing.patch` | local: pair on first open, persist keys |
| `0003-synatlsmoc-rearm-finger-wait.patch` | local: re-arm the 60 s finger wait instead of failing (hyprlock lost fingerprint after 1 min) |
| `60-verimark.rules` | udev rule |

Base: `vojtapl/synaTudorMiS` @ `5452637`. `build.sh` refuses to build if a patch or the resulting tree doesn't match.

## Gotchas

- **Pairing is exclusive.** Pairing on Linux replaces Windows Hello's pairing, and the other way round. If Windows re-pairs: `--purge`, reinstall, re-enroll.
- **Enroll with sudo** (`sudo fprintd-enroll <user>`) from shells without a polkit agent.
