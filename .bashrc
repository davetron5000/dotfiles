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
export PATH_BASE=${PATH}:${ANT_HOME}/bin:${HOME}/bin:${CXOFFICE_HOME}/bin:/opt/local/bin
export PATH=${PATH_BASE}
export JAVA_ROOT=/System/Library/Frameworks/JavaVM.framework/Versions
export TOMCAT_HOME=/Applications/tomcat

function go_gliffy()
{
    JAVA=Java5
    if [ -z $1 ] ; then
        export JAVA_HOME=$JAVA_ROOT/CurrentJDK/Home
    else
        export JAVA_HOME=$JAVA_ROOT/1.4.2/Home
        JAVA=Java1.4.2
    fi
    export PATH=$JAVA_HOME/bin:$PATH_BASE
    go gliffy.git $JAVA ~/Projects/gliffy.git/svnroot/gliffy online/build.xml
}

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

function tomcat()
{
    if [ -z $1 ] ; then
        echo "usage: tomcat [start|stop]";
        return -1;
    else
        if [ $1 == "start" ] ; then
            $TOMCAT_HOME/bin/startup.sh
        elif [ $1 == "stop" ] ; then
            $TOMCAT_HOME/bin/shutdown.sh
        elif [ $1 == "log" ] ; then
            open -a /Applications/Utilities/Console.app $TOMCAT_HOME/logs/catalina.out
        fi
    fi
}

alias vi='gvim'
alias gem_server="ruby -r rubygems/server -e 'Gem::Server.run(:gemdir=>\"/Library/Ruby/Gems/1.8\",:port=>8088)'"
alias psi='/opt/psi/bin/psi'
alias ps='ps auxwwwwwwww'
alias ls='ls -F'
alias mysql='/usr/local/mysql/bin/mysql'

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
        if [ ! -z $3 ];  then
            if [ ! -z $4 ]; then
                alias vi="gvim --cmd 'let g:project_root=\"$3\"' --cmd 'let g:build_file=\"$4\"' \$*"
            else
                alias vi="gvim --cmd 'let g:project_root=\"$3\"' \$*"
            fi
        else
            alias vi="gvim --cmd 'let g:project_root=\"$GO_DIR\"' \$*"
        fi
        alias tailjboss='tail -f $JBOSS_LOG'
    fi

    if [ ! -z $2 ]; then
        export PS1="${TITLEBAR}[\@] ${PROMPT_MAGENTA}\u${PROMPT_BOLD_WHITE}${PROMPT_GREY}\w\n${PROMPT_WHITE} [$GO_TARGET: ($2)]->${PROMPT_GREEN}"
    else
        export PS1="${TITLEBAR}[\@] ${PROMPT_MAGENTA}\u${PROMPT_BOLD_WHITE}${PROMPT_GREY}\w\n${PROMPT_WHITE} [$GO_TARGET:]->${PROMPT_GREEN}"
    fi
    cd $GO_DIR
}

go 
cd ~
