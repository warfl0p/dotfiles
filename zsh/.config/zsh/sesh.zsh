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
          --prompt '⚡  ' \
          --bind 'change:first'
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

# ctrl space to run claude
_run_claude() {
  BUFFER="claude"
  zle accept-line
}
zle -N _run_claude
bindkey '^@' _run_claude
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
