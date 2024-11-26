# theme
background() {
    echo "%{$bg[$1]%}$2%{$reset_color%}"
}

last_background() {
    echo "%(?:%{$bg[$1]%}:%{$bg[red]%})$2%{$reset_color%}"
}

foreground() {
    echo "%{$fg[$1]%}$2%{$reset_color%}"
}

arrow() {
    echo $(background $1 $(foreground $2 " $4 "))$(background $3 $(foreground $1 ''))
}

last_arrow() {
    echo $(background $1 $(foreground $2 " $4 "))$(last_background $3 $(foreground $1 ''))
}

BLACK='black'
WHITE='white'
NONE='none'

COLOR_NAME='blue'
COLOR_DIRECTORY='magenta'
COLOR_GIT='cyan'
COLOR_NVM='green'
COLOR_ERROR='red'

ERROR=$(arrow $COLOR_ERROR $BLACK $NONE '✗ %?')
ERROR_ARROW="%(?::$ERROR)"
LINE1_PREFIX=$(foreground $COLOR_NAME '┌')
LINE2_PREFIX=$(foreground $COLOR_NAME '└─')$(foreground $WHITE '$')

ZSH_THEME_GIT_PROMPT_PREFIX=' '
ZSH_THEME_GIT_PROMPT_SUFFIX=''
ZSH_THEME_GIT_COMMITS_AHEAD_PREFIX='↑'
ZSH_THEME_GIT_COMMITS_BEHIND_PREFIX='↓'

git_remote_status() {
    echo "$(git_commits_ahead)$(git_commits_behind)"
}

git_arrow() {
    echo "%(?:$(arrow $COLOR_GIT $BLACK $NONE $1):$(arrow $COLOR_GIT $BLACK $COLOR_ERROR $1))"
}

prompt() {
    setopt local_options warn_create_global
    echo -n "$LINE1_PREFIX"

    declare -a arrows
    if [[ -n "$SSH_CLIENT" ]]; then
        arrows[1]=($COLOR_NAME '%n@%m')
    else
        arrows[1]=($COLOR_NAME '%n')
    fi
    arrows[3]=($COLOR_DIRECTORY '%~')
    local index=5
    
    if __git_prompt_git rev-parse --get-dir &> /dev/null; then
        local git_prompt="$(_omz_git_prompt_info)"
        local remote_status="$(git_remote_status)"
        if [[ -n $remote_status ]]; then
            git_prompt="$git_prompt $remote_status"
        fi
        arrows[$index]=($COLOR_GIT $git_prompt)
        ((index+=2))
    fi

    local nvm_prompt=$(nvm_prompt_info)
    if [[ -n "$nvm_prompt" ]]; then
        arrows[$index]=($COLOR_NVM "node $nvm_prompt")
    fi

    local i
    for i in {1..${#arrows}..2}; do
        if [[ $i < $((${#arrows} - 2)) ]]; then
            # shellcheck disable=all
            echo -n "$(arrow $arrows[$i] $BLACK $arrows[(($i + 2))] $arrows[(($i + 1))])"
        else
            echo -n "$(last_arrow $arrows[$i] $BLACK $NONE $arrows[(($i + 1))])"
        fi
    done

    echo -n "$ERROR_ARROW\n$LINE2_PREFIX "
}

PROMPT='$(prompt)'

