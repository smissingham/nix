# Smissingham's Dendritic Zsh Config

bindkey -r '^L'
bindkey -r '^J'

autoload -Uz compinit

eval "$(atuin init zsh)"
eval "$(starship init zsh)"
eval "$(tv init zsh)"
eval "$(zoxide init zsh)"
