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
alias cat='bat'
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

fkilljob() {
  local job
  job=$(jobs | fzf | sed -E 's/^\[([0-9]+)\].*/\1/') || return
  kill -9 %"$job"
}

# GitHub-style language breakdown: stacked bar + colored legend (proportional
# widths, linguist colors). Pass any tokei args, e.g. `ghlang src/`.
ghlang() {
  tokei -o json "$@" \
    | jq -r '
        to_entries
        | map(select(.key != "Total" and .key != "Markdown"))
        | map({key: (if .key == "BASH" then "Shell" else .key end), code: .value.code})
        | group_by(.key)
        | map({key: .[0].key, code: (map(.code) | add)})[]
        | "\(.key)\t\(.code)"' \
    | sort -t$'\t' -k2 -rn \
    | awk '
    BEGIN {
      FS = "\t"
      width = 42
      # GitHub linguist colors as "R;G;B"
      col["Go"]="0;173;216"; col["Python"]="53;114;165"; col["QML"]="68;165;28"
      col["JavaScript"]="241;224;90"; col["TypeScript"]="49;120;198"; col["TSX"]="49;120;198"
      col["HTML"]="227;76;38"; col["CSS"]="86;61;124"; col["SCSS"]="198;83;140"; col["Sass"]="165;59;99"
      col["Shell"]="137;224;81"; col["Bash"]="137;224;81"; col["Zsh"]="137;224;81"; col["Fish"]="137;224;81"
      col["C"]="85;85;85"; col["C Header"]="85;85;85"; col["C++"]="243;75;125"; col["C++ Header"]="243;75;125"
      col["Rust"]="222;165;132"; col["Java"]="176;114;25"; col["Kotlin"]="169;123;255"
      col["Ruby"]="112;21;22"; col["Lua"]="0;0;128"; col["Vim Script"]="25;159;75"; col["Vim script"]="25;159;75"
      col["YAML"]="203;23;30"; col["JSON"]="64;64;64"; col["TOML"]="156;66;33"; col["INI"]="215;215;215"
      col["Dockerfile"]="56;77;84"; col["Makefile"]="66;120;25"; col["CMake"]="218;218;218"
      col["Nix"]="126;126;255"; col["Swift"]="240;81;56"; col["PHP"]="79;93;149"; col["Zig"]="236;145;92"
      col["Perl"]="2;152;195"; col["Haskell"]="94;80;134"; col["Elixir"]="110;74;126"; col["Erlang"]="184;57;152"
      col["Go Template"]="0;173;216"; col["Emacs Lisp"]="192;101;219"; col["Clojure"]="219;185;54"
      col["Scala"]="194;45;54"; col["Dart"]="0;180;175"; col["R"]="25;140;190"; col["Julia"]="162;112;186"
      col["SQL"]="227;134;18"; col["GraphQL"]="225;0;152"; col["Svelte"]="255;62;0"; col["Vue"]="65;184;131"
      col["XML"]="0;96;0"; col["Batch"]="192;192;192"; col["PowerShell"]="1;36;86"; col["Assembly"]="110;125;145"
      defcol="110;118;129"
    }
    { name[NR]=$1; code[NR]=$2; sum+=$2 }
    END {
      if (sum == 0) { print "No code found."; exit }
      maxlen = 0
      for (i=1;i<=NR;i++) if (length(name[i])>maxlen) maxlen=length(name[i])
      # segment widths with largest-remainder rounding so they sum to `width`
      used = 0
      for (i=1;i<=NR;i++) {
        raw = code[i]/sum*width
        w[i] = int(raw); frac[i] = raw - w[i]; used += w[i]
      }
      # largest-remainder: hand out the leftover cells to the biggest fractions.
      # This is monotonic, so a bigger percentage never gets a smaller segment.
      # Sub-cell languages get no bar segment (they still show in the legend).
      leftover = width - used
      for (k=0;k<leftover;k++) {
        best=-1; bf=-1
        for (i=1;i<=NR;i++) if (frac[i]>bf) { bf=frac[i]; best=i }
        if (best<0) break
        w[best]++; frac[best]=-1
      }

      bar = ""
      for (i=1;i<=NR;i++) {
        if (w[i]<=0) continue
        c = (name[i] in col) ? col[name[i]] : defcol
        seg = ""
        for (j=0;j<w[i];j++) seg = seg "\xe2\x96\x88"   # full block
        bar = bar "\033[38;2;" c "m" seg "\033[0m"
      }
      printf "\n  %s\n\n", bar

      for (i=1;i<=NR;i++) {
        if (code[i]<=0) continue
        c = (name[i] in col) ? col[name[i]] : defcol
        printf "  \033[38;2;%sm\xe2\x97\x8f\033[0m %-*s \033[2m%5.1f%%\033[0m\n", \
               c, maxlen, name[i], code[i]/sum*100
      }
      print ""
    }'
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
