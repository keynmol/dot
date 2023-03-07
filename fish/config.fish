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
alias gp='git-push'
alias gd='git diff -u .'
alias gcm='git commit -m'
alias scli="scala-cli"
alias repl="scala-cli repl"
alias sbtn="sbt --client"


# Commands to run in interactive sessions can go here
fish_add_path $HOME/.tools
fish_add_path $HOME/.cargo/bin
fish_add_path /opt/homebrew/bin
fish_add_path $HOME/.tools/node-v16.13.1-darwin-arm64/bin/
fish_add_path $HOME/.fly/bin
fish_add_path $HOME/.tools/current_node/bin
fish_add_path $HOME/.tools/sumneko-lua-language-server/bin/

set -gx EDITOR nvim
set -gx VISUAL $EDITOR

set FLY_INSTALL "$HOME/.fly"

function fish_prompt
    set_color FF0
    printf (prompt_pwd)
    set_color brgreen
    printf (fish_git_prompt)
    printf ' '
    set_color FF0
    printf '> '
    set_color normal
end

function clone -a repo_url
    mkdir -p "$repo_url" &&\
    gh repo clone $repo_url $repo_url &&\
    cd $repo_url
end
