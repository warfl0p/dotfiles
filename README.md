Personal dotfiles for [Omarchy](https://omarchy.org) (Arch Linux + Hyprland), managed with GNU Stow.

# Installation
On a fresh Omarchy install, clone the repository into your home directory and run the installation script:
```
cd ~ && \
git clone https://github.com/warfl0p/dotfiles && \
cd dotfiles && \
./install.sh
```
It asks for your sudo password, your password again for `chsh`, and a GitHub login at the end. Log out and back in when it is done.

## What install.sh does
1. **Updates the system** with `omarchy update -y`.
2. **Installs packages**
   - CLI tools: stow, zsh, neovim, tmux, fzf, fd, bat, eza, git, git-delta, uv, zoxide, jq, tokei, yazi, diffnav, lazygit, sesh (AUR)
   - Terminal: Alacritty, set as the default terminal (Super + Return)
   - Apps: Google Chrome, dgop, VS Code, Seafile client, hyprmoncfg, Spotifast, DankCalendar, OnlyOffice (most from the AUR; Seafile builds from source)
   - mise tools from `mise/.config/mise/conf.d/dotfiles.toml`: dekit, node, oh-my-posh, opencode. Omarchy's own `~/.config/mise/config.toml` (claude, codex, gh, ...) is left alone.
3. **Adds omarchy-shell plugins**: [hyprmoncfg](https://github.com/crmne/omarchy-hyprmoncfg), [lock-explorer](https://github.com/SirJul1337/omarchy-lock-explorer) and [omapager](https://github.com/njpatel/omapager). The own `matthias.*` plugins (audio, media, network, osd, tailscale) come from the `omarchy` package below.
4. **Clones the Catppuccin tmux theme** (v2.1.3) into `~/.config/tmux/plugins/catppuccin/tmux`.
5. **Stows the configs** into `~`: `git tmux posh zsh nvim sesh alacritty misc bat hypr bin omarchy mise systemd lazygit`. Any existing file in the way is moved aside as `<file>.pre-stow`.
6. **Sets up the system**
   - Builds the bat cache, for the custom tmux syntax used in sesh previews
   - Enables the user units `ssh-agent.socket`, `zsh-history-backup.timer` and `hyprmoncfgd.service`
   - Keeps VS Code on its own theme when the Omarchy theme changes
   - Opens Office/OpenDocument files in OnlyOffice and `.csv` files in Neovim
   - Applies the `vscode-2026` theme and its wallpaper
7. **Interactive steps**: sets zsh as the login shell (`chsh`) and runs `gh auth login` if gh is not logged in yet.

The script can be rerun: packages already installed and files already stowed are skipped.

## After installing
- Sign in to Seafile once. Its daemon (started from `hypr/autostart.lua`) and the zsh history backup to `~/Seafile` depend on it.
- `launch-workspace-apps` (Super + Ctrl + S) also starts `dbflux-improved`, a local build that is not installed by the script.

See [AGENTS.md](AGENTS.md) for the package layout and conventions.
