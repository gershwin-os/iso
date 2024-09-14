# Removing the following line will break Ctrl-A and Ctrl-E
bindkey -e

PROMPT='%n@%m %1~ %# '
autoload -U colors
colors
PS1='%F{blue}%n%f@%F{green}%m%f %F{yellow}%1~%f %# '
alias ls='ls -G'
alias ll='ls -l'
alias la='ls -la'
export EDITOR=nano

# Source GNUstep.sh
source /System/Makefiles/GNUstep.sh

# Create profile folders
xdg-user-dirs-update

# Check if GWorkspace is running
if ! pgrep -x "Workspace" > /dev/null; then
    # Launch startx with Gershwin-X11 script
    startx /System/Library/Scripts/Gershwin-X11
fi
