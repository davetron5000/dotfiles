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
export PATH=/usr/local/bin:${PATH}:${HOME}/bin
export GREP_OPTIONS='--color=auto'

source ~/.git-completion.bash
if [ -e ~/.ls.bashrc ]; then
  source ~/.ls.bashrc
fi

function mysqld()
{
    if [ -z $1 ] ; then
        echo "usage: mysqld [start|stop]";
        return -1;
    else
        if [ $1 == "start" ] ; then
            sudo -b mysqld_safe
        elif [ $1 == "stop" ] ; then
            sudo mysqladmin shutdown
        fi
    fi
}
function mobile() {
  unmount "/Volumes/External Backup"
  unmount "/Volumes/Laptop Backup"
  unmount "/Volumes/Lion"
  unmount "/Volumes/Time Machine"
}

function unmount() {
  dir=$1
  if [ -e "${dir}" ]; then
    diskutil unmount "${dir}"
  fi
}

alias vi='mvim'
alias psi='/opt/psi/bin/psi'
alias ls='ls -FG'
alias irb=pry

complete -F get_go_targets go

function get_go_targets()
{
    if [ -z $2 ] ; then
        COMPREPLY=(`\ls -1 ~/Projects | sed 's/\/$//'`)
    else
        COMPREPLY=(`\ls -1 ~/Projects | sed 's/\/$//' | grep "^$2"`)
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

source /usr/local/bin/virtualenvwrapper.sh

go 
cd ~

[[ -s $HOME/.rvm/scripts/rvm ]] && source $HOME/.rvm/scripts/rvm


PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"
