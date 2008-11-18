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
export CVSEDITOR="gvim -f"
export SVN_ROOT=svn+ssh://homer/svn
export R=${SVN_ROOT}
export EDITOR=vim
export IFX_JDBC_HOME=/usr/local/ifxjdbc
export INNO_HOME=/Users/davec/.cxoffice/dotwine/fake_windows/Program\ Files/Inno\ Setup\ 4/
export JBOSS_HOME=/opt/jboss
export CXOFFICE_HOME=/opt/cxoffice
export WINE=${CXOFFICE_HOME}/bin/wine
export XDOCLET_HOME=/usr/local/xdoclet
export GREP_OPTIONS='--exclude=\*\.svn\*'
export PATH_BASE=${PATH}:${ANT_HOME}/bin:${HOME}/bin:${CXOFFICE_HOME}/bin:/opt/local/bin
export PATH=${PATH_BASE}
export JAVA_ROOT=/System/Library/Frameworks/JavaVM.framework/Versions
export TOMCAT_HOME=/Applications/tomcat

function gliffy()
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

XTERM_HOSTS_DB="$HOME/.hosts.db"

alias vi='gvim'
alias gem_server="ruby -r rubygems/server -e 'Gem::Server.run(:gemdir=>\"/Library/Ruby/Gems/1.8\",:port=>8088)'"
alias psi='/opt/psi/bin/psi'
alias ps='ps auxwwwwwwww'
alias ls='ls -F'
alias tailweblogic='tail -f $BEA_HOME/wlserver6.1/config/mydomain/logs/weblogic.log'
alias vijboss='vi $JBOSS_LOG'
alias runproduction='cd ~/bin/jdis/jdisapp ; ./run.sh ; cd -'
alias ftphah='ncftp hah'
alias ftpdissonance='ncftp dis'
alias ftpnd5='ncftp nd5'
alias ftpsupercade='ncftp supercade'

alias gwin='cd ~/jdis/client ; ./run.sh ; cd -'
alias gwintrainer='cd ~/jdis/pilot ; ./trainer.sh ; cd -'
alias gwinpilot='cd ~/jdis/pilot ; ./run.sh ; cd -'
alias runlocal=gwin
alias mysql='/usr/local/mysql/bin/mysql'

complete -W "start stop log status" jboss
complete -W "start stop log status" weblogic
complete -F get_xterm_hosts xt
complete -F get_go_targets go
complete -F get_sqlshell_targets sqlshell.pl

function get_sqlshell_targets()
{
    if [ -z $2 ] ; then
        COMPREPLY=(`ls -1 ~/.sqlshell | sed 's/\@$//'`)
    else
        COMPREPLY=(`ls -1 ~/.sqlshell | sed 's/\@$//' | grep "^$2"`)
    fi
}
function get_go_targets()
{
    if [ -z $2 ] ; then
        COMPREPLY=(`ls -1 ~/Projects | sed 's/\/$//'`)
    else
        COMPREPLY=(`ls -1 ~/Projects | sed 's/\/$//' | grep "^$2"`)
    fi
}

function get_xterm_hosts()
{
    if [ -z $2 ] ; then
        COMPREPLY=(`/bin/cat $XTERM_HOSTS_DB | cut -d':' -f1`)
    else
        COMPREPLY=(`/bin/cat $XTERM_HOSTS_DB | cut -d':' -f1 | grep "^$2"`)
    fi
}

function ftp()
{
    if [ -z $3 ] ; then
        echo "ftp user password host"
        return -1
    fi

    local DOJ_HOST=149.101.10.100
    local DOJ_PORT=2100

    FTP_USER=$1
    FTP_PASS=$2
    FTP_HOST=$3

    ncftp -u $FTP_USER@$FTP_HOST -p $FTP_PASS -P $DOJ_PORT $DOJ_HOST
}

function jboss()
{
    local USAGE="Usage: jboss server_name \[start|stop|stat\] {force}"
    if [ -z $1 ]; then
        echo $USAGE
        return
    fi
    if [ -z $2 ]; then
        echo $USAGE
        return
    fi
    local PORT=1099
    if [ $2 == "stop" ] ; then
        if [ $1 == "development" ]; then
            PORT=1199
        else 
            if [ $1 != "head" ] ; then
                echo "Server $2 unknown.  Cannot determine which port to connect to for shutdown"
            fi
        fi
    fi
    local COUNT=`ps | grep org.jboss.Main | grep "c $1" | grep -v grep | wc -l`
    local FORCE=
    if [ ! -z $3 ] && [ $3 == "force" ] ; then
        FORCE=true
    fi
    case "$2" in
        start)
        if [ $COUNT == 0 ] || [ ! -z $FORCE ]; then
            cd $JBOSS_HOME/bin
            ./run.sh -c $1 > /tmp/jboss.start.$$.log 2>&1 &
            cd -
            return
        else
            echo JBoss already running.  Not starting.
        fi
        ;;
        stop)
        if [ $COUNT != 0 ] || [ ! -z $FORCE ]; then
            cd $JBOSS_HOME/bin
            ./shutdown.sh -s `hostname -i`:${PORT}
            cd -
        else
            echo JBoss not running.  Not stopping.
        fi
        ;;
        log)
        tail -f $JBOSS_HOME/server/$1/log/server.log
        ;;
        stat*)
        if [ $COUNT == 0 ] ; then
            echo JBoss not running
        else
            echo "JBoss running with pid `ps | grep org.jboss.Main | grep "c $1" | grep -v grep | awk '{print $2}'`"
        fi
        ;;
        *)
        echo "usage; jboss {start|stop|log|status} [force]"
        ;;
    esac

}

# Launches an xterm to the given host, using $XTERM_HOSTS_DB as the db for usernames and colors
function xt()
{
    if [ -z $1 ] ; then
        xterm -fg green -bg black -sb &
        return
    fi

    if [ $1 == "-h" ] || [ $1 == "--help" ] ; then
        echo "xterm [host] [username] [fg color]"
        return
    fi
    
    local XTERM_USERNAME=${2:-davec}
    local XTERM_COLOR=${3:-cyan}
    local XTERM_HOST=$1

    DB_ENTRY=`grep ${1}: $XTERM_HOSTS_DB`
    if [ -z $DB_ENTRY ] ; then
        XTERM_COLOR=red
    else
        if [ -z $2 ] ; then
            XTERM_USERNAME=`echo "$DB_ENTRY" | cut -d':' -f2`
        fi
        if [ -z $3 ] ; then
            XTERM_COLOR=`echo "$DB_ENTRY" | cut -d':' -f3`
        fi
    fi
    xterm -fg $XTERM_COLOR -bg black -sb -title "$1" -e ssh $XTERM_USERNAME@$XTERM_HOST &
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

#function sqlplusplus()
#{
#    alias vi="gvim --cmd 'let g:project_root=\"/home/davec/Projects/sqlplusplus/work\"' $*"
#    export PS1="${TITLEBAR}[\@] ${PROMPT_MAGENTA}\u${PROMPT_BOLD_WHITE}@${PROMPT_GREY}\h${PROMPT_WHITE}:${PROMPT_BOLD_CYAN}\w\n${PROMPT_WHITE} [sqlplusplus]->${PROMPT_GREEN}"
#}
go 
cd ~
