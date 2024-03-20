## define some func,alias,variable in zsh/bash shell script
# ----------------------- shell function ----------------------
# about git stash
cmd_exists() {
    command -v "$@" > /dev/null 2>&1
}
shpo(){
    git stash pop stash@{$1};
}
shap(){
    git stash apply stash@{$1};
}
shsw(){
    git stash show -p stash@{$1};
}
shdr(){
    git stash drop stash@{$1};
}
# get pid of a process, avoid some Linux system cannot use 'pgrep' command
pgre(){
    ps -ef | grep "$1" | grep -v grep | awk '{print$2;}'
}
# print all info
ppre(){
    ps -ef | grep "$1" | grep -v grep
}
# final location of which command
fwhich(){
    local whi=`which $1 2>/dev/null`
    [ $? -eq 0 -a -x ${whi} 2>/dev/null ] && readlink -f ${whi} || echo "Error:${whi}"
}
# tar compress/uncompress gzip with pigz
tcpzf(){
    type pigz >/dev/null 2>&1 || { echo "Not install pigz !"; return 1; }
    tar cf - $2 | pigz --fast > $1
}
txpz(){
    type pigz >/dev/null 2>&1 || { echo "Not install pigz !"; return 1; }
    tar --no-same-owner -xf $1 -I pigz
}
dus(){
    du $1 -alh -d1 "$(2>/dev/null >&2 du --apparent-size /dev/null && printf '%s\n' --apparent-size || printf '%s\n' --)" | sort -rh | head -n 21
}
# get real network device local ipv4 address
rlip4(){
    ip -o -4 addr list | grep -Ev '\s(docker|lo)' | awk '{print $4}' | cut -d/ -f1
}
# quickly update(rebase) git repo between local with all remotes
gitur(){
    set -x
    git add `git status -s | grep -vE '^\?\?|  ' | awk '{print$2;}'`
    [ $? -eq 0 ] || return 1

    git commit
    if ! git pull --rebase; then
        echo 'handle conflicts first!'
        return 1
    fi

    remote_arr=(`git remote`)
    for var in ${remote_arr[*]}; do
        git push --all $var
    done
}
jnl(){
    journalctl -eu $1 | less +G
}
jfxeu(){
    journalctl -n 100 -fxeu $1
}
dkcid(){
    docker ps -qf "name= $1\$"
}
dktty(){
    ctner_count=`dkcid $1 | wc -l`
    if [ $ctner_count -ne 1 ]; then
        echo "ERROR: $ctner_count container(s) found, cannot exec shell!";
        return 1
    fi
    shell_arr=("bash" "sh" "zsh" "fish" "ash")
    for var in ${shell_arr[*]}; do
        docker exec -ti $1 /bin/$var && return 0
    done
}
qipjq(){
    curl -S ip-api.com/json/$1 2>/dev/null | jq '.'
}
cdt() {
    if [[ ! -e $1 ]]; then
        echo "Error: The file or directory does not exist."
        return 1
    fi

    if [[ -d $1 ]]; then
        cd "$1"
    elif [[ -f $1 ]]; then
        cd "$(dirname "$1")"
    else
        echo "Error: Not a file or directory."
        return 1
    fi
}
cpv() {
    rsync -pogbr -hhh --backup-dir="/tmp/rsync-${USERNAME}" -e /dev/null --progress "$@"
}
# compdef _files cpv

# ----------------------- alias ----------------------
# git
alias gta="git status"
alias gts="git status -s"
alias gtun="git status uno"

alias gcm="git commit"
alias gcmm="git commit -m"
alias gcma="git commit -a"
alias gcmn="git commit --amend"
alias gcman="git commit -a --amend"

alias gpl="git pull"
alias gplrb="git pull --rebase"

alias gsh="git stash"
alias gshl="git stash list"

alias grs="git reset"
alias grsh="git reset --hard"
alias grss="git reset --soft"
alias gstag="git restore --staged"

alias glg="git log --pretty=format:'%Cred%h%Creset -%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset %C(yellow)%d' --abbrev-commit --color"
alias glp="git log --pretty=format:'%Cred%h%Creset -%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset %C(yellow)%d' --abbrev-commit --color --graph"
alias glh="git log --pretty=format:'%Cred%h%Creset -%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset %C(yellow)%d' --abbrev-commit --color --graph | head -30"

alias gdf="git diff"
alias gdfh="git diff HEAD"
alias gdfc="git diff --cached"
alias gbr="git branch"
alias gba="git branch -a"
alias gtl="git tag --list"
alias gck="git checkout"
alias grt="git remote -v"
alias gblm="git blame -L"
alias gaprj="git apply --reject"
# tar
alias tarx="tar --no-same-owner -xf"
alias tarz="tar zcf"

# systemctl
alias syta="systemctl status"
alias syst="sudo systemctl start"
alias syrs="sudo systemctl restart"
alias syte="sudo systemctl stop"
alias syrld="sudo systemctl reload"
alias syen="sudo systemctl enable"
alias syenw="sudo systemctl enable --now"
alias sydis="sudo systemctl disable"
alias sydisw="sudo systemctl disable --now"
alias sydmrld="sudo systemctl daemon-reload"

# cmake
export BUILD_DIR="./build"
alias cmkln="rm -rf ${BUILD_DIR}/CMakeCache.txt ${BUILD_DIR}/CMakeFiles/"
alias cmkr="cmake -B${BUILD_DIR} -G 'Ninja' -DCMAKE_BUILD_TYPE=Release"
alias cmkd="cmake -B${BUILD_DIR} -G 'Ninja' -DCMAKE_BUILD_TYPE=Debug"
alias cmba="cmake --build ${BUILD_DIR}"
alias cmbt="cmake --build ${BUILD_DIR} -t"

