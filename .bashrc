set -o vi
shopt -s cdspell
shopt -s histappend
if [ -t 0 ] ; then
    stty erase 
fi
export FIGNORE=~:.bak:.tmp:.swp
export HISTCONTROL=ignoredups
export LANG=en_US

export CLASSPATH=
export EDITOR=vim
export GREP_OPTIONS='--exclude=\*\.svn\*'
export JAVA_ROOT=/System/Library/Frameworks/JavaVM.framework/Versions
export PATH=${PATH}:${HOME}/bin

source ~/.git-completion.bash

function mysqld()
{
    if [ -z $1 ] ; then
        echo "usage: mysqld [start|stop]";
        return -1;
    else
        if [ $1 == "start" ] ; then
            sudo -b /usr/local/mysql/bin/mysqld_safe
        elif [ $1 == "stop" ] ; then
            sudo /usr/local/mysql/bin/mysqladmin shutdown
        fi
    fi
}

alias vi='mvim'
alias psi='/opt/psi/bin/psi'
alias ps='ps auxwwwwwwww'
alias ls='ls -FG'
export MYSQL_EXE='/usr/local/mysql/bin/mysql --show-warnings'
alias mysql=$MYSQL_EXE

complete -F get_gliffy_targets gliffy
function get_gliffy_targets() 
{
    if [ -z $2 ] ; then
        COMPREPLY=(`gliffy help -c`)
    else
        COMPREPLY=(`gliffy help -c $2`)
    fi
}
complete -F get_go_targets go

function get_go_targets()
{
    if [ -z $2 ] ; then
        COMPREPLY=(`ls -1 ~/Projects | sed 's/\/$//'`)
    else
        COMPREPLY=(`ls -1 ~/Projects | sed 's/\/$//' | grep "^$2"`)
    fi
}

PROMPT_BLACK="\[\033[1;30m\]"
PROMPT_BOLD_RED="\[\033[1;31m\]"
PROMPT_BOLD_GREEN="\[\033[1;32m\]"
PROMPT_BOLD_YELLOW="\[\033[1;33m\]"
PROMPT_BOLD_CYAN="\[\033[1;34m\]"
PROMPT_BOLD_MAGENTA="\[\033[1;35m\]"
PROMPT_BOLD_GREY="\[\033[1;36m\]"
PROMPT_BOLD_WHITE="\[\033[1;37m\]"
PROMPT_RED="\[\033[0;31m\]"
PROMPT_GREEN="\[\033[0;32m\]"
PROMPT_YELLOW="\[\033[0;33m\]"
PROMPT_CYAN="\[\033[0;34m\]"
PROMPT_MAGENTA="\[\033[0;35m\]"
PROMPT_GREY="\[\033[0;36m\]"
PROMPT_WHITE="\[\033[0;37m\]"
PROMPT_RESET="\[\033[0m\]"
case $TERM in
    xterm*)
    TITLEBAR="\[\e]0;\u@\h:\w\007\]"
    ;;
    *)
    TITLEBAR=""
    ;;
esac

function go()
{
    if [ ! -z $1 ]; then
        GO_TARGET=$1
        if [ -d ~/Projects/$GO_TARGET ] ; then
            GO_DIR=~/Projects/$GO_TARGET
        else
            echo "$GO_TARGET not found!"
            return;
        fi
        export CURRENT_PROJECT=$GO_TARGET
        if [ ! -z $3 ];  then
            if [ ! -z $4 ]; then
                alias vi="mvim --cmd 'let g:project_root=\"$3\"' --cmd 'let g:build_file=\"$4\"' \$*"
            else
                alias vi="mvim --cmd 'let g:project_root=\"$3\"' \$*"
            fi
        else
            alias vi="mvim --cmd 'let g:project_root=\"$GO_DIR\"' \$*"
        fi
        if [ $1 == 'pose' ]; then
            alias vi="mvim --cmd 'let g:pose=\"true\"' \$*"
        fi
    fi
    colorless_update_prompt $GO_TARGET

    cd $GO_DIR
}

function colorless_update_prompt()
{
    #PS1_START='⎛ \u@\h '
    PS1_START='⎛ '
    if [ -z $1 ]; then
      PS1_TARGET=" "
    else
      PS1_TARGET="«$1» "
    fi
    PS1_GIT='$(__git_ps1 "⎇ %s") '
    PS1_RVM='$(rvm-prompt v i g )'
    #PS1_DIR='\w> '
    PS1_DIR='\w ❺➠ '
    PS1_LASTLINE="\n⎝ "
    export PS1=$PROMPT_BOLD_WHITE$PS1_START$PROMPT_YELLOW$PS1_TARGET$PROMPT_BOLD_GREEN$PS1_RVM$PROMPT_BOLD_WHITE$PROMPT_MAGENTA$PS1_GIT$PROMPT_BOLD_WHITE$PS1_LASTLINE$PS1_DIR$PROMPT_RESET
}

function update_prompt()
{
    PS1_START='\[\033[0;35m\]\u@\[\033[1;37m\]\h '
    PS1_TARGET="\[\033[1;36m\][$1]\n"
    PS1_GIT='\[\033[1;33m\]$(__git_ps1 "git://%s")\[\033[0;32m\] '
    #PS1_DIR='\[\033[0;32m\]\w> '
    PS1_DIR='\033[1;37m\]\w❺➠\033[0;37m\] '
    export PS1=$PS1_START$PS1_TARGET$PS1_GIT$PS1_DIR
}

##
# Your previous /Users/davec/.profile file was backed up as /Users/davec/.profile.macports-saved_2009-10-12_at_19:01:00
##
go 
cd ~

[[ -s $HOME/.rvm/scripts/rvm ]] && source $HOME/.rvm/scripts/rvm

