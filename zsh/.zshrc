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
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
export PATH=$PATH:/home/matthias/bin
export PATH=$HOME/.npm-global/bin:$PATH
export PATH=/home/matthias/.local/share/mise/installs/go/1.26.0/bin:$PATH

# ─── History ──────────────────────────────────────────────────────────────────
export HISTSIZE=12000
export SAVEHIST=10000
export HISTFILE="${ZDOTDIR:-$HOME}"/.zsh_history
HISTDUP=erase
setopt appendhistory
setopt SHARE_HISTORY
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# ─── Prompt ───────────────────────────────────────────────────────────────────
eval "$(oh-my-posh init zsh --config ~/.config/oh-my-posh/themes/custom_kushal.omp.json)"

# ─── Plugins & Snippets ───────────────────────────────────────────────────────
zinit light zsh-users/zsh-syntax-highlighting
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
source <(fzf --zsh)
source ~/.zsh_plugins/fzf-tab/fzf-tab.plugin.zsh

export FZF_CTRL_R_OPTS="$(
    cat <<'FZF_FTW'
--bind "ctrl-d:execute-silent(zsh -ic 'builtin fc -p $HISTFILE $HISTSIZE $SAVEHIST; for i in {+1}; do ignore+=( \"${(b)history[$i]}\" );done;
    HISTORY_IGNORE=\"(${(j:|:)ignore})\";builtin fc -W $HISTFILE')+reload:builtin fc -p $HISTFILE $HISTSIZE $SAVEHIST; builtin fc -rl 1 |
    awk '{ cmd=$0; sub(/^[ \t]*[0-9]+\**[ \t]+/, \"\", cmd); if (!seen[cmd]++) print $0 }'"
--bind 'enter:accept-or-print-query'
--header 'enter select · ^d remove'
--prompt ' Global History > '
FZF_FTW
)"

modified-fzf-history-widget() {
  local selected
  setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases no_bash_rematch 2>/dev/null
  builtin fc -AI $HISTFILE
  builtin fc -p $HISTFILE $HISTSIZE $SAVEHIST
  selected="$(builtin fc -rl 1 |
    awk '{ cmd=$0; sub(/^[ \t]*[0-9]+\**[ \t]+/, "", cmd); if (!seen[cmd]++) print $0 }' |
    FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} ${FZF_DEFAULT_OPTS-} -n2..,.. --scheme=history --bind=ctrl-r:toggle-sort,ctrl-z:ignore ${FZF_CTRL_R_OPTS-} --query=${(qqq)LBUFFER} --multi" $(__fzfcmd))"
  local ret=$?
  if [[ -n $selected ]]; then
    if [[ "$selected" =~ ^[[:blank:]]*[[:digit:]]+ ]]; then
      builtin fc -pa "$HISTFILE"
      zle vi-fetch-history -n "$MATCH"
    else
      LBUFFER="$selected"
    fi
  fi
  builtin fc -R $HISTFILE
  zle reset-prompt
  return $ret
}
zle -N modified-fzf-history-widget
bindkey "^R" modified-fzf-history-widget

fzf-git-log-widget() {
  if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo "Not in a git repository." >&2
    return 1
  fi
  local selected
  selected=$(git log --no-show-signature --color=always \
    --format='%C(bold blue)%h%C(reset) - %C(cyan)%ad%C(reset) %C(yellow)%d%C(reset) %C(normal)%s%C(reset)  %C(dim normal)[%an]%C(reset)' \
    --date=short | \
    fzf --ansi --multi --scheme=history --prompt="Git Log> " \
      --preview='git show --color=always --stat --patch {1}' \
      --preview-window=right:50%:wrap | \
    awk '{print $1}' | \
    xargs -I {} git rev-parse {} 2>/dev/null | \
    tr '\n' ' ')
  [[ -n "$selected" ]] && LBUFFER="${LBUFFER}${selected}"
  zle reset-prompt
}
zle -N fzf-git-log-widget
bindkey '^[^L' fzf-git-log-widget  # Ctrl+Alt+L

