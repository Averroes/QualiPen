# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# --- Oh My Zsh de base ---
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME=""
source $ZSH/oh-my-zsh.sh

# --- Prompt perso avec date FR + chemin + branche git ---
export LC_TIME=fr_FR.UTF-8
setopt prompt_subst
RPROMPT=''                                  # rien à droite


# Option sûre: hook precmd sans écraser d'autres 'precmd'
autoload -Uz add-zsh-hook vcs_info
add-zsh-hook precmd vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' formats ' (%b)'    # affiche " (branche)"

# Couleurs + format
PROMPT='%F{4}[%D{%d/%m/%Y %H:%M:%S}]%f %F{yellow}[$(hostname)]%f %B%F{magenta}%d%f%b%F{red}${vcs_info_msg_0_}%f %(?.%F{green}#%f.%F{red}#%f) '

plugins=(git z zsh-autosuggestions zsh-syntax-highlighting command-not-found history-substring-search)

source $ZSH/oh-my-zsh.sh

# historique
export HISTFILESIZE=1000000000
export HISTSIZE=1000000000
export HISTTIMEFORMAT="[%F %T] "
setopt INC_APPEND_HISTORY
setopt EXTENDED_HISTORY
setopt HIST_FIND_NO_DUPS


if [ -f "/opt/my_config/.zshrc" ]; then
    source "/opt/my_config/.zshrc"
fi



