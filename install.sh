#!/bin/bash
#
# Minimal install for a server/VM: zsh, fzf (ctrl-r history search), and
# Neovim. No Homebrew, no curl-pipe-bash installers, no third-party prompt
# engine — everything here is either an Ubuntu apt package or a versioned
# tarball straight from the upstream project's GitHub releases.

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DEBIAN_FRONTEND=noninteractive

install_apt_if_missing() {
    local package="$1"
    local command_name="${2:-$1}"

    if ! command -v "$command_name" >/dev/null 2>&1; then
        echo "Installing ${package}..."
        sudo apt install -y "$package"
    fi
}

echo "Updating apt and installing base dependencies..."
sudo apt update
# gcc + make: LazyVim's treesitter parsers compile from source on :TSUpdate,
# and some Mason-installed tools need a compiler too (see commit "required
# compilers" on ubuntu_core). Not the full build-essential meta-package —
# just the two binaries treesitter actually needs.
sudo apt install -y unzip stow curl git tree gcc make

# Install Zsh
install_apt_if_missing zsh

# Check current default shell
CURRENT_SHELL=$(getent passwd "$USER" | cut -d: -f7)
ZSH_PATH=$(command -v zsh)
if [[ "$CURRENT_SHELL" != "$ZSH_PATH" ]]; then
    echo "Setting Zsh as default shell..."
    chsh -s "$ZSH_PATH"
else
    echo "Zsh is already the default shell."
fi

# fzf — Ubuntu's apt package, not Homebrew. Ships shell integration examples
# (including the key-bindings script .zshrc sources for ctrl-r) at
# /usr/share/doc/fzf/examples/.
install_apt_if_missing fzf

# Neovim — Ubuntu's apt package lags well behind upstream releases, and this
# LazyVim config wants a current version. Installing the official prebuilt
# binary instead of adding a PPA or Homebrew: this is a plain tarball
# download and extract, not a script being executed, so it doesn't carry the
# curl-pipe-bash risk the old install.sh had for Homebrew/oh-my-posh.
if ! command -v nvim >/dev/null 2>&1; then
    echo "Installing Neovim..."
    # Pinned to a specific release rather than "latest" so this install is
    # reproducible — bump this URL to a newer tag when you want to upgrade.
    NVIM_VERSION="v0.10.2"
    curl -fsSL -o /tmp/nvim-linux-x86_64.tar.gz \
        "https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux-x86_64.tar.gz"
    sudo rm -rf /opt/nvim
    sudo tar -C /opt -xzf /tmp/nvim-linux-x86_64.tar.gz
    sudo mv /opt/nvim-linux-x86_64 /opt/nvim
    sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim
    rm /tmp/nvim-linux-x86_64.tar.gz
fi

# Stow dotfiles
cd "$DOTFILES_DIR"
stow -t ~ zsh nvim

echo "Done! Restart your shell or log out and back in."
