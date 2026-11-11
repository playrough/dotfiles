fzf_theme_opts="\
--color=bg+:{{colors.surface_container_low.default.hex}}
--color=bg:{{colors.surface.default.hex}}
--color=spinner:{{colors.tertiary.default.hex}}
--color=fg:{{colors.terminal_foreground.default.hex}}
--color=fg+:{{colors.on_surface.default.hex}}
--color=hl:{{colors.error.default.hex}}
--color=header:{{colors.error.default.hex}}
--color=info:{{colors.primary.default.hex}}
--color=pointer:{{colors.primary.default.hex}}
--color=marker:{{colors.on_surface_variant.default.hex}}
--color=prompt:{{colors.primary.default.hex}}
--color=hl+:{{colors.error.default.hex}}
--color=selected-bg:{{colors.primary.default.hex}}
--color=border:{{colors.on_secondary.default.hex}}
--color=label:{{colors.on_surface.default.hex}}"

export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:+$FZF_DEFAULT_OPTS
}$fzf_theme_opts"


