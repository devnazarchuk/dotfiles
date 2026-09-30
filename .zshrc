eval "$(starship init zsh)"
alias ls='eza --icons=always'
alias ll='eza -al --icons=always'
alias lt='eza -a --tree --level=1 --icons=always'

# Created by `pipx` on 2026-08-26 06:01:34
export PATH="$PATH:$HOME/.local/bin"

alias knc="killall swaync && swaync &"

#source $HOME/.config/broot/launcher/bash/br
export PATH="$HOME/.cargo/bin:$PATH"

export PATH="$HOME/.local/bin:$PATH"

export PATH=$PATH:$HOME/.spicetify

export EDITOR=nano

# --- KEYBINDINGS & NAVIGATION ---
bindkey -e

# Word navigation with Ctrl + Left / Right
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word

# Word deletion with Ctrl + Backspace / Delete
bindkey '^H' backward-kill-word
bindkey '^[[3;5~' kill-word
bindkey '^[[3~' delete-char

# --- ZSH HISTORY ---
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_SAVE_NO_DUPS
export PATH=~/.npm-global/bin:$PATH
