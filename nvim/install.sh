#!/usr/bin/env bash

set -e

echo "Setting up NvChad Neovim configuration..."

if [ -z "${DOTFILES_LOCATION}" ]; then
  DOTFILES_LOCATION="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  export DOTFILES_LOCATION
fi

OS="$(uname -s)"
case "${OS}" in
  Darwin*)
    PLATFORM="macos"
    ;;
  Linux*)
    PLATFORM="linux"
    ;;
  *)
    echo "❌ Unsupported operating system: ${OS}."
    echo "NvChad installation is configured for macOS and Linux only."
    exit 1
    ;;
esac

echo "Platform detected: ${PLATFORM} (${OS})"

# Helper to compare semver versions
version_ge() {
  local v1="$1" v2="$2"
  if [ "$v1" = "$v2" ]; then return 0; fi
  local major1 minor1 patch1 major2 minor2 patch2
  IFS=. read -r major1 minor1 patch1 <<EOF
$v1
EOF
  IFS=. read -r major2 minor2 patch2 <<EOF
$v2
EOF
  major1="${major1:-0}"; minor1="${minor1:-0}"; patch1="${patch1:-0}"
  major2="${major2:-0}"; minor2="${minor2:-0}"; patch2="${patch2:-0}"

  if [ "$major1" -gt "$major2" ]; then return 0; fi
  if [ "$major1" -lt "$major2" ]; then return 1; fi
  if [ "$minor1" -gt "$minor2" ]; then return 0; fi
  if [ "$minor1" -lt "$minor2" ]; then return 1; fi
  if [ "$patch1" -ge "$patch2" ]; then return 0; fi
  return 1
}

get_nvim_version() {
  if ! command -v nvim >/dev/null 2>&1; then
    echo "0.0.0"
    return
  fi
  nvim --version | head -n 1 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -n 1
}

# 1. Dependency checks and installation
echo "Checking dependencies (Neovim >= 0.10, ripgrep, fd, make, C compiler)..."

SUDO=""
if [ "$(id -u)" -ne 0 ] && command -v sudo >/dev/null 2>&1; then
  SUDO="sudo"
fi

if [ "${PLATFORM}" = "macos" ]; then
  if ! command -v brew >/dev/null 2>&1; then
    echo "⚠️  Homebrew not found. Please install Homebrew from https://brew.sh or install dependencies manually."
  else
    NVIM_VER="$(get_nvim_version)"
    if ! command -v nvim >/dev/null 2>&1; then
      echo "📦 Installing Neovim via Homebrew..."
      brew install neovim
    elif ! version_ge "${NVIM_VER}" "0.10.0"; then
      echo "📦 Neovim version ${NVIM_VER} is < 0.10.0. Upgrading via Homebrew..."
      brew upgrade neovim
    fi

    if ! command -v rg >/dev/null 2>&1; then
      echo "📦 Installing ripgrep via Homebrew..."
      brew install ripgrep
    fi

    if ! command -v fd >/dev/null 2>&1; then
      echo "📦 Installing fd via Homebrew..."
      brew install fd
    fi

    if ! command -v make >/dev/null 2>&1; then
      echo "📦 Installing make via Homebrew..."
      brew install make
    fi
  fi
