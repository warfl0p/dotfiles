#!/bin/bash

set -euo pipefail

# Run from a clone of this repo: git clone https://github.com/warfl0p/dotfiles ~/dotfiles
DOTFILES_DIR=$(dirname "$(realpath "$0")")

if ! command -v omarchy &> /dev/null; then
    echo "This installer expects an Omarchy system (omarchy not found on PATH)." >&2
    exit 1
fi

# Packages go through omarchy so system upgrades stay behind `omarchy update`.
# `omarchy pkg add` is idempotent: it skips packages that are already present.
# Core: everything the shell, tmux, sesh and git configs depend on.
omarchy pkg add stow zsh neovim tmux fzf fd bat eza git git-delta uv \
    zoxide jq tokei yazi diffnav lazygit
omarchy pkg aur add sesh-bin

# Install Alacritty and make it the xdg-terminal-exec default (Super + Return)
omarchy install terminal alacritty

# Apps referenced by hypr bindings/autostart, launch-workspace-apps and sesh windows.
omarchy pkg add google-chrome dgop
omarchy pkg aur add visual-studio-code-bin seafile-client hyprmoncfg-bin \
    spotifast-bin dankcalendar-bin onlyoffice-bin

# Third-party omarchy-shell plugins (own matthias.* plugins are stowed below)
for url in \
    https://github.com/crmne/omarchy-hyprmoncfg \
    https://github.com/SirJul1337/omarchy-lock-explorer \
    https://github.com/njpatel/omapager; do
    omarchy plugin add "$url" --enable --yes || echo "Skipping plugin $url"
done

# Catppuccin tmux theme (loaded with `run` in tmux.conf, no TPM)
CATPPUCCIN_DIR="$HOME/.config/tmux/plugins/catppuccin/tmux"
if [ ! -d "$CATPPUCCIN_DIR" ]; then
    git clone -b v2.1.3 https://github.com/catppuccin/tmux.git "$CATPPUCCIN_DIR"
fi

# Stow dotfiles. Omarchy ships real files at some of these paths (hypr, alacritty, lazygit),
# which makes stow abort, so move any non-symlink target aside as *.pre-stow first.
cd "$DOTFILES_DIR"
PACKAGES=(git tmux posh zsh nvim sesh alacritty misc bat hypr bin omarchy mise systemd lazygit)
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

# Register the custom tmux syntax used by sesh previews
bat cache --build

# Tools from ~/.config/mise/conf.d/dotfiles.toml (dekit, node, oh-my-posh, opencode)
mise install

# One ssh-agent for every shell; .zshrc points SSH_AUTH_SOCK at this socket
systemctl --user enable --now ssh-agent.socket
systemctl --user daemon-reload
systemctl --user enable --now zsh-history-backup.timer
# Monitor profile daemon; the crmne.hyprmoncfg bar plugin talks to its socket
systemctl --user enable --now hyprmoncfgd.service

# Keep VS Code on its own theme when the Omarchy theme changes
mkdir -p ~/.local/state/omarchy/toggles && touch ~/.local/state/omarchy/toggles/skip-vscode-theme-changes

# Open Office/OpenDocument files in OnlyOffice instead of LibreOffice
xdg-mime default onlyoffice-desktopeditors.desktop $(grep '^MimeType=' \
    /usr/share/applications/onlyoffice-desktopeditors.desktop | cut -d= -f2 | tr ';' '\n' \
    | grep -E '^application/(msword|vnd\.(ms-|openxmlformats|oasis))')
xdg-mime default nvim.desktop text/csv

# OMARCHY_THEME_SKIP_BACKGROUND (hyprland.lua) keeps the background link, but on a
# fresh install it points into ~/.local/state/omarchy/current/theme, which a theme
# switch replaces. Repoint it at the same image in the theme's own folder first.
state=~/.local/state/omarchy/current
bg=$(readlink "$state/background" || true)
if [[ $bg == "$state/theme/"* ]]; then
    old_theme=$(cat "$state/theme.name")
    for dir in "${OMARCHY_PATH:-/usr/share/omarchy}/themes/$old_theme" ~/.config/omarchy/themes/"$old_theme"; do
        if [[ -f $dir/${bg#"$state/theme/"} ]]; then
            omarchy theme bg set "$dir/${bg#"$state/theme/"}"
            break
        fi
    done
fi

# The theme ships no wallpaper; hyprland.lua sets this too, but only for new sessions
OMARCHY_THEME_SKIP_BACKGROUND=1 omarchy theme set vscode-2026 || echo "Could not set theme vscode-2026"

if [[ "$(getent passwd "$USER" | cut -d: -f7)" != "$(command -v zsh)" ]]; then
    echo "Setting Zsh as default shell..."
    chsh -s "$(command -v zsh)"
fi

# Interactive steps last, so the unattended part finishes first
if ! gh auth status &> /dev/null; then
    gh auth login
fi

echo "Done! Restart your shell or log out and back in."
