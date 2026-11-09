# Better ls
alias ls='eza -s Name --icons=auto'

# Detailed listing
alias ll='eza -lh -s Name --icons=auto --git'

# Detailed listing including hidden files
alias la='eza -lah -s Name --icons=auto --git'

# Tree view
alias tree='eza --tree -s Name --icons=auto'

# Reuse ls completions for eza (avoids defining a separate completion function)
compdef eza=ls

# Better cat
alias cat='bat -p'

# =========================================================
# Core utilities
# =========================================================

alias grep='rg --color=auto'
alias diff='diff --color=auto'
alias df='df -h'

# =========================================================
# Navigation
# =========================================================

alias -- -='cd -'  # -- prevents - being parsed as a flag; cd - jumps to previous directory

# =========================================================
# Editor
# =========================================================

alias nv='nvim'

# =========================================================
# Git
# =========================================================
alias dot='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'

# =========================================================
# Paru
# =========================================================

alias p='paru'
alias el='elio'

# =========================================================
# Wget
# =========================================================

alias wget="wget --hsts-file=$XDG_DATA_HOME/wget-hsts"