# docker
if cmd_exists perl; then
    alias dps="docker ps --format 'table {{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}' | perl -pe 's/, :::.*?p//g'"
else
    alias dps="docker ps --format 'table {{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}'"
fi

alias dpz="docker ps --format 'table {{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Size}}'"

# docker-compose
# if cmd_exists docker-compose; then
#     export CPO_YML="/var/dkcmpo/docker-compose.yml"
#     alias dkcpo="docker-compose -f $CPO_YML"
#     alias dkcps="docker-compose -f $CPO_YML ps"
# fi

export DKCP_DIR="/var/dkcmpo"

_get_dcp_file() {
    if [[ -z "$1" ]]; then
        echo "input para"
        return 1
    fi
    if [[ -z "$DKCP_DIR" ]]; then
        local DKCP_DIR=`pwd`
    fi
    local ext1=docker-compose.yml
    local ext2=docker-compose.yaml

    if [[ -e "$DKCP_DIR/$1/$ext1" ]]; then
        echo "$DKCP_DIR/$1/$ext1"
        return 0
    fi
    if [[ -e "$DKCP_DIR/$1/$ext2" ]]; then
        echo "$DKCP_DIR/$1/$ext2"
        return 0
    fi
    ## try to grep
    local matched_file=`find $DKCP_DIR -maxdepth 3 -type f -name $ext1 -o -name $ext2 | xargs grep -El "[ ]+$1:$" | head -1`
    if [ $? -ne 0 ]; then
        echo "cannot find any y(a)ml files matched this service"
        return 1
    fi

    echo $matched_file
}

# pacman (archlinux/manjaro)
if cmd_exists pacman; then
    alias pkgins="sudo pacman -Sy"
    alias pkguni="sudo pacman -R"
    alias pkgss="pacman -Ss"
    alias pkgsi="pacman -Si"
    alias pkgssq="pacman -Ssq"
    alias pkgqs="pacman -Qs"
    alias pkgqi="pacman -Qi"
    alias pkgql="pacman -Ql"
    alias pkgqo="pacman -Qo"
fi

[[ -z "$LS_OPTIONS" ]] && export LS_OPTIONS="--color=auto"
alias ls="ls -A $LS_OPTIONS"
alias ll="ls -AlFh"
alias l="ls -AlF"
alias la="ls -alF"

# other shell
alias pingk="ping -c4"
alias gdb="gdb -q"
alias cp="cp -arvf"
alias less="less -R"
alias df="df -Th"

cmd_exists trash && alias rm="trash" && alias rrm="\rm -rf"
cmd_exists xclip && alias pbcopy="xclip -selection clipboard" && alias pbpaste="xclip -selection clipboard -o"
cmd_exists fd && alias fd="fd -HI"
cmd_exists tree && alias trelh="tree -AlFh" && alias treds="tree -hF --du --sort=size | more"

alias grep >/dev/null 2>&1 || alias grep="grep --color=auto"
alias thupipins="pip install -i https://pypi.tuna.tsinghua.edu.cn/simple"

_get_short_pwd(){
    # echo -n `pwd | sed -e "s!$HOME!~!" | sed "s:\([^/]\)[^/]*/:\1/:g"`
    split=5
    W=$(pwd | sed -e "s!$HOME!~!")
    # W=${PWD/#"$HOME"/~}
    total_cnt=$(echo $W | grep -o '/' | wc -l)
    last_cnt=$(($total_cnt-1))
    if [ $total_cnt -gt $split ]; then
        echo $W | cut -d/ -f1-2 | xargs -I{} echo {}"/…/$(echo $W | cut -d/ -f${last_cnt}-)"
    else
        echo $W
    fi
}

_bash_prompt_cmd(){
    [[ $? -eq 0 ]] && local ps1ArrowFgColor="92" || local ps1ArrowFgColor="91"
    local shortPwd=`_get_short_pwd`
    PS1="\[\e[0m\]\[\033[0;32m\]\A \[\e[0;36m\]${shortPwd} \[\e[0;${ps1ArrowFgColor}m\]\\$\[\e[0m\] "
}

if [[ -n "$BASH_VERSION" ]]; then
    # PROMPT_DIRTRIM=2
    PROMPT_COMMAND=_bash_prompt_cmd
    HISTCONTROL=ignoreboth
    shopt -s histappend
    export HISTTIMEFORMAT='%F %T `whoami` '
elif [[ -n "$ZSH_VERSION" ]]; then
    setopt promptsubst
    # 不保存重复的历史记录项
    setopt hist_save_no_dups
    setopt hist_ignore_dups
    setopt hist_ignore_space
    setopt hist_reduce_blanks
    setopt hist_fcntl_lock 2>/dev/null
    # modify default PROMPT
    if [[ "$PROMPT" =~ "^# " ]]; then
        PROMPT='%F{cyan}%(6~|%-1~/…/%4~|%5~)%f %(?.%F{green}.%F{red})%B>%b%f '
    fi
    if [[ ! -n "$RPROMPT" ]]; then
        RPROMPT='%F{red}%(?..%?)%f %F{yellow}%n@%l %F{white}%*%f'
    fi
fi

# ----------------------- export some env var -------------------------
export HISTSIZE=10000
export SAVEHIST=10000
export VISUAL=vim
export EDITOR=vim

local_inc=$HOME/.local/include
if [ -d $local_inc ]; then
    [[ ! $C_INCLUDE_PATH =~ $local_inc ]] && export C_INCLUDE_PATH=$C_INCLUDE_PATH:$local_inc
    [[ ! $CPLUS_INCLUDE_PATH =~ $local_inc ]] && export CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH:$local_inc
fi
unset local_inc
