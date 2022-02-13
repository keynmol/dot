if status is-interactive
end

alias l='exa -la --icons'
alias ls='exa'
alias tree='exa -T'
alias weather='curl wttr.in/london'
alias v="nvim"
alias new-sbt='g8 scala/scala-seed.g8'
alias gst='git status .'
alias gfu='git fetch upstream'
alias gp='git-push-origin'
alias gd='git diff -u .'
# alias gmum='git merge upstream/main'
alias scli="scala-cli"

# Commands to run in interactive sessions can go here
fish_add_path $HOME/.tools
fish_add_path $HOME/.cargo/bin
fish_add_path /opt/homebrew/bin

set -gx EDITOR nvim
set -gx VISUAL $EDITOR
