#!/usr/bin/env zsh
# ============================================================================
# Completion System Optimizer
# ============================================================================
# Managed by chezmoi
# Compiles completions to .zwc for faster loading
# Cleans up stale cache files
# ============================================================================

# Compile zsh files for faster loading
function zsh_compile_files() {
  local zsh_cache="${ZSH_COMPDUMP:h}"
  
  echo "⚡ Compiling zsh files for faster startup..."
  
  # Compile main zsh config files
  for file in ~/.zshenv ~/.zprofile ~/.zshrc ~/.zlogin ~/.zlogout; do
    if [[ -f "$file" && ( ! -f "${file}.zwc" || "$file" -nt "${file}.zwc" ) ]]; then
      zcompile "$file" && echo "  ✓ Compiled: $file"
    fi
  done
  
  # Compile config directory files
  if [[ -d ~/.config/zsh ]]; then
    for file in ~/.config/zsh/*.zsh; do
      if [[ -f "$file" && ( ! -f "${file}.zwc" || "$file" -nt "${file}.zwc" ) ]]; then
        zcompile "$file" && echo "  ✓ Compiled: $file"
      fi
    done
  fi
  
  # Compile completion dump
  if [[ -f "$ZSH_COMPDUMP" ]]; then
    if [[ ! -f "${ZSH_COMPDUMP}.zwc" || "$ZSH_COMPDUMP" -nt "${ZSH_COMPDUMP}.zwc" ]]; then
      zcompile "$ZSH_COMPDUMP" && echo "  ✓ Compiled: $ZSH_COMPDUMP"
    fi
  fi
  
  echo "✅ Compilation complete"
}

# Clean stale completion cache files
function zsh_clean_cache() {
  local zsh_cache="${ZSH_COMPDUMP:h}"
  local count=0
  
  echo "🧹 Cleaning stale completion cache files..."
  
  # Remove hostname-specific compdump files (keep only main .zcompdump)
  if [[ -d "$zsh_cache" ]]; then
    for file in "$zsh_cache"/.zcompdump.*.*; do
      if [[ -f "$file" ]]; then
        rm -f "$file"
        ((count++))
      fi
    done
    
    # Remove old .zwc files for non-existent source files
    for zwc_file in "$zsh_cache"/*.zwc; do
      if [[ -f "$zwc_file" ]]; then
        local source_file="${zwc_file%.zwc}"
        if [[ ! -f "$source_file" ]]; then
          rm -f "$zwc_file"
          ((count++))
        fi
      fi
    done
  fi
  
  if (( count > 0 )); then
    echo "  ✓ Removed $count stale files"
  else
    echo "  ✓ No stale files found"
  fi
}

# Full optimization: clean + compile
function zsh_optimize() {
  zsh_clean_cache
  zsh_compile_files
  
  # Rebuild completion cache
  echo "🔄 Rebuilding completion cache..."
  rm -f "$ZSH_COMPDUMP"
  compinit -d "$ZSH_COMPDUMP"
  
  echo "✅ Zsh optimization complete. Restart your shell for changes to take effect."
}

# Auto-compile on first load (silent)
if [[ ! -f "${ZSH_COMPDUMP}.zwc" ]]; then
  zsh_compile_files >/dev/null 2>&1
fi

# Aliases for manual optimization
alias zsh-optimize="zsh_optimize"
alias zsh-compile="zsh_compile_files"
alias zsh-clean="zsh_clean_cache"

# ============================================================================
# Weekly automatic cache cleanup (check on Sunday morning)
# ============================================================================
function zsh_weekly_cleanup() {
  local marker_file="${ZSH_COMPDUMP:h}/.last_cleanup"
  local current_week=$(date +%Y-W%U)
  
  if [[ -f "$marker_file" ]]; then
    local last_cleanup=$(cat "$marker_file")
    if [[ "$last_cleanup" != "$current_week" ]]; then
      zsh_clean_cache >/dev/null 2>&1
      echo "$current_week" > "$marker_file"
    fi
  else
    echo "$current_week" > "$marker_file"
  fi
}

# Run weekly cleanup check (silent, fast)
zsh_weekly_cleanup

# ============================================================================
# End of Completion Optimizer
# ============================================================================
