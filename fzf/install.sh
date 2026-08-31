#!/usr/bin/env bash

set -e

echo "Setting up fzf..."

if ! command -v fzf >/dev/null 2>&1; then
  echo "⚠️  fzf binary not found in PATH."
  echo "Installing fzf via git or package manager..."
  if command -v apt-get >/dev/null 2>&1; then
    echo "Run: sudo apt-get install fzf"
  elif command -v brew >/dev/null 2>&1; then
    echo "Run: brew install fzf"
  else
    echo "Run: git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install"
  fi
else
  echo "✅ fzf is installed ($(fzf --version)). Shell integration is configured in shell dotfiles."
fi
