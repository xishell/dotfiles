# LaTeX Build Configuration

Global latexmk configuration for efficient LaTeX document compilation with VimTeX integration.

## Features

- **Clean builds**: Separates auxiliary and output files into `build/` directories
- **Biber integration**: Automatic bibliography processing with proper directory handling
- **Multi-engine support**: pdfLaTeX, LuaLaTeX, XeLaTeX with consistent settings
- **VimTeX compatible**: Seamless integration with Neovim LaTeX editing

## Directory Structure

```
project/
├── main.tex
├── build/
│   ├── aux/          # Auxiliary files (.aux, .log, etc.)
│   └── out/          # Output files (.pdf, .synctex.gz)
```

## Build Engines

- **Default**: pdfLaTeX with SyncTeX
- **Alternative**: LuaLaTeX, XeLaTeX (uncomment in config)
- **Modern**: Tectonic support (commented, requires installation)

## Key Features

- **Robustness**: Up to 8 compilation passes for complex cross-references
- **Dependency tracking**: `$recorder = 1` for optimal rebuilds
- **Comprehensive cleaning**: Removes all auxiliary files automatically
- **Debug output**: Conditional Biber logging (set `LATEXMK_DEBUG=1`)

## Usage

### With VimTeX
Configuration automatically detected by VimTeX plugin.

### Command Line
```bash
# Basic compilation
latexmk document.tex

# Custom directories
latexmk -auxdir=custom/aux -outdir=custom/out document.tex

# Clean build files
latexmk -c

# Enable debug output
LATEXMK_DEBUG=1 latexmk document.tex
```

## Installation

1. Symlink config: `ln -sf ~/dotfiles/latexmk/.latexmkrc ~/.latexmkrc`
2. Ensure Biber is installed: `tlmgr install biber`
3. For VimTeX: Configure Neovim with vimtex plugin

## Troubleshooting

- **Biber issues**: Check `.bcf` files in aux directory
- **Missing fonts**: Use LuaLaTeX or XeLaTeX for system fonts
- **Shell escape**: Uncomment shell-escape lines for packages requiring it