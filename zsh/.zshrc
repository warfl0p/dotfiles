### Added by Zinit's installer
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


# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

### End of Zinit's installer chunk
# Shell integrations
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# fzf ctrl r
source <(fzf --zsh)
# [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# fzf-tab plugin
source ~/.zsh_plugins/fzf-tab/fzf-tab.plugin.zsh

modified-fzf-history-widget() {
  local selected
  setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases no_bash_rematch 2> /dev/null
  # appends the current shell history buffer to the HISTFILE
  builtin fc -AI $HISTFILE
  # pushes entries from the $HISTFILE onto a stack and uses this history
  builtin fc -p $HISTFILE $HISTSIZE $SAVEHIST
  selected="$(builtin fc -rl 1 |
    awk '{ cmd=$0; sub(/^[ \t]*[0-9]+\**[ \t]+/, "", cmd); if (!seen[cmd]++) print $0 }' |
    FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} ${FZF_DEFAULT_OPTS-} -n2..,.. --scheme=history --bind=ctrl-r:toggle-sort,ctrl-z:ignore ${FZF_CTRL_R_OPTS-} --query=${(qqq)LBUFFER} --multi" $(__fzfcmd))"
  local ret=$?
	if [[ -n $selected ]]; then
    if [[ "$selected" =~ ^[[:blank:]]*[[:digit:]]+ ]]; then
	  builtin fc -pa "$HISTFILE"
	  zle vi-fetch-history -n "$MATCH"
    else # selected is a custom query, not from history
      LBUFFER="$selected"
    fi
  fi
  # Read the history from the history file into the history list
  builtin fc -R $HISTFILE
  zle reset-prompt
  return $ret
}
zle -N modified-fzf-history-widget
bindkey "^R" modified-fzf-history-widget


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

# History
export HISTSIZE=12000
export SAVEHIST=10000
export HISTFILE="${ZDOTDIR:-$HOME}"/.zsh_history
# HISTFILE=~/.zsh_history
HISTDUP=erase
setopt appendhistory
setopt SHARE_HISTORY
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups


# ohmy posh
export PATH=$PATH:/home/matthias/bin
eval "$(oh-my-posh init zsh --config ~/.config/oh-my-posh/themes/custom_kushal.omp.json)"

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions

# Add in snippets
zinit snippet OMZL::git.zsh
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::archlinux
zinit snippet OMZP::command-not-found

# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q

# Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}' # make completion case-insensitive
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}" # colorize completions
zstyle ':completion:*' menu no # remove default completion menu, because we are using fzf
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Aliases
alias ls='ls --color'
alias c='clear'

# activate virtual environment
activate() {
    if [ -f .venv/bin/activate ]; then
        source .venv/bin/activate
    else
        echo "Error: .venv/bin/activate not found in the current directory."
    fi
}
mem_usage() {
top -b -n 1 | awk 'NR>7 {arr[$12]+=$6} END {for (i in arr) printf "%-60s %.2f GB\n", i, arr[i]/1024/1024}' | sort -nk2 | tail -n 20
}

# auto start ssh
# Start ssh-agent if not running and add SSH key
if ! pgrep -u "$USER" ssh-agent > /dev/null; then
  eval "$(ssh-agent -s)" >/dev/null 2>&1
fi

if [ -f ~/.ssh/bitbucket_work ]; then
  ssh-add -q ~/.ssh/bitbucket_work >/dev/null 2>&1
fi



# remove unwanted suggestions
zstyle ':completion:*:complete:-command-:*:*' ignored-patterns '*.dll|*.exe|*.so|*.pyd'
# add uv zsh completions
eval "$(uv generate-shell-completion zsh)"



# add golang path
export PATH=$PATH:/usr/local/go/bin
# allow for ctr+arrow keys navigation
### ctrl+arrows
bindkey "\e[1;5C" forward-word
bindkey "\e[1;5D" backward-word
# urxvt
bindkey "\eOc" forward-word
bindkey "\eOd" backward-word

### ctrl+delete
bindkey "\e[3;5~" kill-word
# urxvt
bindkey "\e[3^" kill-word

### ctrl+backspace
bindkey '^H' backward-kill-word

### ctrl+shift+delete
bindkey "\e[3;6~" kill-line
# urxvt
bindkey "\e[3@" kill-line

# typer autocompletes for optimile project
fpath+=~/.zfunc; autoload -Uz compinit; compinit


if [ -z "$TMUX" ]; then
  # Ctrl+A outside tmux → start/attach tmux session in ~
  bindkey -s '^A' 'tmux attach -t matthias 2>/dev/null || (cd ~ && tmux new -s home)\n'
fi

