# Lines configured by zsh-newuser-install
export EDITOR=nvim
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

alias ls='eza --icons --group-directories-first --color=always'
alias ll='eza -lah --icons --git'
alias la='eza -a --icons'
alias tree='eza --tree --icons'

# Completion styling
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes

# Better process completion
zstyle ':completion:*:*:kill:*:processes' command 'ps -u $USER -o pid,cmd'

# Tab behavior
bindkey '^I' expand-or-complete

# Plugin sourcing (guarded — only sources if the file exists,
# so this works unchanged on both Arch and NixOS)
[[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && \
  source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
[[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && \
  source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
[[ -f /usr/share/fzf/completion.zsh ]] && \
  source /usr/share/fzf/completion.zsh
[[ -f /usr/share/fzf/key-bindings.zsh ]] && \
  source /usr/share/fzf/key-bindings.zsh

eval "$(starship init zsh)"
export PATH="$HOME/.local/bin:$PATH"

# Aliases
alias nrs="sudo nixos-rebuild switch"
#alias fnrs="sudo nixos-rebuild switch --flake ~/myNixOS/#Desktop-NixOS-BTW"
alias hermes='docker exec -it hermes-gateway hermes'
fnrs() {
  sudo nixos-rebuild switch --flake ~/myNixOS/#"$1"
}
