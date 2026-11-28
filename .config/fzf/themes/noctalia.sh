fzf_theme_opts="\
--color=bg+:#1b1b21
--color=bg:#121318
--color=spinner:#e5bad8
--color=fg:#e3e1e9
--color=fg+:#e3e1e9
--color=hl:#ffb4ab
--color=header:#ffb4ab
--color=info:#bac3ff
--color=pointer:#bac3ff
--color=marker:#c6c5d0
--color=prompt:#bac3ff
--color=hl+:#ffb4ab
--color=selected-bg:#bac3ff
--color=border:#2c2f42
--color=label:#e3e1e9"

export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:+$FZF_DEFAULT_OPTS
}$fzf_theme_opts"


