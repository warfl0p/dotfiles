#!/bin/bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DEBIAN_FRONTEND=noninteractive

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

echo "Installing base packages..."
sudo apt update
sudo apt install -y unzip stow curl git zsh tmux tree neovim build-essential fzf fd-find

# Install Zsh
if ! command_exists zsh; then
    echo "Installing Zsh..."
    sudo apt install -y zsh
fi

# Check current default shell
CURRENT_SHELL=$(getent passwd "$USER" | cut -d: -f7)
ZSH_PATH="$(command -v zsh)"
if [[ "$CURRENT_SHELL" != "$ZSH_PATH" ]]; then
    if [[ "${SET_DEFAULT_SHELL:-0}" == "1" ]]; then
        echo "Setting Zsh as default shell..."
        chsh -s "$ZSH_PATH"
    else
        echo "Default shell is not zsh. To switch automatically, rerun with SET_DEFAULT_SHELL=1"
    fi
else
    echo "Zsh is already the default shell."
fi

# Install oh-my-posh
if ! command_exists oh-my-posh; then
    mkdir -p ~/bin
    export PATH="$PATH:$HOME/bin"
    curl -fsSL https://ohmyposh.dev/install.sh | bash -s -- -d ~/bin
fi

# uv
if ! command_exists uv; then
    echo "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
fi

export PATH="$HOME/.local/bin:$PATH"
if ! command_exists uv; then
    echo "uv install completed but uv is not on PATH. Add ~/.local/bin to your shell PATH."
    exit 1
fi

# fzf
if ! command_exists fzf; then
    echo "Installing fzf..."
    sudo apt install -y fzf
fi

# sesh 
# https://github.com/joshmedeski/sesh
if ! command_exists sesh; then
    echo "sesh not found. Install it manually from https://github.com/joshmedeski/sesh/releases"
fi

# fd command compatibility (Ubuntu package provides fdfind)
if command_exists fdfind && ! command_exists fd; then
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
fi

# fzf-tab
FZF_TAB_DIR="$HOME/.zsh_plugins/fzf-tab"
if [ ! -d "$FZF_TAB_DIR" ]; then
    echo "Installing fzf-tab..."
    mkdir -p ~/.zsh_plugins
    git clone --depth 1 https://github.com/Aloxaf/fzf-tab "$FZF_TAB_DIR"
fi

# Install TPM (Tmux Plugin Manager)
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [ ! -d "$TPM_DIR" ]; then
    echo "Installing TPM..."
    mkdir -p "$(dirname "$TPM_DIR")"
    git clone --depth 1 https://github.com/tmux-plugins/tpm "$TPM_DIR"
else
    echo "TPM already installed."
fi

# Stow dotfiles
cd "$DOTFILES_DIR"
stow -t ~ tmux posh zsh nvim

echo "Done! Start a new shell (or run: exec zsh)."
