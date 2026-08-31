#!/usr/bin/env bash

set -e

echo "Setting up Bash configuration..."

ln -sf "${DOTFILES_LOCATION}/bash/.bashrc" "${HOME}/.bashrc"

echo "✅ Bash configuration linked successfully to ~/.bashrc."
