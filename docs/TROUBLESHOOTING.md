# Troubleshooting Guide

## Common Issues and Solutions

### Template Errors

**Problem:** Template rendering fails  
**Symptoms:**
```
template: dot_zshrc.tmpl:10: undefined variable "is_work"
```

**Solution:**
```bash
# 1. Check configuration data
chezmoi data

# 2. Test template rendering
chezmoi execute-template < ~/.local/share/chezmoi/dot_zshrc.tmpl

# 3. Regenerate .chezmoidata.yaml
chezmoi state delete-bucket --bucket=scriptState
chezmoi apply -v ~/.config/chezmoi/.chezmoidata.yaml
```

### Run-Once Scripts Won't Re-run

**Problem:** Made changes to run-once script but it won't execute  
**Solution:**
```bash
# Clear script state
chezmoi state delete-bucket --bucket=scriptState

# Re-apply
chezmoi apply -v
```

### Permission Denied Errors

**Problem:** Can't modify files  
**Solution:**
```bash
# Check file permissions
chezmoi managed -i files

# Fix specific file
chmod 644 ~/.zshrc
chezmoi apply -v ~/.zshrc
```

### Completion System Warnings

**Problem:** Zsh shows "insecure directories" warning  
**Solution:**
```bash
# Already handled by run_once_after_03-configure-shell.sh
# But if needed manually:
chmod -R go-w "$(brew --prefix)/share/zsh/site-functions"
chmod -R go-w "$(brew --prefix)/share/zsh-completions"

# Clear completion cache
rm -f ~/.cache/zsh/.zcompdump*
```

### Homebrew Installation Fails

**Problem:** Brewfile installation errors  
**Solution:**
```bash
# 1. Update Homebrew
brew update

# 2. Check for conflicts
brew doctor

# 3. Install manually
brew bundle --file=~/.Brewfile

# 4. Check specific package
brew info <package-name>
```

### Architecture Mismatch

**Problem:** Config shows wrong architecture (amd64 vs arm64)  
**Solution:**
```bash
# Edit config directly
chezmoi edit --config

# Update arch value
[data.machine]
    arch = "arm64"

# Verify
chezmoi data | grep arch
```

### Git Sync Issues

**Problem:** Can't push/pull changes  
**Solution:**
```bash
# Check git status in source directory
chezmoi cd
git status
git remote -v

# Pull latest
git pull

# Push changes
git push

# Exit back to home
exit
```

### Encryption/Decryption Errors

**Problem:** Can't decrypt files  
**Solution:**
```bash
# 1. Verify age identity exists
ls -la ~/.config/chezmoi/key.txt

# 2. Check chezmoi config
chezmoi edit --config

# 3. Test decryption manually
age -d -i ~/.config/chezmoi/key.txt file.age

# 4. Re-add encrypted file if needed
chezmoi re-add ~/.ssh/id_rsa
```

### Taskfile Errors

**Problem:** Task commands fail  
**Solution:**
```bash
# 1. Install/update task
brew install go-task

# 2. Verify Taskfile syntax
task --list

# 3. Run with verbose output
task --verbose <task-name>

# 4. Check task variables
task --summary <task-name>
```

### Oh My Zsh Installation Issues

**Problem:** Oh My Zsh or plugins not loading  
**Solution:**
```bash
# 1. Reinstall Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# 2. Reinstall Powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
  ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# 3. Reinstall plugins
git clone https://github.com/zsh-users/zsh-autosuggestions \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

### Slow Shell Startup

**Problem:** Terminal takes too long to open  
**Solution:**
```bash
# 1. Profile startup time
time zsh -i -c exit

# 2. Check what's slow
zsh -xv 2>&1 | less

# 3. Disable plugins temporarily
# Edit ~/.zshrc and comment out slow plugins

# 4. Recompile zsh files
task maintenance:clean
rm -f ~/.cache/zsh/.zcompdump*
zsh
```

### Pre-commit Hooks Not Working

**Problem:** Pre-commit hooks don't run on git commit  
**Solution:**
```bash
cd ~/.local/share/chezmoi

# Install/reinstall hooks
pre-commit install

# Test hooks manually
pre-commit run --all-files

# Update hooks
pre-commit autoupdate
```

### Chezmoi Doctor Issues

**Problem:** `chezmoi doctor` shows warnings  
**Solution:**
```bash
# Run doctor
chezmoi doctor

# Common fixes:
# - Update chezmoi: brew upgrade chezmoi
# - Fix git config: git config --global user.name "Your Name"
# - Fix permissions: chmod 700 ~/.local/share/chezmoi
```

## Diagnostic Commands

### Check System State
```bash
# Chezmoi diagnostics
chezmoi doctor

# Configuration data
chezmoi data

# Managed files
chezmoi managed

# Status
chezmoi status
```

### Check What Would Change
```bash
# See all differences
chezmoi diff

# See specific file
chezmoi diff ~/.zshrc

# Dry run
chezmoi apply --dry-run -v
```

### Template Debugging
```bash
# View rendered template
chezmoi cat ~/.zshrc

# Test template syntax
chezmoi execute-template < ~/.local/share/chezmoi/dot_zshrc.tmpl

# View source vs target
chezmoi diff ~/.zshrc
```

### Repository Validation
```bash
# Validate repo structure
task validate:repo

# Lint shell scripts
task validate:lint

# Test templates
task test:templates

# Test installation (dry-run)
task test:dry-run
```

## Reset and Recovery

### Soft Reset (Keep Changes)
```bash
# Review changes
chezmoi diff

# Re-apply everything
chezmoi apply -v
```

### Hard Reset (Lose Changes)
```bash
# Backup first
cp -r ~/.local/share/chezmoi ~/.local/share/chezmoi.backup

# Reset git repository
chezmoi cd
git reset --hard HEAD
git clean -fd
exit

# Re-apply
chezmoi apply -v
```

### Complete Reinstall
```bash
# 1. Backup current state
tar -czf ~/chezmoi-backup-$(date +%Y%m%d).tar.gz \
  ~/.local/share/chezmoi ~/.config/chezmoi

# 2. Remove everything
rm -rf ~/.local/share/chezmoi ~/.config/chezmoi

# 3. Reinstall
curl -fsLS https://raw.githubusercontent.com/solaegis/chezmoi/main/install-comprehensive.sh | bash
```

## Getting Help

### Documentation
- Chezmoi docs: https://www.chezmoi.io/
- This repository: https://github.com/solaegis/chezmoi

### Debug Mode
```bash
# Verbose output
chezmoi apply -v

# Very verbose
chezmoi apply -vv

# Show what would happen
chezmoi apply --dry-run -v
```

### Create Issue
If you encounter a persistent problem:

1. Run diagnostics: `chezmoi doctor`
2. Check logs: `chezmoi apply -vv`
3. Create issue with:
   - Error message
   - Steps to reproduce
   - System info (`chezmoi data`)
   - Diagnostic output
