source <(fzf --zsh)
source ~/.zsh_plugins/fzf-tab/fzf-tab.plugin.zsh

export FZF_CTRL_T_OPTS="--preview 'if [ -d {} ]; then ls -A --color=always {}; else bat --color=always --style=numbers --line-range=:200 {}; fi'"

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
  local current_token="${LBUFFER##* }"
  local ref=""
  if [[ -n "$current_token" ]] && git rev-parse --verify --quiet "$current_token" >/dev/null 2>&1; then
    ref="$current_token"
    LBUFFER="${LBUFFER%$current_token}"
  fi
  local selected
  selected=$(git log --no-show-signature --color=always \
    --format='%C(bold blue)%h%C(reset) - %C(cyan)%ad%C(reset) %C(yellow)%d%C(reset) %C(normal)%s%C(reset)  %C(dim normal)[%an]%C(reset)' \
    --date=short ${ref} | \
    fzf --ansi --multi --scheme=history --prompt="Git Log${ref:+ ($ref)}> " \
      --preview='git show --color=always --stat --patch {1} | delta --dark --paging=never' \
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