elif [ "${PLATFORM}" = "linux" ]; then
  NVIM_VER="$(get_nvim_version)"
  NEED_NVIM_INSTALL=false

  if ! command -v nvim >/dev/null 2>&1 || ! version_ge "${NVIM_VER}" "0.10.0"; then
    NEED_NVIM_INSTALL=true
  fi

  if command -v pacman >/dev/null 2>&1; then
    echo "📦 Arch Linux detected. Installing missing packages via pacman..."
    ${SUDO} pacman -S --needed --noconfirm neovim git ripgrep fd make gcc
    NEED_NVIM_INSTALL=false
  elif command -v dnf >/dev/null 2>&1; then
    echo "📦 Fedora/RHEL detected. Installing missing packages via dnf..."
    ${SUDO} dnf install -y neovim git ripgrep fd-find make gcc
    NEED_NVIM_INSTALL=false
  elif command -v apt-get >/dev/null 2>&1; then
    echo "📦 Debian/Ubuntu detected. Installing core dependencies via apt..."
    ${SUDO} apt-get update -y
    ${SUDO} apt-get install -y git ripgrep fd-find make gcc

    # Create fd alias if installed as fdfind
    if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
      mkdir -p "${HOME}/.local/bin"
      ln -sf "$(command -v fdfind)" "${HOME}/.local/bin/fd"
    fi
  fi

  if [ "${NEED_NVIM_INSTALL}" = true ]; then
    echo "📦 Fetching official Neovim binary release (>= 0.10) for Linux..."
    ARCH="$(uname -m)"
    TARBALL_NAME=""
    case "${ARCH}" in
      x86_64)
        TARBALL_NAME="nvim-linux-x86_64.tar.gz"
        ;;
      aarch64|arm64)
        TARBALL_NAME="nvim-linux-arm64.tar.gz"
        ;;
    esac

    if [ -n "${TARBALL_NAME}" ]; then
      TMP_DIR="$(mktemp -d)"
      curl -sSL "https://github.com/neovim/neovim/releases/latest/download/${TARBALL_NAME}" -o "${TMP_DIR}/${TARBALL_NAME}"
      mkdir -p "${HOME}/.local"
      tar -xzf "${TMP_DIR}/${TARBALL_NAME}" -C "${HOME}/.local" --strip-components=1
      rm -rf "${TMP_DIR}"
      export PATH="${HOME}/.local/bin:${PATH}"
      echo "✅ Neovim binary installed to ~/.local/bin/nvim"
    else
      echo "⚠️  Could not auto-download Neovim for architecture ${ARCH}. Please install Neovim >= 0.10.0 manually."
    fi
  fi
fi

# Final check for Neovim version
if command -v nvim >/dev/null 2>&1; then
  CURRENT_VER="$(get_nvim_version)"
  if version_ge "${CURRENT_VER}" "0.10.0"; then
    echo "✅ Neovim ${CURRENT_VER} is ready."
  else
    echo "⚠️  Neovim version ${CURRENT_VER} is installed, but NvChad requires >= 0.10.0."
  fi
else
  echo "⚠️  Neovim was not found in PATH."
fi

# 2. Backup previous Neovim share/state if switching from another setup (e.g. LazyVim)
if [ -d "${HOME}/.local/share/nvim/lazy" ] && [ ! -d "${HOME}/.local/share/nvim/lazy/NvChad" ]; then
  SHARE_BACKUP="${HOME}/.local/share/nvim.backup.$(date +%Y%m%d%H%M%S)"
  echo "📦 Detected plugin data from another Neovim distribution."
  echo "📦 Moving ~/.local/share/nvim to ${SHARE_BACKUP} to avoid plugin conflicts..."
  mv "${HOME}/.local/share/nvim" "${SHARE_BACKUP}"
fi

# 3. Safe configuration linking
NVIM_TARGET="${HOME}/.config/nvim"
DOTFILES_NVIM="${DOTFILES_LOCATION}/nvim"

mkdir -p "${HOME}/.config"

if [ -L "${NVIM_TARGET}" ]; then
  CURRENT_DEST="$(readlink "${NVIM_TARGET}" || true)"
  if [ "${CURRENT_DEST}" = "${DOTFILES_NVIM}" ]; then
    echo "✅ Neovim configuration is already linked to ${DOTFILES_NVIM}."
  else
    BACKUP_NAME="${NVIM_TARGET}.backup.$(date +%Y%m%d%H%M%S)"
    echo "📦 Backing up existing Neovim symlink to ${BACKUP_NAME}..."
    mv "${NVIM_TARGET}" "${BACKUP_NAME}"
    ln -s "${DOTFILES_NVIM}" "${NVIM_TARGET}"
    echo "✅ Linked ${DOTFILES_NVIM} to ${NVIM_TARGET}."
  fi
elif [ -d "${NVIM_TARGET}" ]; then
  BACKUP_NAME="${NVIM_TARGET}.backup.$(date +%Y%m%d%H%M%S)"
  echo "📦 Backing up existing Neovim configuration directory to ${BACKUP_NAME}..."
  mv "${NVIM_TARGET}" "${BACKUP_NAME}"
  ln -s "${DOTFILES_NVIM}" "${NVIM_TARGET}"
  echo "✅ Linked ${DOTFILES_NVIM} to ${NVIM_TARGET}."
else
  ln -s "${DOTFILES_NVIM}" "${NVIM_TARGET}"
  echo "✅ Linked ${DOTFILES_NVIM} to ${NVIM_TARGET}."
fi

echo ""
echo "✨ NvChad setup completed!"
echo "🚀 Run 'nvim' in your terminal to bootstrap lazy.nvim and install plugins automatically."
echo "💡 Make sure you use a Nerd Font in your terminal for icons to display properly."
