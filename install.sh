#!/bin/bash

# Install Zsh
if ! command -v zsh &> /dev/null; then
    echo "Installing Zsh..."
    sudo apt update && sudo apt install -y zsh
fi

# Make Zsh default shell
echo "Setting Zsh as default shell..."
chsh -s $(which zsh)

# Clone dotfiles
DOTFILES_DIR="$HOME/dotfiles"
if [ ! -d "$DOTFILES_DIR" ]; then
    echo "Cloning dotfiles..."
    git clone https://github.com/warfl0p/dotfiles.git "$DOTFILES_DIR"
fi


sudo apt install stow
cd "$DOTFILES_DIR"
stow .



echo "Done! Restart your shell or log out and back in."
