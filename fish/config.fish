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
alias n="nvim"
alias j="cd (fd -d 2 -t d '' ~/projects | fzf)"


# Commands to run in interactive sessions can go here
fish_add_path $HOME/.tools
fish_add_path $HOME/.cargo/bin
fish_add_path /opt/homebrew/bin
# fish_add_path $HOME/.tools/node-v16.13.1-darwin-arm64/bin/
fish_add_path $HOME/.fly/bin
# fish_add_path $HOME/.tools/current_node/bin
fish_add_path $HOME/Library/Application\ Support/Coursier/bin
fish_add_path $HOME/.sg
fish_add_path $HOME/go/bin

set -gx EDITOR nvim
set -gx VISUAL $EDITOR

set FLY_INSTALL "$HOME/.fly"

export SRC_ENDPOINT='https://sourcegraph.com'
export SRC_ACCESS_TOKEN=(cat ~/.sourcegraph-tk 2> /dev/null || echo "not set")

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

function start -a repo_url
    cd $HOME/projects &&\
    mkdir -p "$repo_url" &&\
    gh repo clone $repo_url $repo_url &&\
    cd $repo_url &&\
    nvim . 
end

function new_project -a repo_url
    gh repo create $repo_url --private &&\
    start $repo_url
end


# The next line updates PATH for the Google Cloud SDK.
if [ -f "$HOME/.tools/google-cloud-sdk/path.fish.inc" ]; . "$HOME/.tools/google-cloud-sdk/path.fish.inc"; end

set PATH $PATH $HOME/.sbt/1.0/bin
