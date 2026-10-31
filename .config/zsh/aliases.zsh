# Better ls
alias ls='eza --icons=auto'

# Detailed listing
alias ll='eza -lh --icons=auto --git'

# Detailed listing including hidden files
alias la='eza -lah --icons=auto --git'

# Tree view
alias tree='eza --tree --icons=auto'

# Reuse ls completions for eza (avoids defining a separate completion function)
compdef eza=ls

# Better cat
alias cat='bat'

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
alias dots='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'

# =========================================================
# Paru
# =========================================================

alias p='paru'
alias el='elio'
