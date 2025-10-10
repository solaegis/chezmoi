#!/usr/bin/env zsh
# ============================================================================
# ZSH Aliases - Separated from functions to avoid conflicts v2
# ============================================================================

# Basic aliases (non-conflicting)
alias cll="clear;ls -l"
alias cls="clear;ls -G"
alias ..="cd .."

# Git aliases (these should be set after functions are loaded)
alias git="hub"

# Terraform alias (set after functions)
#alias tf="terraform"

# Terraform documentation
alias tfdoc="terraform-docs md table ."

# Directory shortcuts
alias git-work="cd ~/git-work && source ~/git-work/SSH.sh"
alias git-me="cd ~/git"
alias git-dnlc="cd ~/git-dnlc && source ~/git-dnlc/SSH.sh"

# Core chezmoi alias
alias cz="chezmoi"

# NOTE: czst, czdf, czup, czap, czec, czls are now defined as function aliases
# in functions.zsh to avoid conflicts

# Chezmoi file operations (safe aliases)
alias czcat="chezmoi cat"
alias czcd="chezmoi cd"

# Git integration aliases for chezmoi
alias czgit="chezmoi cd && git"
alias czlog="chezmoi cd && git log --oneline -10 && cd -"
alias czremote="chezmoi cd && git remote -v && cd -"

# Quick dotfiles management
alias dotfiles="chezmoi cd"
alias dotpush="czpush"
alias dotpull="czpull"
alias dotstatus="czstatus"   # Use function name
alias dotdiff="czdiff"       # Use function name

# Claude alias (if Claude Code is installed)
if [ -f /Users/lvavasour/.claude/local/claude ]; then
    alias claude="/Users/lvavasour/.claude/local/claude"
fi

# SSH Agent aliases
alias sshls="ssh_list_keys"
alias sshclear="ssh_clear_keys"
alias sshreload="ssh_reload_keys"
alias sshstop="stop_ssh_agent"