fzf-variables-widget() {
  local current_token="${LBUFFER##* }"
  local cleaned_token="${current_token#\$}"
  local selected
  selected=$(typeset -p | awk '{print $1, $2}' | sort -u | awk '{print $2}' | \
    fzf --multi --prompt="Variables> " --preview-window=wrap \
      --preview='echo {} && typeset -p {} 2>/dev/null || echo "No details available"' \
      --query="$cleaned_token")
  if [[ -n "$selected" ]]; then
    [[ "$current_token" == \$* ]] && selected="\$${selected}"
    LBUFFER="${LBUFFER%$current_token}${selected} "
  fi
  zle reset-prompt
}
zle -N fzf-variables-widget
bindkey '^V' fzf-variables-widget

# ─── sesh ─────────────────────────────────────────────────────────────────────
# alt S top open session picker
function sesh-sessions() {
  {
    exec </dev/tty
    exec <&1
    local session
    session=$(
      sesh list -i |
        fzf \
          --ansi \
          --height 40% \
          --reverse \
          --border \
          --border-label ' sesh ' \
          --prompt '⚡  '
    )
    zle reset-prompt >/dev/null 2>&1 || true
    [[ -z "$session" ]] && return
    sesh connect "$session"
  }
}
zle -N sesh-sessions
bindkey -M emacs '\es' sesh-sessions
bindkey -M vicmd '\es' sesh-sessions
bindkey -M viins '\es' sesh-sessions

# ctrl A to open home session
_sesh_home() {
  BUFFER="sesh connect 'home (~)'"
  zle accept-line
}
zle -N _sesh_home
bindkey '^A' _sesh_home
# alt L to open last session
sesh-last-session() {
  {
    exec </dev/tty
    exec <&1
    sesh last
  }
}

zle -N sesh-last-session
bindkey -M emacs '\el' sesh-last-session
bindkey -M vicmd '\el' sesh-last-session
bindkey -M viins '\el' sesh-last-session
# ─── Aliases ──────────────────────────────────────────────────────────────────
alias ls='ls --color'
alias c='clear'
alias mem_usage='dgop'
alias cal='cal -m -w -y'

unalias gd 2>/dev/null
gd() {
  git diff "$@" | diffnav
}

# ─── Functions ────────────────────────────────────────────────────────────────
# Activate local .venv
activate() {
  if [ -f .venv/bin/activate ]; then
    source .venv/bin/activate
  else
    echo "Error: .venv/bin/activate not found in the current directory."
  fi
}

# ─── SSH Agent ────────────────────────────────────────────────────────────────
if ! pgrep -u "$USER" ssh-agent >/dev/null; then
  eval "$(ssh-agent -s)" >/dev/null 2>&1
fi
[[ -f ~/.ssh/bitbucket_work ]] && ssh-add -q ~/.ssh/bitbucket_work >/dev/null 2>&1
[[ -f ~/unraidVM_publickey ]]  && ssh-add -q ~/unraidVM_publickey  >/dev/null 2>&1

# ─── Integrations (must be last) ──────────────────────────────────────────────
eval "$(zoxide init zsh)"
source ~/.local/share/omarchy/default/bash/fns/tmux
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"

# Resend CLI
export PATH="$HOME/.resend/bin:$PATH"

svg-unwrap() {
  python3 -c "
import re, base64, sys
path = sys.argv[1]
h = open(path).read()
m = re.search(r'base64,([A-Za-z0-9+/=]+)', h)
if not m:
    print('No base64 SVG found in', path); sys.exit(1)
open(path, 'wb').write(base64.b64decode(m.group(1)))
print('Done:', path)
" "$1" && touch "$1"
}

fpath+=~/.zfunc; autoload -Uz compinit; compinit
