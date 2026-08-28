#!/usr/bin/env bash

set -e

###
# Installation of packages, configurations, and dotfiles.
###
DOTFILES_LOCATION="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES_LOCATION

###
# Install components
###
./bin/dotfiles install tmux
./bin/dotfiles install starship
./bin/dotfiles install fzf
./bin/dotfiles install zsh
./bin/dotfiles install bash

echo "✨ All dotfiles configurations installed successfully!"
