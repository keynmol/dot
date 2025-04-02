
alias j='cd $(fd . "$HOME/projects" -d 2 -t d | fzf)'
alias n='nvim .'
alias z='zed .'

export FLY_INSTALL="$HOME/.fly"

export PATH="$HOME/.fly/bin:$PATH"
export PATH="$HOME/.fly/bin:$PATH"


function start() {
    local repo_url=$1
    cd $HOME/projects &&\
    if [ ! -d "$repo_url" ]; then
        mkdir -p "$repo_url" &&\
        gh repo clone $repo_url $repo_url
    fi &&\
    cd $repo_url &&\
    zed .
}
function new_project() {
    gh repo create $1 --private &&\
    start $1
}
