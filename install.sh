#!/bin/bash

# Install Zsh
sudo apt install unzip
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

# install oh my posh
mkdir ~/bin
export PATH="$PATH:$HOME/bin"
curl -s https://ohmyposh.dev/install.sh | bash -s -- -d ~/bin
oh-my-posh font install meslo


# install gh and authorize
if ! command -v gh &> /dev/null; then
    echo "Installing GitHub CLI..."
    sudo apt install gh
    gh auth login
fi

sudo apt install stow
cd "$DOTFILES_DIR"

stow .
# tmux theme and source config
CATPUCCIN_DIR="$HOME/.config/tmux/plugins/catppuccin/tmux"
if [ ! -d "$CATPUCCIN_DIR" ]; then
    mkdir -p ~/.config/tmux/plugins/catppuccin
    git clone -b v2.1.3 https://github.com/catppuccin/tmux.git ~/.config/tmux/plugins/catppuccin/tmux
    tmux source ~/.tmux.conf
fi
#install homebrew
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi
# install uv
if ! command -v uv &> /dev/null; then
    brew install uv
fi

# install fzf
if ! command -v fzf >/dev/null 2>&1; then
  brew install fzf
fi


echo "Done! Restart your shell or log out and back in."
