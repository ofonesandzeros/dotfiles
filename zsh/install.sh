#!/usr/bin/env bash

set -e

echo "Setting up Zsh configuration..."

ln -sf "${DOTFILES_LOCATION}/zsh/.zshrc" "${HOME}/.zshrc"

echo "✅ Zsh configuration linked successfully to ~/.zshrc."
