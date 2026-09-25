#!/bin/bash

set -e

DOTFILES_DIR="$HOME/dotfiles"

if ! command -v omarchy &> /dev/null; then
    echo "This installer expects an Omarchy system (omarchy not found on PATH)." >&2
    exit 1
fi

# Packages go through omarchy so system upgrades stay behind `omarchy update`.
# `omarchy pkg add` is idempotent: it skips packages that are already present.
omarchy pkg add stow zsh alacritty neovim tmux fzf fd bat git uv github-cli \
    zoxide eza jq tokei yazi diffnav
omarchy pkg aur add sesh-bin

# One ssh-agent for every shell; .zshrc points SSH_AUTH_SOCK at this socket
systemctl --user enable --now ssh-agent.socket

# Check current default shell
CURRENT_SHELL=$(getent passwd "$USER" | cut -d: -f7)
if [[ "$CURRENT_SHELL" != "$(which zsh)" ]]; then
    echo "Setting Zsh as default shell..."
    chsh -s $(which zsh)
else
    echo "Zsh is already the default shell."
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
fi

# Authenticate the GitHub CLI (interactive)
if ! gh auth status &> /dev/null; then
    gh auth login
fi

# Install Tmux + Catppuccin theme
CATPUCCIN_DIR="$HOME/.config/tmux/plugins/catppuccin/tmux"
if [ ! -d "$CATPUCCIN_DIR" ]; then
    mkdir -p "$(dirname "$CATPUCCIN_DIR")"
    git clone -b v2.1.3 https://github.com/catppuccin/tmux.git "$CATPUCCIN_DIR"
fi

# delta for improved diffs (AUR)
omarchy pkg aur add git-delta-git || echo "Skipping git-delta-git (AUR unavailable)"

# fzf-tab plugin
FZF_TAB_DIR="$HOME/.zsh_plugins/fzf-tab"
if [ ! -d "$FZF_TAB_DIR" ]; then
    mkdir -p ~/.zsh_plugins
    git clone https://github.com/Aloxaf/fzf-tab "$FZF_TAB_DIR"
fi

# Stow dotfiles. Omarchy ships real files at some of these paths (hypr, alacritty),
# which makes stow abort, so move any non-symlink target aside as *.pre-stow first.
cd "$DOTFILES_DIR"
PACKAGES=(git tmux posh zsh nvim sesh alacritty misc bat hypr bin)
for pkg in "${PACKAGES[@]}"; do
    while IFS= read -r -d '' file; do
        target="$HOME/${file#"$pkg"/}"
        # skip paths already served by the repo (stow may have linked a parent directory)
        if [[ -e $target && $(realpath "$target") != "$DOTFILES_DIR"/* ]]; then
            echo "Backing up $target -> $target.pre-stow"
            mv "$target" "$target.pre-stow"
        fi
    done < <(find "$pkg" -type f -print0)
done
stow -t ~ "${PACKAGES[@]}"

echo "Done! Restart your shell or log out and back in."
