# latexmk

Global `.latexmkrc` that keeps build artefacts out of the source tree and runs
Biber automatically.

Outputs are split:

```
project/
├── main.tex
└── build/
    ├── aux/   # .aux .log .bcf .bbl …
    └── out/   # .pdf .synctex.gz
```

`-auxdir` / `-outdir` on the command line override the defaults. VimTeX picks
up the same config without further setup.

## Engines

`pdflatex` is the default. `lualatex` and `xelatex` are defined as `$lualatex` /
`$xelatex` — switch by setting `$pdf_mode = 4` or `5`. A Tectonic command line
is included but commented out.

Shell-escape variants are commented at the bottom of the rc; uncomment if a
package needs it.

## Biber

The rc registers a `bcf → bbl` custom dependency that calls Biber with
`--input-directory` / `--output-directory` pointed at `$aux_dir`. This is
needed because latexmk's `emulate-aux-dir` mode expects the `.bbl` in the aux
dir, not next to the source.

Set `LATEXMK_DEBUG=1` to print the Biber command and paths before each run.

## Install

```sh
stow latexmk       # from ~/dotfiles
```

Symlinks `.latexmkrc` into `$HOME`. Biber ships with most TeX Live installs;
otherwise `tlmgr install biber`.

## Usage

```sh
latexmk document.tex                        # build
latexmk -auxdir=custom/aux -outdir=out doc  # override dirs
latexmk -c                                  # clean aux
latexmk -C                                  # clean aux + pdf
LATEXMK_DEBUG=1 latexmk document.tex        # trace Biber
```
