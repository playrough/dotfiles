# ==================================================
#  ENV & PATH
# ==================================================

# export LD_PRELOAD=/usr/lib/libiconv.so.2

export PATH="$PATH:$HOME/.local/bin"
export PAGER=ov



# ==================================================
#  OH MY ZSH
# ==================================================

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""

plugins=(
    git
    zsh-autosuggestions
    zsh-vi-mode
)

source $ZSH/oh-my-zsh.sh



# ==================================================
#  PROMPT & NAVIGATION
# ==================================================

# Starship prompt
eval "$(starship init zsh)"

# zoxide (smart cd)
eval "$(zoxide init zsh)"



# ==================================================
#  ALIASES – CORE
# ==================================================

alias q='exit'
alias :q='exit'
alias reload='source ~/.zshrc'
alias rz='source ~/.zshrc'
alias ez='nvim ~/.zshrc'
alias kl='kitty @ load-config'



# ==================================================
#  DOTFILES
# ==================================================

# alias dot='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
# alias ds='dot status'
# alias da='dot add'
# alias dc='dot commit'
# alias dp='dot push'


dot() {
  git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" "$@"
}

alias ds='dot status'
alias da='dot add'
alias dc='dot commit'
alias dp='dot push'



# ==================================================
#  FILE / EDITOR
# ==================================================

alias nv='nvim'
alias y='yazi'



# ==================================================
#  LS / LSD
# ==================================================

if command -v lsd >/dev/null 2>&1; then
  alias ls='lsd'
  alias l='lsd -l'
  alias la='lsd -a'
  alias lla='lsd -la'
  alias lt='lsd --tree'
fi



# ==================================================
#  MATUGEN / HYPRLAND
# ==================================================

alias mtg="$HOME/.config/hypr/Script/wallSelect-fzf.sh"
alias cw="$HOME/.config/hypr/Script/wallSelect.sh"



# ==================================================
#  GLOW
# ==================================================

alias glow="glow --style=$HOME/.config/glow/glow-style.json"
alias cs="glow -p notes/cheatsheet.md -w 65"



# ==================================================
#  WIFI (NMCLI + FZF)
# ==================================================

alias w='nmcli device wifi connect'
alias wl='nmcli device wifi list'
alias ws='nmcli device status'
alias wt='nmcli radio wifi'
alias wu='nmcli connection up'

alias wf='nmcli -t -f IN-USE,SSID,SECURITY,SIGNAL device wifi list |
awk -F: '"'"'{
  mark = ($1=="*") ? "󰐾" : " ";
  printf "%s %-25s %-12s %3s%%\t%s\n", mark, $2, $3, $4, $2;
}'"'"' |
fzf --ansi |
awk -F"\t" "{print \$2}" |
xargs -r -I{} nmcli device wifi connect "{}"'



# ==================================================
#  FUN
# ==================================================

alias minato='kitty +kitten icat --align center --scale-up ~/Downloads/Logos/minato-naruto.gif'



# ==================================================
#  INFO
# ==================================================

fastfetch
