# theme: Tokyo Night Ember

`palette.toml` is the only place a colour is written down. Every themed config in
this repo is generated from it by `gen/` (a small Rust tool), so a colour change is
one edit plus one command:

```sh
$EDITOR theme/palette.toml
theme/ember            # build + regenerate every consumer
theme/ember --check    # CI / pre-commit: fail if any output drifted from its template
```

Do not hand-edit hex in a generated file. Edit its template in `templates/`, or the
palette, and regenerate. Generated files are committed so a plain `stow` works
before Rust is installed.

## Files

```
theme/
├── palette.toml     # tokens ([colors]) + ANSI 16 ([ansi]) + [meta]
├── targets.toml     # template → output map
├── templates/       # one template per consumer, laid out by tool
├── gen/             # ember-gen (Rust, only depends on `toml`)
└── ember            # wrapper: cargo build --release, then run
```

## Templates

`{{ token }}` renders `#rrggbb`. Filters:

| placeholder | output |
|---|---|
| `{{ orange }}` / `{{ orange \| hex }}` | `#ff9e64` |
| `{{ orange \| bare }}` | `ff9e64` |
| `{{ orange \| hexa:f2 }}` | `#ff9e64f2` |
| `{{ orange \| rgb }}` | `255, 158, 100` |
| `{{ orange \| rgba:0.4 }}` | `rgba(255, 158, 100, 0.4)` |
| `{{ orange \| hypr }}` | `rgb(ff9e64)` (Hyprland) |
| `{{ orange \| hypr:ee }}` | `rgba(ff9e64ee)` |
| `{{ meta.name }}` | plain string from `[meta]` |

Tokens: everything under `[colors]` (`crust` … `blue`) and `[ansi]` (`color0` … `color15`).

## Targets

```toml
[[target]]
template = "hypr/palette.lua"                     # under theme/templates/
output   = "hypr/.config/hypr/modules/palette.lua" # repo-relative
comment  = "--"                                   # header comment prefix; "" = no header
region   = false
```

A whole-file target is overwritten. With `region = true`, only the block between
`<comment> ember:begin` and `<comment> ember:end` in a hand-maintained file is replaced.
That suits files where colour is a small part, like kitty's `tab_bar.py`, so the rest
of the file keeps being edited normally on either OS.
