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

# Make Zsh default shell
if [ "$SHELL" != "$(which zsh)" ]; then
    echo "Setting Zsh as default shell..."
    chsh -s "$(which zsh)"
fi

# Clone dotfiles if missing
if [ ! -d "$DOTFILES_DIR" ]; then
    echo "Cloning dotfiles..."
    git clone https://github.com/warfl0p/dotfiles.git "$DOTFILES_DIR"
fi

# Install oh-my-posh
if ! command -v oh-my-posh &> /dev/null; then
    mkdir -p ~/bin
    export PATH="$PATH:$HOME/bin"
    curl -s https://ohmyposh.dev/install.sh | bash -s -- -d ~/bin
    oh-my-posh font install meslo
fi

# Install GitHub CLI
if ! command -v gh &> /dev/null; then
    echo "Installing GitHub CLI..."
    sudo apt install -y gh
    gh auth login
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

# fzf-tab
FZF_TAB_DIR="$HOME/.zsh_plugins/fzf-tab"
if [ ! -d "$FZF_TAB_DIR" ]; then
    echo "Installing fzf-tab..."
    mkdir -p ~/.zsh_plugins
    git clone https://github.com/Aloxaf/fzf-tab "$FZF_TAB_DIR"
fi

# Stow dotfiles
cd "$DOTFILES_DIR"
stow -t ~ git tmux i3 posh zsh nvim

echo "Done! Restart your shell or log out and back in."
