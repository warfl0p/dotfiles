# Dotfiles Repository

Personal dotfiles for Arch Linux (Omarchy) managed with [GNU Stow](https://www.gnu.org/software/stow/). Each top-level directory is a stow package that symlinks into `~` (or `~/.config/`).


## Structure

```
├── alacritty/   # Alacritty terminal config (imports omarchy theme)
├── bat/         # bat syntax definitions (custom tmux.sublime-syntax for previews)
├── bin/         # Personal scripts in ~/.local/bin (alarm, volume wrapper, workspace launcher)
├── git/         # Global git config (~/.config/git/config, delta pager)
├── hypr/        # Hyprland overrides (bindings, autostart, monitor scripts); monitors.lua is left to hyprmoncfg
├── lazygit/     # lazygit config (delta diff renderer)
├── mise/        # mise tools in conf.d/dotfiles.toml (dekit, node, oh-my-posh, opencode); config.toml stays Omarchy's
├── misc/        # Miscellaneous configs (terminal-colors.d/cal.scheme)
├── nvim/        # Neovim (LazyVim-based) config and plugins
├── omarchy/     # Omarchy shell.json (bar layout), shell.toml (surface styling), custom themes (vscode-2026) and own omarchy-shell plugins (matthias.*)
├── posh/        # Oh My Posh prompt themes (minimal, active; custom_kushal, previous)
├── sesh/        # sesh session manager config (tmux session definitions)
├── systemd/     # systemd user units (zsh-history-backup timer)
├── tmux/        # tmux config (Catppuccin theme, vi-mode, sesh integration)
├── zsh/         # .zshrc (zinit, fzf, zoxide, sesh keybindings)
├── install.sh   # Bootstrap script for fresh Omarchy installs
└── AGENTS.md
```

## Installation

All packages are deployed via `stow -t ~` from the repo root. The `install.sh` script installs core packages and the apps the configs reference through `omarchy pkg add` / `omarchy pkg aur add`, adds the third-party omarchy-shell plugins, clones the catppuccin tmux theme, moves any conflicting real files aside as `*.pre-stow`, stows everything, runs `bat cache --build` and `mise install`, enables the `ssh-agent.socket`, `zsh-history-backup.timer` and `hyprmoncfgd.service` user units, sets the vscode-2026 theme, and finally runs the interactive `chsh` / `gh auth login` steps:

```sh
stow -t ~ git tmux posh zsh nvim sesh alacritty misc bat hypr bin omarchy mise systemd lazygit
```

## Key conventions

- **Stow layout**: each package mirrors the home directory hierarchy. For example `sesh/.config/sesh/sesh.toml` symlinks to `~/.config/sesh/sesh.toml`.
- **Package manager**: `omarchy pkg add` (pacman) and `omarchy pkg aur add` for AUR. No Homebrew.
- **Zsh plugin manager**: zinit (zdharma-continuum). fzf-tab is loaded through zinit after `compinit` and before zsh-autosuggestions.
- **Neovim**: LazyVim distribution with custom plugin overrides in `nvim/.config/nvim/lua/plugins/`.
- **Tmux**: prefix is `C-a` (`C-Space` runs `claude` via zsh), Catppuccin Mocha theme cloned by `install.sh` to `~/.config/tmux/plugins/catppuccin/tmux` and loaded with `run` (no TPM). Sesh integration via `M-s` (session picker) and `M-l` (last session).
- **bat**: custom syntax files live in `bat/.config/bat/syntaxes/`. After stowing, run `bat cache --build` to register them. The tmux syntax is used by sesh `preview_command` entries.

## Editing guidelines

- When adding a new config, create a new stow package directory (or add to an existing one) and add it to the `stow` command in `install.sh`.
- Keep configs minimal; avoid duplicating upstream defaults.
- The `sesh.toml` uses `bat -l tmux` for previewing tmux config — this depends on the custom syntax in the `bat/` package.
- `omarchy bar ...` commands rewrite `~/.config/omarchy/shell.json` with `mv`, which replaces the stow symlink with a real file. Edit `omarchy/.config/omarchy/shell.json` directly, or after using `omarchy bar` copy the file back into the repo and run `stow -R -t ~ omarchy`.
- `~/.config/hypr/monitors.lua` is not in the repo: hyprmoncfg rewrites it per machine (and its generated `hyprmoncfg-monitors.lua` is loaded last from `hyprland.lua`).
