# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

export ZSH="$HOME/.oh-my-zsh"

#ZSH_THEME="agnosterzak"
ZSH_THEME="jonathan"


plugins=( 
    git
    dnf
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# check the dnf plugins commands here
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/dnf


# Display Pokemon-colorscripts
# Project page: https://gitlab.com/phoneybadger/pokemon-colorscripts#on-other-distros-and-macos
#pokemon-colorscripts --no-title -s -r #without fastfetch
pokemon-colorscripts --no-title -s -r | fastfetch -c $HOME/.config/fastfetch/config-pokemon.jsonc --logo-type file-raw --logo-height 10 --logo-width 5 --logo -

# fastfetch. Will be disabled if above colorscript was chosen to install
#fastfetch -c $HOME/.config/fastfetch/config-compact.jsonc

# Set-up FZF key bindings (CTRL R for fuzzy history finder)
source <(fzf --zsh)

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory

bindkey -v

export WEATHER_UNITS=imperial
# Set-up icons for files/directories in terminal using lsd


# ALIAS
alias ls='lsd'
alias l='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias lt='ls --tree'
alias py="python3"
alias x="exit"
alias ..="cd .."
alias vim="vi"
alias home="cd $HOME"
#alias ssh="kitty +kitten ssh"

export PATH=$PATH:/home/hercules/.spicetify
path=(/snap/bin $path)

if [[ -z "$TMUX" ]]; then
  tmux
fi


. "$HOME/.local/bin/env"

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"

