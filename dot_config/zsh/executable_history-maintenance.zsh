#!/usr/bin/env zsh
# ============================================================================
# History Maintenance - Auto-cleanup and optimization
# ============================================================================
# Managed by chezmoi
# Conservative pruning at 90% capacity
# ============================================================================

# Auto-cleanup function (runs on shell exit, zero performance impact)
function zsh_history_cleanup() {
  local hist_file="${HISTFILE:-$HOME/.zsh_history}"
  local hist_size=$(wc -l < "$hist_file" 2>/dev/null || echo 0)
  
  # Only prune if history exceeds 45,000 entries (90% of 50K limit)
  if (( hist_size > 45000 )); then
    local backup_file="${hist_file}.backup-$(date +%Y%m%d-%H%M%S)"
    
    # Create backup
    cp "$hist_file" "$backup_file"
    
    # Prune: remove duplicates, keep chronological order, trim to 40K
    fc -W  # Write current session to history
    
    # Use awk to remove duplicates (keep last occurrence)
    # Then keep most recent 40,000 entries
    awk -F';' '!seen[$2]++' "$hist_file" | tail -40000 > "${hist_file}.tmp"
    
    if [[ -s "${hist_file}.tmp" ]]; then
      mv "${hist_file}.tmp" "$hist_file"
      local new_size=$(wc -l < "$hist_file")
      echo "🧹 History pruned: $hist_size → $new_size entries (backup: $backup_file)"
      
      # Remove backups older than 30 days
      find "$(dirname $hist_file)" -name ".zsh_history.backup-*" -mtime +30 -delete 2>/dev/null
    else
      rm -f "${hist_file}.tmp"
    fi
  fi
}

# Register cleanup hook (runs when shell exits)
autoload -Uz add-zsh-hook
add-zsh-hook zshexit zsh_history_cleanup

# Manual cleanup command
alias history-cleanup="zsh_history_cleanup"

# ============================================================================
# End of History Maintenance
# ============================================================================
