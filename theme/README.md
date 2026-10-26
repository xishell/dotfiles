# theme: Hearth

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
| `{{ orange }}` / `{{ orange \| hex }}` | `#ff9a4f` |
| `{{ orange \| bare }}` | `ff9a4f` |
| `{{ orange \| hexa:f2 }}` | `#ff9a4ff2` |
| `{{ orange \| rgb }}` | `255, 154, 79` |
| `{{ orange \| rgba:0.4 }}` | `rgba(255, 154, 79, 0.4)` |
| `{{ orange \| hypr }}` | `rgb(ff9a4f)` (Hyprland) |
| `{{ orange \| hypr:ee }}` | `rgba(ff9a4fee)` |
| `{{ green \| mix:base:0.2 }}` | green laid over base at 20 % (tints the palette lacks) |
| `{{ meta.name }}` | plain string from `[meta]` |

Tokens: everything under `[colors]` (`crust` … `blue`) and `[ansi]` (`color0` … `color15`).
`primary` is the one solid focus colour (active workspace, cursor, selection, matches,
couch chip); `orange` is for numbers and the warm end of the focus gradient.

## Accent check

`[check]` in `palette.toml` lists the accents and the floor each must clear against
`against` (bg1): WCAG contrast `min_contrast` and CIE LCh(uv) chroma `min_chroma`.
If any accent fails, `ember-gen` names it and writes nothing, so no washed-out or
low-contrast colour ships.

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
