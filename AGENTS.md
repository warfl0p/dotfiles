# Dotfiles Repository

Personal dotfiles for Arch Linux (Omarchy) managed with [GNU Stow](https://www.gnu.org/software/stow/). Each top-level directory is a stow package that symlinks into `~` (or `~/.config/`).


## Structure

```
├── alacritty/   # Alacritty terminal config (imports omarchy theme)
├── bat/         # bat syntax definitions (custom tmux.sublime-syntax for previews)
├── bin/         # Personal scripts in ~/.local/bin (alarm, volume wrapper, workspace launcher)
├── git/         # Global git config (~/.config/git/config, delta pager)
├── hypr/        # Hyprland overrides (bindings, monitors, autostart, monitor scripts)
├── misc/        # Miscellaneous configs (terminal-colors.d/cal.scheme)
├── nvim/        # Neovim (LazyVim-based) config and plugins
├── posh/        # Oh My Posh prompt theme (custom_kushal)
├── sesh/        # sesh session manager config (tmux session definitions)
├── tmux/        # tmux config (Catppuccin theme, vi-mode, sesh integration)
├── zsh/         # .zshrc (zinit, fzf, zoxide, sesh keybindings)
├── install.sh   # Bootstrap script for fresh Omarchy installs
└── AGENTS.md
```

## Installation

All packages are deployed via `stow -t ~` from the repo root. The `install.sh` script installs dependencies through `omarchy pkg add` (stow, zsh, neovim, tmux, fzf, gh, zoxide, sesh, …), plus oh-my-posh, the catppuccin tmux theme, git-delta and fzf-tab, enables the systemd `ssh-agent.socket`, moves any conflicting real files aside as `*.pre-stow`, and then stows everything:

```sh
stow -t ~ git tmux posh zsh nvim sesh alacritty misc bat hypr bin
```

## Key conventions

- **Stow layout**: each package mirrors the home directory hierarchy. For example `sesh/.config/sesh/sesh.toml` symlinks to `~/.config/sesh/sesh.toml`.
- **Package manager**: `omarchy pkg add` (pacman) and `omarchy pkg aur add` for AUR. No Homebrew.
- **Zsh plugin manager**: zinit (zdharma-continuum).
- **Neovim**: LazyVim distribution with custom plugin overrides in `nvim/.config/nvim/lua/plugins/`.
- **Tmux**: prefix is `C-a`, Catppuccin Mocha theme cloned by `install.sh` to `~/.config/tmux/plugins/catppuccin/tmux` and loaded with `run` (no TPM). Sesh integration via `M-s` (session picker) and `M-l` (last session).
- **bat**: custom syntax files live in `bat/.config/bat/syntaxes/`. After stowing, run `bat cache --build` to register them. The tmux syntax is used by sesh `preview_command` entries.

## Editing guidelines

- When adding a new config, create a new stow package directory (or add to an existing one) and add it to the `stow` command in `install.sh`.
- Keep configs minimal; avoid duplicating upstream defaults.
- The `sesh.toml` uses `bat -l tmux` for previewing tmux config — this depends on the custom syntax in the `bat/` package.
