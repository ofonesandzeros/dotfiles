#!/usr/bin/env bash

set -e

echo "Setting up Starship prompt..."

mkdir -p "${HOME}/.config"

ln -sf "${DOTFILES_LOCATION}/starship/starship.toml" "${HOME}/.config/starship.toml"

if ! command -v starship >/dev/null 2>&1; then
  echo "⚠️  starship binary not found in PATH."
  echo "To install starship, visit https://starship.rs or run:"
  echo "  curl -sS https://starship.rs/install.sh | sh"
else
  echo "✅ Starship configured successfully."
fi
