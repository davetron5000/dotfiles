set -o vi
shopt -s cdspell
shopt -s histappend
if [ -t 0 ] ; then
    stty erase 
fi
export FIGNORE=~:.bak:.tmp:.swp
export HISTCONTROL=ignoredups
export LANG=en_US

export ANT_HOME=/opt/ant
export ANT_OPTS=-Xmx640m
export CLASSPATH=
export EDITOR=vim
export GREP_OPTIONS='--exclude=\*\.svn\*'
export SCALA_HOME=/Applications/scala
export PATH_BASE=${PATH}:${SCALA_HOME}/bin:${ANT_HOME}/bin:${HOME}/bin:${CXOFFICE_HOME}/bin:/opt/local/bin
export PATH=${PATH_BASE}
export JAVA_ROOT=/System/Library/Frameworks/JavaVM.framework/Versions
export TOMCAT_HOME=/Applications/tomcat
export R_HOME=/Library/Frameworks/R.framework/Versions/2.8/Resources/

# Positive Energy config

export workspace=/Users/davec/Projects/pose
export SSH_TUNNEL_REMOTE_PORT=5468
export POSE_USER=dave.copeland
if [ -e ~/.passwordsrc ]; then
    . ~/.passwordsrc
fi
source ~/pose.bash
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

function mvn()
{
    /usr/bin/mvn $*
    if [ $? == 0 ]; then
        growlnotify -s -n Maven -m "Build Successful" --image /Users/davec/Pictures/Icons/pass.jpg
    else
        growlnotify -s -n Maven -m "Build FAILED" --image /Users/davec/Pictures/Icons/fail.png
    fi

}

alias vi='mvim'
alias gem_server="ruby -r rubygems/server -e 'Gem::Server.run(:gemdir=>\"/Library/Ruby/Gems/1.8\",:port=>8088)'"
alias psi='/opt/psi/bin/psi'
alias ps='ps auxwwwwwwww'
alias ls='ls -F'
export MYSQL_EXE='/usr/local/mysql/bin/mysql --show-warnings'

function mysql()
{
    if [ -z $1 ]; then
        USER=poseur
        PASS=poseur
    else
        USER=$1
        PASS=$2
    fi

    $MYSQL_EXE -u$USER -p$PASS
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
    update_prompt $GO_TARGET

    cd $GO_DIR
}

function colorless_update_prompt()
{
    PS1_START='\u@\h '
    PS1_TARGET="[$1]\n"
    PS1_GIT='$(__git_ps1 "git://%s") '
    PS1_DIR='\w> '
    export PS1=$PS1_START$PS1_TARGET$PS1_GIT$PS1_DIR
}

function update_prompt()
{
    PS1_START='\[\033[0;35m\]\u@\[\033[1;37m\]\h '
    PS1_TARGET="\[\033[1;36m\][$1]\n"
    PS1_GIT='\[\033[1;33m\]$(__git_ps1 "git://%s")\[\033[0;32m\] '
    #PS1_DIR='\[\033[0;32m\]\w> '
    PS1_DIR='\033[1;37m\]\w>\033[0;37m\] '
    export PS1=$PS1_START$PS1_TARGET$PS1_GIT$PS1_DIR
}

go 
cd ~
