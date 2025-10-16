#!/bin/bash

set -e

DOTFILES_DIR="$HOME/dotfiles"

sudo pacman -Syu --noconfirm stow
# Install Zsh
if ! command -v zsh &> /dev/null; then
    echo "Installing Zsh..."
    sudo pacman -S --noconfirm zsh
fi

# Check current default shell
CURRENT_SHELL=$(getent passwd "$USER" | cut -d: -f7)
if [[ "$CURRENT_SHELL" != "$(which zsh)" ]]; then
    echo "Setting Zsh as default shell..."
    chsh -s $(which zsh)
else
    echo "Zsh is already the default shell."
fi

# Alacritty (repo version)
if ! command -v alacritty &> /dev/null; then
    sudo pacman -S --noconfirm alacritty
fi

# Install Homebrew
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.zshrc
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Clone dotfiles
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
    sudo pacman -S --noconfirm gh
    gh auth login
fi

# Install Tmux + Catppuccin theme
CATPUCCIN_DIR="$HOME/.config/tmux/plugins/catppuccin/tmux"
if [ ! -d "$CATPUCCIN_DIR" ]; then
    mkdir -p "$(dirname "$CATPUCCIN_DIR")"
    git clone -b v2.1.3 https://github.com/catppuccin/tmux.git "$CATPUCCIN_DIR"
fi

# Install Neovim
if ! command -v nvim &> /dev/null; then
    sudo pacman -S --noconfirm neovim
fi

# Install Homebrew packages (preserve your original Brew installs)
brew install uv
brew install fzf

# fzf-tab plugin
FZF_TAB_DIR="$HOME/.zsh_plugins/fzf-tab"
if [ ! -d "$FZF_TAB_DIR" ]; then
    mkdir -p ~/.zsh_plugins
    git clone https://github.com/Aloxaf/fzf-tab "$FZF_TAB_DIR"
fi

# Stow dotfiles
cd "$DOTFILES_DIR"
stow -t ~ git tmux posh zsh 

echo "Done! Restart your shell or log out and back in."