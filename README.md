# Dotfiles

Personal dotfiles and environment configuration for a lightweight, modern terminal setup.

## Features

- **Tmux**: Sleek custom status bar with active/inactive window indicators and automatic pane renaming.
- **Starship**: Cross-shell prompt styled with Nerd Font symbol presets.
- **fzf**: Fast fuzzy finder shell integration for Bash and Zsh.
- **NvChad**: Blazing fast Neovim IDE setup with onedark theme, LSP, syntax highlighting, formatters, and custom keymaps (macOS & Linux).
- **Zsh & Bash**: Clean shell configurations with completion systems, history optimization, and tool integrations without heavy framework overhead.

## Directory Structure

```
.
├── bin/
│   └── dotfiles          # Package management CLI helper
├── nvim/
│   ├── init.lua          # Neovim & NvChad entrypoint
│   ├── lua/              # NvChad user configuration, mappings & plugins
│   └── install.sh        # Dependency resolver & symlinks to ~/.config/nvim
├── tmux/
│   ├── .tmux.conf        # Tmux styling & configuration
│   └── install.sh        # Symlinks .tmux.conf to ~/.tmux.conf
├── starship/
│   ├── starship.toml     # Starship prompt configuration
│   └── install.sh        # Symlinks starship.toml to ~/.config/starship.toml
├── fzf/
│   └── install.sh        # Verifies fzf installation and shell integration
├── zsh/
│   ├── .zshrc            # Modern Zsh configuration
│   └── install.sh        # Symlinks .zshrc to ~/.zshrc
├── bash/
│   ├── .bashrc           # Bash configuration with fzf & starship
│   └── install.sh        # Symlinks .bashrc to ~/.bashrc
├── install.sh            # Master installation script
└── README.md
```

## Installation

To install all dotfiles configurations:

```bash
./install.sh
```

Or install individual packages using the helper CLI:

```bash
./bin/dotfiles install nvim
./bin/dotfiles install tmux
./bin/dotfiles install starship
./bin/dotfiles install fzf
./bin/dotfiles install zsh
./bin/dotfiles install bash
```