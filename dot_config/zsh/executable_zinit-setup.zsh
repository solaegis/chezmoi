#!/usr/bin/env zsh
# ============================================================================
# Zinit Plugin Manager Configuration
# ============================================================================
# Managed by chezmoi
# High-performance plugin loading with turbo mode
# ============================================================================

# Zinit installation directory
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit if not present
if [[ ! -f "${ZINIT_HOME}/zinit.zsh" ]]; then
  print -P "%F{yellow}Installing Zinit...%f"
  command mkdir -p "$(dirname $ZINIT_HOME)"
  command git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Load Zinit
source "${ZINIT_HOME}/zinit.zsh"

# ============================================================================
# Plugin Loading with Turbo Mode
# ============================================================================

# Load immediately (critical for UX)
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# ============================================================================
# Fast-Syntax-Highlighting (Load with turbo mode)
# ============================================================================
zinit wait lucid for \
  atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay" \
    zdharma-continuum/fast-syntax-highlighting \
  blockf \
    zsh-users/zsh-completions \
  atload"!_zsh_autosuggest_start" \
    zsh-users/zsh-autosuggestions

# ============================================================================
# Autosuggestions Configuration
# ============================================================================
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_USE_ASYNC=1
ZSH_AUTOSUGGEST_MANUAL_REBIND=1

# ============================================================================
# Syntax Highlighting Configuration  
# ============================================================================
typeset -gA FAST_HIGHLIGHT_STYLES
FAST_HIGHLIGHT_STYLES[default]=none
FAST_HIGHLIGHT_STYLES[unknown-token]=fg=red,bold
FAST_HIGHLIGHT_STYLES[reserved-word]=fg=yellow
FAST_HIGHLIGHT_STYLES[alias]=fg=green
FAST_HIGHLIGHT_STYLES[builtin]=fg=green
FAST_HIGHLIGHT_STYLES[function]=fg=green
FAST_HIGHLIGHT_STYLES[command]=fg=green
FAST_HIGHLIGHT_STYLES[path]=fg=cyan
FAST_HIGHLIGHT_STYLES[globbing]=fg=blue,bold
FAST_HIGHLIGHT_STYLES[single-quoted-argument]=fg=yellow
FAST_HIGHLIGHT_STYLES[double-quoted-argument]=fg=yellow
FAST_HIGHLIGHT_STYLES[comment]=fg=black,bold
FAST_HIGHLIGHT_STYLES[variable]=fg=blue

# ============================================================================
# End of Zinit Configuration
# ============================================================================
