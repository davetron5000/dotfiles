# This is because fucking Apple has no respect for their users
# and has to tell them that zsh is the default.  FUCK YOU.
export BASH_SILENCE_DEPRECATION_WARNING=1
if [ -f "/opt/homebrew/bin/brew" ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi
source ~/.bash/bash_setup
source ~/.bash/aliases
source ~/.bash/command_options
source ~/.bash/prompt_colors
source ~/.bash/quick_nav
source ~/.bash/direnv
source ~/.bash/ftfc
source ~/.bash/vim
source ~/.bash/cargo
source ~/.bash/jj
source ~/.git-completion.bash
colorless_update_prompt

if [ -f "~/.orbstack/shell/init.bash" ]; then
  # Added by OrbStack: command-line tools and integration
  # This won't be added again if you remove it.
  source ~/.orbstack/shell/init.bash 2>/dev/null || :
fi
