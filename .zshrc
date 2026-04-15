# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=100
SAVEHIST=100
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/aswdxtbyyn/.zshrc'
alias dotfiles='git --git-dir="$HOME/dotfiles/" --work-tree="$HOME"'
autoload -Uz compinit
compinit
# End of lines added by compinstall
autoload -Uz vcs_info
precmd_functions+=(vcs_info)

zstyle ':vcs_info:git:*' formats ' %F{177}(%b)%f'

setopt PROMPT_SUBST

PROMPT='%F{99}%n@%m%f:%F{141}%~%f${vcs_info_msg_0_:+ ${vcs_info_msg_0_}} %F{201}➜%f '