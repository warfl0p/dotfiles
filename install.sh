#!/bin/bash

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

apt_has_package() {
    apt-cache show "$1" >/dev/null 2>&1
}

echo "Updating apt and installing base dependencies..."
sudo apt update
sudo apt install -y unzip stow curl git tmux tree

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

# Install Homebrew
if ! command -v brew >/dev/null 2>&1; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    if ! grep -Fq 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' "$HOME/.zshrc" 2>/dev/null; then
        echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> "$HOME/.zshrc"
    fi
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Install oh-my-posh
if ! command -v oh-my-posh >/dev/null 2>&1; then
    mkdir -p "$HOME/bin"
    export PATH="$PATH:$HOME/bin"
    curl -s https://ohmyposh.dev/install.sh | bash -s -- -d "$HOME/bin"
    oh-my-posh font install meslo
fi

# Install Tmux + Catppuccin theme
CATPUCCIN_DIR="$HOME/.config/tmux/plugins/catppuccin/tmux"
if [ ! -d "$CATPUCCIN_DIR" ]; then
    mkdir -p "$(dirname "$CATPUCCIN_DIR")"
    git clone -b v2.1.3 https://github.com/catppuccin/tmux.git "$CATPUCCIN_DIR"
fi

if apt_has_package fd-find; then
    install_apt_if_missing fd-find fdfind
fi

# Install Homebrew packages
brew install uv
brew install television
brew install fzf
brew install neovim
brew install sesh

# fzf-tab plugin
FZF_TAB_DIR="$HOME/.zsh_plugins/fzf-tab"
if [ ! -d "$FZF_TAB_DIR" ]; then
    mkdir -p "$HOME/.zsh_plugins"
    git clone https://github.com/Aloxaf/fzf-tab "$FZF_TAB_DIR"
fi

# Install TPM (Tmux Plugin Manager)
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [ ! -d "$TPM_DIR" ]; then
    mkdir -p "$(dirname "$TPM_DIR")"
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi

# Stow dotfiles
cd "$DOTFILES_DIR"

STOW_TARGETS=(tmux posh zsh nvim)
for target in "${STOW_TARGETS[@]}"; do
    if [ -d "$target" ]; then
        stow -t "$HOME" "$target"
    fi
done

echo "Done! Restart your shell or log out and back in."
