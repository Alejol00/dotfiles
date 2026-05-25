# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source ~/.local/share/omarchy/default/bash/rc

# Add your own exports, aliases, and functions here.
#
# Make an alias for invoking commands you use constantly
# alias p='python'
export EDITOR=hx
export VISUAL=hx
export EDITOR=helix
export VISUAL=helix
alias hx=helix


# Added by Antigravity CLI installer
export PATH="/home/alejo/.local/bin:$PATH"
