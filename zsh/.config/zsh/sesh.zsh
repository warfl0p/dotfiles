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
