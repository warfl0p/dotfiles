#!/bin/bash

set -e

DOTFILES_DIR="$HOME/dotfiles"

# Ensure deps
sudo apt update
sudo apt install -y unzip stow curl git

# Install Zsh
if ! command -v zsh &> /dev/null; then
    echo "Installing Zsh..."
    sudo apt install -y zsh
fi

# Check current default shell
CURRENT_SHELL=$(getent passwd "$USER" | cut -d: -f7)
if [[ "$CURRENT_SHELL" != "$(which zsh)" ]]; then
    echo "Setting Zsh as default shell..."
    chsh -s $(which zsh)
else
    echo "Zsh is already the default shell."
fi

# install curl
sudo apt install curl
sudo apt install tmux
sudo apt install tree

# Install oh-my-posh
if ! command -v oh-my-posh &> /dev/null; then
    mkdir -p ~/bin
    export PATH="$PATH:$HOME/bin"
    curl -s https://ohmyposh.dev/install.sh | bash -s -- -d ~/bin
    oh-my-posh font install meslo
fi

# Install Tmux + Catppuccin theme
if ! command -v tmux &> /dev/null; then
    echo "Installing Tmux..."
    sudo apt install -y tmux
fi

CATPUCCIN_DIR="$HOME/.config/tmux/plugins/catppuccin/tmux"
if [ ! -d "$CATPUCCIN_DIR" ]; then
    mkdir -p "$(dirname "$CATPUCCIN_DIR")"
    git clone -b v2.1.3 https://github.com/catppuccin/tmux.git "$CATPUCCIN_DIR"
fi

# Install Neovim
if ! command -v nvim &> /dev/null; then
    echo "Installing Neovim..."
    sudo apt install -y neovim
fi

# Homebrew
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# uv
if ! command -v uv &> /dev/null; then
    brew install uv
fi

# fzf
if ! command -v fzf &> /dev/null; then
    brew install fzf
fi

# sesh 
# https://github.com/joshmedeski/sesh
if ! command -v sesh &> /dev/null; then
    brew install sesh
fi

# sessionizer
if ! command -v tms &> /dev/null; then
    brew install tmux-sessionizer
    mkdir -p ~/github
    tms config ~/github
fi

# fzf-tab
FZF_TAB_DIR="$HOME/.zsh_plugins/fzf-tab"
if [ ! -d "$FZF_TAB_DIR" ]; then
    echo "Installing fzf-tab..."
    mkdir -p ~/.zsh_plugins
    git clone https://github.com/Aloxaf/fzf-tab "$FZF_TAB_DIR"
fi

# Install TPM (Tmux Plugin Manager)
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [ ! -d "$TPM_DIR" ]; then
    echo "Installing TPM..."
    mkdir -p "$(dirname "$TPM_DIR")"
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
else
    echo "TPM already installed."
fi

# Stow dotfiles
cd "$DOTFILES_DIR"
stow -t ~ git tmux posh zsh nvim

source ~/.zshrc

echo "Done! Restart your shell or log out and back in."
