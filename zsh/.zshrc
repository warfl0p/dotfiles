# ─── Zinit Bootstrap ──────────────────────────────────────────────────────────
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Annexes (required before plugins)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

# ─── Environment ──────────────────────────────────────────────────────────────
export PATH=$PATH:/home/matthias/bin
export PATH=$HOME/.npm-global/bin:$PATH
export PATH=$HOME/.local/share/mise/installs/go/latest/bin:$PATH  # mise keeps `latest` pointed at the newest install

# ─── History ──────────────────────────────────────────────────────────────────
export HISTSIZE=12000
export SAVEHIST=10000
export HISTFILE="${ZDOTDIR:-$HOME}"/.zsh_history
setopt appendhistory
setopt SHARE_HISTORY
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_find_no_dups

# ─── Prompt ───────────────────────────────────────────────────────────────────
eval "$(oh-my-posh init zsh --config ~/.config/oh-my-posh/themes/custom_kushal.omp.json)"

# ─── Plugins & Snippets ───────────────────────────────────────────────────────
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions

zinit snippet OMZL::git.zsh
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::archlinux
zinit snippet OMZP::command-not-found
zinit snippet OMZP::colored-man-pages

# ─── Completions ──────────────────────────────────────────────────────────────
# fpath additions must come before compinit
fpath+=~/.zfunc

autoload -Uz compinit && compinit
zinit cdreplay -q

# uv shell completions
eval "$(uv generate-shell-completion zsh)"

# ─── Keybindings ──────────────────────────────────────────────────────────────
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region
bindkey '^e' edit-command-line

# ctrl+arrow navigation
bindkey "\e[1;5C" forward-word
bindkey "\e[1;5D" backward-word
bindkey "\eOc" forward-word   # urxvt
bindkey "\eOd" backward-word  # urxvt

# delete
bindkey "\e[3~" delete-char

# ctrl+delete
bindkey "\e[3;5~" kill-word
bindkey "\e[3^" kill-word     # urxvt

# ctrl+backspace
bindkey '^H' backward-kill-word

# ctrl+shift+delete
bindkey "\e[3;6~" kill-line
bindkey "\e[3@" kill-line     # urxvt

# edit command in vim
autoload -U edit-command-line
zle -N edit-command-line

# ─── Completion Styling ───────────────────────────────────────────────────────
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'
zstyle ':completion:*:complete:-command-:*:*' ignored-patterns '*.dll|*.exe|*.so|*.pyd'

# ─── fzf ──────────────────────────────────────────────────────────────────────
source ~/.config/zsh/fzf.zsh

# ─── sesh ─────────────────────────────────────────────────────────────────────
source ~/.config/zsh/sesh.zsh
# ─── Aliases ──────────────────────────────────────────────────────────────────
alias ls='ls --color'
alias cat='bat'
alias c='clear'
alias mem_usage='dgop'
alias cal='cal -m -w -y'

unalias gd 2>/dev/null
gd() {
  git diff "$@" -- . ':(exclude)*_templ.go' | diffnav --unified
}

# ─── Functions ────────────────────────────────────────────────────────────────
# `nvim` with no args restores this dir's session and opens Neo-tree; `nvim <args>` behaves normally
nvim() {
  if [ $# -eq 0 ]; then
    command nvim -c 'lua require("persistence").load()' -c 'Neotree show'
  else
    command nvim "$@"
  fi
}

# Activate local .venv
activate() {
  if [ -f .venv/bin/activate ]; then
    source .venv/bin/activate
  else
    echo "Error: .venv/bin/activate not found in the current directory."
  fi
}

fkilljob() {
  local job
  job=$(jobs | fzf | sed -E 's/^\[([0-9]+)\].*/\1/') || return
  kill -9 %"$job"
}

source ~/.config/zsh/ghlang.zsh


# ─── SSH Agent ────────────────────────────────────────────────────────────────
# systemd user agent (ssh-agent.socket, enabled by install.sh): one agent shared by every shell
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"

# ─── Integrations (must be last) ──────────────────────────────────────────────
eval "$(zoxide init zsh)"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"

# Resend CLI
export PATH="$HOME/.resend/bin:$PATH"

# must be sourced after every other widget is defined
zinit light zsh-users/zsh-syntax-highlighting
