source ~/.bash/bash_setup
source ~/.bash/command_options
source ~/.bash/prompt_colors
source ~/.bash/quick_nav
source ~/.bash/go
source ~/.bash/asdf
source ~/.bash/direnv
source ~/.bash/ftfc
source ~/.git-completion.bash
if [ -e ~/.bash/npm ]; then
  source ~/.bash/npm
else
  echo "You need to create ~/.bash/npm with NPM_TOKEN=«your token»"
fi
source ~/.bash/github

g
cd ~
