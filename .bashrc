source ~/.bash/bash_setup
source ~/.bash/command_options
source ~/.bash/prompt_colors
source ~/.bash/quick_nav
source ~/.bash/asdf
source ~/.bash/direnv
source ~/.bash/ftfc
source ~/.bash/vim
source ~/.bash/golang
source ~/.git-completion.bash
if [ -e ~/.bash/npm ]; then
  source ~/.bash/npm
else
  #echo "You need to create ~/.bash/npm with NPM_TOKEN=«your token»"
  echo
fi
source ~/.bash/github

g
cd ~
