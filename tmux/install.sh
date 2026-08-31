#!/usr/bin/env bash

set -e

echo "Setting up tmux configuration..."

ln -sf "${DOTFILES_LOCATION}/tmux/.tmux.conf" "${HOME}/.tmux.conf"

if ! command -v tmux >/dev/null 2>&1; then
  echo "⚠️  tmux binary not found in PATH."
  echo "To install tmux, run: sudo apt install tmux (or brew install tmux on macOS)"
else
  echo "✅ tmux configuration linked successfully to ~/.tmux.conf."
fi
