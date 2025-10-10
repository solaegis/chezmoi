#!/usr/bin/env zsh
# ============================================================================
# Zsh Health Check & Diagnostics
# ============================================================================
# Run this to verify your zsh configuration is optimized
# ============================================================================

echo "
🔍 ZSH CONFIGURATION HEALTH CHECK
"
echo "================================================================="

# Check 1: Zinit Installation
echo "
📦 Plugin Manager"
if [[ -d ~/.local/share/zinit/zinit.git ]]; then
  echo "  ✅ Zinit installed"
  if [[ -n "\${ZINIT}" ]]; then
    echo "  ✅ Zinit loaded in current shell"
  else
    echo "  ⚠️  Zinit not loaded (restart shell)"
  fi
else
  echo "  ❌ Zinit not installed"
fi

# Check 2: Plugins
echo "
🔌 Plugins"
if command -v fast-theme &>/dev/null; then
  echo "  ✅ fast-syntax-highlighting loaded"
else
  echo "  ⚠️  fast-syntax-highlighting not loaded"
fi

if [[ -n "\${ZSH_AUTOSUGGEST_STRATEGY}" ]]; then
  echo "  ✅ zsh-autosuggestions loaded"
else
  echo "  ⚠️  zsh-autosuggestions not loaded"
fi

# Check 3: Compiled Files
echo "
⚡ Compiled Files (.zwc for performance)"
local compiled_count=0
local total_count=0

for file in ~/.zshenv ~/.zprofile ~/.zshrc ~/.config/zsh/*.zsh; do
  if [[ -f "\$file" ]]; then
    ((total_count++))
    if [[ -f "\${file}.zwc" && "\${file}.zwc" -nt "\$file" ]]; then
      ((compiled_count++))
    fi
  fi
done

echo "  📊 \$compiled_count/\$total_count files compiled"
if (( compiled_count == total_count )); then
  echo "  ✅ All zsh files compiled"
elif (( compiled_count > 0 )); then
  echo "  ⚠️  Some files not compiled - run: zsh-compile"
else
  echo "  ❌ No files compiled - run: zsh-compile"
fi

# Check 4: Cache Health
echo "
🗂️  Cache Directory"
local cache_dir="\${ZSH_COMPDUMP:h}"
if [[ -d "\$cache_dir" ]]; then
  local stale_files=\$(ls -1 "\$cache_dir"/.zcompdump.*.* 2>/dev/null | wc -l | tr -d ' ')
  echo "  📁 Cache: \$cache_dir"
  echo "  📊 Stale files: \$stale_files"
  
  if (( stale_files == 0 )); then
    echo "  ✅ No stale cache files"
  else
    echo "  ⚠️  Stale files found - run: zsh-clean"
  fi
else
  echo "  ❌ Cache directory not found"
fi

# Check 5: History
echo "
📜 History Configuration"
local hist_file="\${HISTFILE:-\$HOME/.zsh_history}"
if [[ -f "\$hist_file" ]]; then
  local hist_size=\$(wc -l < "\$hist_file" 2>/dev/null || echo 0)
  local hist_limit=\${HISTSIZE:-50000}
  local usage_pct=\$(( hist_size * 100 / hist_limit ))
  
  echo "  📊 Entries: \$hist_size / \$hist_limit (\${usage_pct}%)"
  
  if (( usage_pct < 90 )); then
    echo "  ✅ History size healthy"
  else
    echo "  ⚠️  History approaching limit (will auto-prune at exit)"
  fi
  
  # Check for recent backups
  local backup_count=\$(ls -1 "\${hist_file}.backup-"* 2>/dev/null | wc -l | tr -d ' ')
  if (( backup_count > 0 )); then
    echo "  📦 Backups found: \$backup_count"
  fi
else
  echo "  ❌ History file not found"
fi

# Check 6: Performance
echo "
⚡ Startup Performance"
if command -v zsh &>/dev/null; then
  echo "  🔄 Testing shell startup time..."
  local time1=\$(( \$(gdate +%s%N 2>/dev/null || date +%s000000000) ))
  zsh -i -c exit 2>/dev/null
  local time2=\$(( \$(gdate +%s%N 2>/dev/null || date +%s000000000) ))
  local duration=\$(( (time2 - time1) / 1000000 ))
  
  echo "  ⏱️  Startup time: \${duration}ms"
  
  if (( duration < 200 )); then
    echo "  ✅ Excellent performance"
  elif (( duration < 400 )); then
    echo "  ✅ Good performance"
  elif (( duration < 800 )); then
    echo "  ⚠️  Moderate performance"
  else
    echo "  ❌ Slow startup - consider optimization"
  fi
fi

# Check 7: Configuration Files
echo "
📄 Configuration Files"
local config_files=(
  "~/.zshenv:Environment variables"
  "~/.zprofile:Login shell setup"
  "~/.zshrc:Interactive configuration"
  "~/.config/zsh/zinit-setup.zsh:Plugin manager"
  "~/.config/zsh/functions.zsh:Shell functions"
  "~/.config/zsh/aliases.zsh:Basic aliases"
  "~/.config/zsh/modern-aliases.zsh:Modern tool aliases"
  "~/.config/zsh/completion-optimizer.zsh:Performance optimizer"
  "~/.config/zsh/history-maintenance.zsh:History management"
)

for entry in "\${config_files[@]}"; do
  local file="\${entry%%:*}"
  local desc="\${entry#*:}"
  file=\${file/#\~\/\$HOME/}
  
  if [[ -f "\$file" ]]; then
    echo "  ✅ \$desc"
  else
    echo "  ❌ \$desc (missing: \$file)"
  fi
done

# Summary
echo "
================================================================="
echo "📊 SUMMARY"
echo "=================================================================
"

local issues=0

# Count issues
[[ ! -d ~/.local/share/zinit/zinit.git ]] && ((issues++))
! command -v fast-theme &>/dev/null && ((issues++))
[[ -z "\${ZSH_AUTOSUGGEST_STRATEGY}" ]] && ((issues++))
(( compiled_count < total_count )) && ((issues++))
(( stale_files > 0 )) && ((issues++))

if (( issues == 0 )); then
  echo "✅ All systems operational! Your zsh configuration is optimized.
"
else
  echo "⚠️  Found \$issues issue(s). Run suggested commands above to fix.
"
  echo "Quick fixes:"
  echo "  - Compile files:    zsh-compile"
  echo "  - Clean cache:      zsh-clean"
  echo "  - Full optimize:    zsh-optimize"
  echo "  - Restart shell:    exec zsh
"
fi

# ============================================================================
# End of Health Check
# ============================================================================
