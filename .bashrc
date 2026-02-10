# This is because fucking Apple has no respect for their users
# and has to tell them that zsh is the default.  FUCK YOU.
export BASH_SILENCE_DEPRECATION_WARNING=1
eval "$(/opt/homebrew/bin/brew shellenv)"
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

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init.bash 2>/dev/null || :

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/davec/.lmstudio/bin"
# End of LM Studio CLI section


# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/davec/.lmstudio/bin"
# End of LM Studio CLI section

