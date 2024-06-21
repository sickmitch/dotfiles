# ~/.zshrc

##Title

# Function to set terminal title
function set_title() {
  print -Pn "\e]0;$1\a"
}
# Precmd hook to set the title to the current command
precmd() {
  set_title "${USER}@${HOSTNAME}: %~"
}
# Add function to update title for each command executed
TRAPUSR1() {
  set_title "${USER}@${HOSTNAME}: ${1}"
}

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias grep='grep --color=auto'
alias nv='nvim'
alias vi='vim'
alias cat='bat'
alias neofetch='fastfetch'
alias bt='pacmd set-card-profile bluez_card.00_1B_66_0F_3D_F0 a2dp_sink'

##zsh

autoload -U compinit; compinit
source ~/.config/znap/fzf-tab/fzf-tab.plugin.zsh

##Eternal history 

#use a history file in here
HISTFILE=${ZDOTDIR:-$HOME}/.zsh_history
# make it huge, really huge.
SAVEHIST=1000000
HISTSIZE=1000000

# there is for sure still some redundancy, but ...
# setopt BANG_HIST                 # Treat the '!' character specially during expansion.
# setopt EXTENDED_HISTORY          # Write the history file in the ":start:elapsed;command" format.
setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first when trimming history.
setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate.
setopt HIST_FIND_NO_DUPS         # Do not display a line previously found.
setopt HIST_IGNORE_SPACE         # Don't record an entry starting with a space.
setopt HIST_SAVE_NO_DUPS         # Don't write duplicate entries in the history file.
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks before recording entry.
#setopt HIST_VERIFY               # Don't execute immediately upon history expansion.
#setopt HIST_BEEP                 # Beep when accessing nonexistent history.

alias history="history 0"

## styling

# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# set descriptions format to enable group support
# NOTE: don't use escape sequences here, fzf-tab will ignore them
zstyle ':completion:*:descriptions' format '[%d]'
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':completion:*' menu no
# preview directory's content with eza when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
# switch group using `<` and `>`
zstyle ':fzf-tab:*' switch-group '<' '>'
# Download Znap, if it's not there yet.
[[ -r ~/.config/znap/znap.zsh ]] ||
    git clone --depth 1 -- \
        https://github.com/marlonrichert/zsh-snap.git ~/.config/znap
source ~/.config/znap/znap.zsh  # Start Znap

#HISTORY
#HISTFILE=~/.zsh_history
#HISTSIZE=10000
#SAVEHIST=10000
#setopt SHARE_HISTORY

# for pattern search (the wildcard `*` will use zsh completion)
bindkey "^R" history-incremental-pattern-search-backward

# ---- Eza (better ls) -----
alias ls="eza --color=always --git --icons auto"
alias ll="eza --color=always --long --git --icons=always"

# Autojump
if [ -f "/usr/share/autojump/autojump.zsh" ]; then
  . /usr/share/autojump/autojump.zsh
elif [ -f "/usr/share/autojump/autojump.sh" ]; then
  . /usr/share/autojump/autojump.sh
else
  echo "can't find the autojump script"
fi

## ---- FZF -----

# Set up fzf key bindings and fuzzy completion
eval "$(fzf --zsh)"

# -- Use fd instead of fzf --

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

# Use fd (https://github.com/sharkdp/fd) for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git . "$1"
}

source ~/github/fzf-git.sh/fzf-git.sh

# --- Setup fzf theme ---
fg="#CBE0F0"
# bg="#011628"
bg_highlight="#143652"
purple="#B388FF"
blue="#06BCE4"
cyan="#2CF9ED"

export FZF_DEFAULT_OPTS="--color=fg:${fg},hl:${purple},fg+:${fg},bg+:${bg_highlight},hl+:${purple},info:${blue},prompt:${cyan},pointer:${cyan},marker:${cyan},spinner:${cyan},header:${cyan}"

show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"

export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo ${}'"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    *)            fzf --preview "$show_file_or_dir_preview" "$@" ;;
  esac
}

# ----- Bat (better cat) -----

export BAT_THEME="Catppuccin Mocha"

eval "$(oh-my-posh init zsh --config ~/.config/omp/zen.toml)"

