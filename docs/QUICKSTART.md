# Quick Start Guide

## 🚀 New Mac Installation

### Comprehensive (Production)
```bash
curl -fsLS https://raw.githubusercontent.com/solaegis/chezmoi/main/install-comprehensive.sh | bash
```
**Does everything automatically** - installs Homebrew, chezmoi, applies dotfiles, installs packages.

### Minimal (Testing)
```bash
curl -fsLS https://raw.githubusercontent.com/solaegis/chezmoi/main/install-minimal.sh | bash
```
**Safe testing only** - shows what would be applied, doesn't change anything.

---

## 📋 Common Commands

### Daily Use
```bash
chezmoi update          # Pull latest changes and apply
chezmoi diff            # See what would change
chezmoi apply -v        # Apply all changes
```

### Editing
```bash
chezmoi edit ~/.zshrc   # Edit a dotfile
chezmoi diff            # Preview changes
chezmoi apply           # Apply changes
```

### Git Workflow
```bash
chezmoi cd              # Go to source directory
git add .
git commit -m "Update"
git push
exit                    # Return to previous directory
```

### Information
```bash
chezmoi managed         # List managed files
chezmoi data            # Show configuration data
chezmoi doctor          # Check for issues
```

---

## 🔧 Machine Configuration

Edit machine-specific settings:
```bash
chezmoi edit-config
```

Or directly edit:
```bash
vim ~/.config/chezmoi/.chezmoidata.yaml
```

### Configuration Options
- `machine_type`: `"work"` or `"personal"`
- `is_work`: `true` or `false`
- `install_cloud_tools`: `true` (work) or `false` (personal)
- `email`: Your email address
- `github_user`: Your GitHub username

---

## 🧪 Testing New Configurations

1. Test locally:
   ```bash
   chezmoi diff
   ```

2. Test on new machine (safe):
   ```bash
   curl -fsLS https://raw.githubusercontent.com/solaegis/chezmoi/main/install-minimal.sh | bash
   # Review output
   rm -rf ~/.local/share/chezmoi  # Clean up test
   ```

3. Commit when ready:
   ```bash
   chezmoi cd
   git add .
   git commit -m "Description"
   git push
   ```

---

## 🆘 Emergency Commands

### See what's different
```bash
chezmoi diff
```

### Undo local changes
```bash
chezmoi apply --force
```

### Start fresh
```bash
rm -rf ~/.local/share/chezmoi
curl -fsLS https://raw.githubusercontent.com/solaegis/chezmoi/main/install-comprehensive.sh | bash
```

### Re-run setup scripts
```bash
chezmoi state delete-bucket --bucket=scriptState
chezmoi apply -v
```

---

## 📚 More Information

- Full installation guide: [INSTALLATION.md](INSTALLATION.md)
- Complete user guide: [README.md](README.md)
- Chezmoi docs: https://www.chezmoi.io/
