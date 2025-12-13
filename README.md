# Chezmoi Dotfiles Configuration

**Automated dotfile management for macOS** • [GitHub](https://github.com/solaegis/chezmoi)

> Professional dotfiles managed with [chezmoi](https://www.chezmoi.io/), featuring age encryption, machine-specific templating, and comprehensive automation.

---

## 🚀 Quick Start

### One-Line Installation

**Full automated setup** (new machine):
```bash
curl -fsLS https://raw.githubusercontent.com/solaegis/chezmoi/main/install-comprehensive.sh | bash
```

**Test installation** (dry-run, no changes):
```bash
curl -fsLS https://raw.githubusercontent.com/solaegis/chezmoi/main/install-minimal.sh | bash
```

This will:
- ✅ Install Xcode Command Line Tools, Homebrew, and chezmoi
- ✅ Auto-detect machine type (work/personal)
- ✅ Clone and apply your dotfiles
- ✅ Install packages based on machine type
- ✅ Configure shell (Oh My Zsh, Powerlevel10k, plugins)

---

## 📋 What's Included

### Core Features
- 🔐 **Age encryption** for sensitive files
- 🎯 **Machine-specific templates** (work vs personal)
- 🤖 **Taskfile automation** (40+ commands)
- 📦 **Brewfile** for package management
- 🐚 **Modular zsh configuration**
- 🔄 **Run-once scripts** for reproducible setups
- ✅ **Pre-commit hooks** for validation

### Managed Files
- Shell: `.zshrc`, `.zshenv`, `.zprofile`, `.bashrc`
- Git: `.gitconfig`, `.gitignore_global`
- Tools: Vim, iTerm2, SSH agent
- Packages: Homebrew Brewfile
- Configuration: zsh modules, aliases, functions

---

## 🛠️ Installation Options

### Comprehensive Installation
For production use on a new machine:
```bash
curl -fsLS https://raw.githubusercontent.com/solaegis/chezmoi/main/install-comprehensive.sh | bash
```

Includes: All dependencies + package installation + shell configuration

### Minimal Installation
For testing without applying changes:
```bash
curl -fsLS https://raw.githubusercontent.com/solaegis/chezmoi/main/install-minimal.sh | bash
```

Perfect for: Testing templates, validating configurations, development

### Custom Installation
```bash
# Install chezmoi only
brew install chezmoi

# Initialize without applying
chezmoi init --apply=false solaegis/chezmoi

# Review changes
chezmoi diff

# Apply selectively
chezmoi apply ~/.zshrc
chezmoi apply ~/.gitconfig

# Apply everything
chezmoi apply -v
```

---

## 🎯 Machine-Specific Configuration

### Auto-Detection
The system automatically detects machine type based on hostname:
- Contains `work`, `corp`, `company`, `office` → **WORK**
- Otherwise → **PERSONAL**

### Configuration Variables
After installation, configuration is stored in `~/.config/chezmoi/.chezmoidata.yaml`:

```yaml
machine_type: "work"  # or "personal"
email: "your@email.com"
github_user: "solaegis"
full_name: "Your Name"

# Conditional flags
is_work: true
is_personal: false
install_dev_tools: true
install_cloud_tools: true  # work only
```

### Using Templates
```bash
# ~/.zshrc.tmpl
{{- if .is_work }}
export WORK_PROXY="http://proxy.company.com:8080"
{{- end }}

{{- if .is_personal }}
export HOBBY_DIR="~/projects"
{{- end }}

# Common
export EMAIL="{{ .email }}"
```

---

## 📚 Taskfile Commands

Run `task` or `task --list` to see all available commands.

### Essential Commands
```bash
# Development
task chezmoi:status          # Show status
task chezmoi:diff            # See what would change
task chezmoi:apply           # Apply changes
task chezmoi:update          # Pull and apply updates

# Templates
task test:templates          # Validate all templates
task test:dry-run           # Test without applying

# Git
task git:status             # Git status
task git:push               # Push changes

# Maintenance
task maintenance:clean      # Clean temp files
task validate:repo          # Validate repository
```

See [detailed Taskfile documentation](docs/TASKFILE.md) for all 40+ commands.

---

## 🔒 Security & Encryption

### Age Encryption
This setup uses [age](https://github.com/FiloSottile/age) for encrypting sensitive files:

```bash
# Add encrypted file
chezmoi add --encrypt ~/.ssh/id_rsa
task chezmoi:encrypt ~/.ssh/id_rsa  # Using Taskfile

# View encrypted file
chezmoi cat ~/.ssh/id_rsa
```

**Key Management:**
- Identity: `~/.config/chezmoi/key.txt`
- Recipient: Configured in `chezmoi.toml`
- **Backup your key!** See [Security Documentation](docs/SECURITY.md)

---

## 🔄 Run-Once Scripts

Scripts that execute automatically during `chezmoi apply`:

1. **`run_once_before_01-install-homebrew.sh`**
   - Installs Homebrew (macOS only)
   - Runs before applying dotfiles

2. **`run_once_after_02-install-packages.sh`**
   - Installs packages from Brewfile
   - Machine-specific packages (work/personal)

3. **`run_once_after_03-configure-shell.sh`**
   - Sets zsh as default shell
   - Installs Oh My Zsh, Powerlevel10k
   - Installs zsh plugins

4. **`run_once_after_04-configure-timemachine.sh`**
   - Configures Time Machine exclusions

### Re-running Scripts
```bash
# Re-run all scripts
chezmoi state delete-bucket --bucket=scriptState

# Then apply
chezmoi apply -v
```

---

## 🔧 Common Tasks

### Update Dotfiles
```bash
# Simple update
chezmoi update

# Or manually
chezmoi cd
git pull
exit
chezmoi apply -v
```

### Edit Managed Files
```bash
# Edit source file and apply
chezmoi edit ~/.zshrc
chezmoi apply

# Or edit in place
chezmoi edit --apply ~/.zshrc
```

### Add New Files
```bash
# Add file to chezmoi
chezmoi add ~/.gitconfig

# Add encrypted file
chezmoi add --encrypt ~/.ssh/config
```

### Debug Templates
```bash
# View configuration data
chezmoi data

# Test template rendering
chezmoi execute-template < ~/.local/share/chezmoi/dot_zshrc.tmpl

# View what file would become
chezmoi cat ~/.zshrc
```

---

## 🧪 Testing & Validation

### Pre-commit Hooks
```bash
# Install hooks
cd ~/.local/share/chezmoi
pre-commit install

# Run manually
pre-commit run --all-files
```

### Template Validation
```bash
task test:templates
```

### Installation Testing
```bash
# Test minimal install
task install:minimal

# Test comprehensive install (careful!)
task install:comprehensive
```

---

## 📖 Documentation

- **[Automation Guide](docs/AUTOMATION.md)** - Detailed automation documentation
- **[SSH Agent Setup](docs/SSH_AGENT.md)** - SSH agent configuration
- **[Taskfile Reference](docs/TASKFILE.md)** - All 40+ Taskfile commands
- **[Security Guide](docs/SECURITY.md)** - Encryption and security best practices
- **[Troubleshooting](docs/TROUBLESHOOTING.md)** - Common issues and solutions

---

## 🔍 Troubleshooting

### Check Configuration
```bash
chezmoi doctor           # System diagnostics
chezmoi data            # View configuration variables
chezmoi status          # See what would change
```

### View Rendered Templates
```bash
chezmoi cat ~/.zshrc    # See final output
```

### Reset Configuration
```bash
# Backup current
mv ~/.local/share/chezmoi ~/.local/share/chezmoi.backup

# Re-initialize
chezmoi init --apply=false solaegis/chezmoi
chezmoi diff
chezmoi apply -v
```

### Common Issues

**Problem:** Template errors  
**Solution:** `chezmoi execute-template < file.tmpl` to debug

**Problem:** Script won't re-run  
**Solution:** `chezmoi state delete-bucket --bucket=scriptState`

**Problem:** Permission denied  
**Solution:** Check file permissions with `chezmoi managed -i files`

See [full troubleshooting guide](docs/TROUBLESHOOTING.md) for more solutions.

---

## 🚀 Next Steps

After installation:

1. **Restart terminal** to load new configuration
2. **Review applied files:** `chezmoi managed`
3. **Customize further:** `chezmoi edit <file>`
4. **Keep updated:** `chezmoi update`
5. **Explore Taskfile:** `task --list`

---

## 📝 Development Workflow

### Making Changes
```bash
# 1. Edit files
chezmoi edit ~/.zshrc

# 2. Test locally
chezmoi diff
chezmoi apply

# 3. Commit changes
chezmoi cd
git add .
git commit -m "Update zsh config"
git push

# 4. Update other machines
chezmoi update
```

### Adding Machine-Specific Config
```bash
# Edit template
chezmoi edit ~/.zshrc

# Add conditional
{{- if .is_work }}
# Work-specific configuration
{{- end }}

# Test and apply
chezmoi diff
chezmoi apply
```

---

## 🌟 Features Highlight

### Intelligent Completion Caching
Zsh completion regenerates only once per day for faster startup.

### Modular Configuration
Organized zsh config in `~/.config/zsh/`:
- `functions.zsh` - Custom functions
- `aliases.zsh` - Command aliases
- `modern-aliases.zsh` - Modern tool aliases (eza, bat, ripgrep)
- `zinit-setup.zsh` - Plugin manager
- `completion-optimizer.zsh` - Performance optimization

### Powerlevel10k Theme
Instant prompt for minimal latency.

### Cross-Platform Support
Templates handle both Intel and Apple Silicon Macs automatically.

---

## 📚 Resources

- [Chezmoi Documentation](https://www.chezmoi.io/)
- [Chezmoi Template Reference](https://www.chezmoi.io/reference/templates/)
- [Age Encryption](https://github.com/FiloSottile/age)
- [Task Runner](https://taskfile.dev/)
- [Oh My Zsh](https://ohmyz.sh/)
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k)

---

## 📄 License

This configuration is for personal use. Feel free to fork and adapt to your needs.

---

**Questions or issues?** Open an issue on [GitHub](https://github.com/solaegis/chezmoi/issues)
