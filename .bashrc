# This is because fucking Apple has no respect for their users
# and has to tell them that zsh is the default.  FUCK YOU.
export BASH_SILENCE_DEPRECATION_WARNING=1
eval "$(/opt/homebrew/bin/brew shellenv)"
source ~/.bash/bash_setup
source ~/.bash/command_options
source ~/.bash/prompt_colors
source ~/.bash/quick_nav
source ~/.bash/direnv
source ~/.bash/ftfc
source ~/.bash/vim
<<<<<<< HEAD
source ~/.bash/golang
source ~/.bash/user_rubygems
source ~/.bash/aliases
=======
source ~/.bash/conda
>>>>>>> master
source ~/.git-completion.bash
if [ -e ~/.bash/npm ]; then
  source ~/.bash/npm
else
 #echo "You need to create ~/.bash/npm with NPM_TOKEN=«your token»"
  echo
fi
<<<<<<< HEAD
source ~/.bash/github
#g
#cd ~
colorless_update_prompt
=======

g

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init.bash 2>/dev/null || :
>>>>>>> master
