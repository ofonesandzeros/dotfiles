#!/usr/bin/env bash

set -e

echo "Setting up Starship prompt..."

if [ -z "${DOTFILES_LOCATION}" ]; then
  DOTFILES_LOCATION="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  export DOTFILES_LOCATION
fi

# Ensure Homebrew is in PATH on macOS if present
if [ -x "/opt/homebrew/bin/brew" ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x "/usr/local/bin/brew" ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

mkdir -p "${HOME}/.config"

ln -sf "${DOTFILES_LOCATION}/starship/starship.toml" "${HOME}/.config/starship.toml"

if ! command -v starship >/dev/null 2>&1; then
  OS="$(uname -s)"
  if [ "${OS}" = "Darwin" ] && command -v brew >/dev/null 2>&1; then
    echo "📦 Installing Starship via Homebrew..."
    brew install starship
  else
    echo "⚠️  starship binary not found in PATH."
    echo "To install starship, visit https://starship.rs or run:"
    echo "  curl -sS https://starship.rs/install.sh | sh"
  fi
fi

if command -v starship >/dev/null 2>&1; then
  echo "✅ Starship configured successfully ($(starship --version | head -n 1))."
fi
