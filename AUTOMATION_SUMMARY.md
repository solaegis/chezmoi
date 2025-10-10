# Chezmoi Automation Summary

## What Was Created

I've created a comprehensive automation system for installing chezmoi on new Macs. Here's what's available:

### 📁 Files Created

#### Installation Scripts (in `~/.local/share/chezmoi/`)

1. **`install-comprehensive.sh`** (10KB)
   - Full production installation script
   - Installs Xcode tools, Homebrew, chezmoi
   - Auto-detects work vs personal machine
   - Applies all dotfiles and configurations
   - Runs all setup scripts automatically

2. **`install-minimal.sh`** (6.3KB)
   - Safe testing script for development
   - Shows what would be applied without changes
   - Perfect for validating configurations
   - Tests machine type detection
   - Easy cleanup for repeated testing

#### Configuration Templates

3. **`.chezmoidata.yaml.tmpl`** (1.5KB)
   - Machine-specific configuration template
   - Auto-detects work/personal based on hostname
   - Prompts for email, name, GitHub username
   - Stores preferences for package installation

#### Automation Scripts (run_once_*)

4. **`run_once_before_01-install-homebrew.sh.tmpl`** (767B)
   - Installs Homebrew before applying dotfiles
   - Handles both Intel and Apple Silicon Macs

5. **`run_once_after_02-install-packages.sh.tmpl`** (2.4KB)
   - Installs essential packages (git, curl, vim, etc.)
   - Installs dev tools (go, python, node, rust)
   - Work-specific: terraform, gcloud, awscli, kubectl
   - Personal-specific: media tools

6. **`run_once_after_03-configure-shell.sh.tmpl`** (2.2KB)
   - Sets zsh as default shell
   - Installs Oh My Zsh
   - Installs Powerlevel10k theme
   - Installs zsh plugins (autosuggestions, syntax-highlighting)

#### Documentation

7. **`INSTALLATION.md`** (9KB)
   - Complete installation guide
   - Machine-specific configuration docs
   - Development workflow
   - Troubleshooting guide

8. **`QUICKSTART.md`** (2.5KB)
   - Quick reference card
   - Common commands
   - Emergency procedures

---

## 🚀 Usage

### For a New Mac (Production)

```bash
curl -fsLS https://raw.githubusercontent.com/solaegis/chezmoi/main/install-comprehensive.sh | bash
```

**What it does:**
1. ✅ Installs Xcode Command Line Tools
2. ✅ Installs Homebrew
3. ✅ Installs chezmoi
4. ✅ Clones your dotfiles from GitHub
5. ✅ Detects if work or personal machine
6. ✅ Prompts for user information
7. ✅ Applies all dotfiles with proper templates
8. ✅ Installs packages based on machine type
9. ✅ Configures shell (Oh My Zsh, themes, plugins)
10. ✅ One command, fully automated!

### For Testing New Configurations (Development)

```bash
curl -fsLS https://raw.githubusercontent.com/solaegis/chezmoi/main/install-minimal.sh | bash
```

**What it does:**
1. ✅ Installs/checks chezmoi
2. ✅ Clones repository
3. ✅ Detects machine type
4. ✅ Shows what would be applied (diff)
5. ✅ Shows configuration data
6. ❌ Does NOT apply any changes
7. ✅ Easy cleanup: `rm -rf ~/.local/share/chezmoi`

---

## 🔄 Development Workflow

### Developing Machine-Specific Configurations

```bash
# 1. Edit templates on your current machine
chezmoi edit ~/.zshrc

# 2. Add conditionals for work/personal
{{- if .is_work }}
# Work-specific code
{{- end }}

{{- if .is_personal }}
# Personal code
{{- end }}

# 3. Test locally
chezmoi diff
chezmoi apply

# 4. Commit changes
chezmoi cd
git add .
git commit -m "Add work/personal conditional config"
git push

# 5. Test on another machine (minimal install)
curl -fsLS https://raw.githubusercontent.com/solaegis/chezmoi/main/install-minimal.sh | bash
# Review output to verify conditionals work correctly

# 6. If good, clean up test and run full install
rm -rf ~/.local/share/chezmoi
curl -fsLS https://raw.githubusercontent.com/solaegis/chezmoi/main/install-comprehensive.sh | bash
```

---

## 🎯 Machine Type Detection

The system automatically determines if a machine is for work or personal use:

### Detection Logic
- Hostname contains: `work`, `corp`, `company`, `office` → **WORK**
- Otherwise → **PERSONAL**
- Can be overridden during installation

### Configuration File
After installation, settings are stored in `~/.config/chezmoi/.chezmoidata.yaml`:

```yaml
machine_type: "work"        # or "personal"
email: "user@example.com"
github_user: "solaegis"
full_name: "Your Name"

# Conditional flags
is_work: true               # false for personal
is_personal: false          # true for personal
git_work_enabled: true      # work only
install_cloud_tools: true   # work only
install_gaming_tools: false # personal only
```

### Using in Templates

```bash
# In any .tmpl file:
{{- if .is_work }}
export WORK_PROXY="http://proxy.company.com:8080"
alias work-vpn="sudo openconnect vpn.company.com"
{{- end }}

{{- if .is_personal }}
export HOBBY_DIR="~/projects"
{{- end }}
```

---

## 📦 Package Installation

Packages are automatically installed based on machine type:

### Essential (All Machines)
- git, curl, wget, vim
- direnv, jq, ripgrep, fd
- bat, exa, htop, tree

### Development Tools (If Enabled)
- go, python3, node, rust

### Work-Specific
- terraform, terraform-docs
- google-cloud-sdk
- awscli
- kubectl, helm

### Personal-Specific
- youtube-dl
- media/gaming tools

Configure in `.chezmoidata.yaml`:
```yaml
install_dev_tools: true
install_cloud_tools: true   # work
install_gaming_tools: false # personal
```

---

## 🧪 Testing Strategy

### Step 1: Test Locally
```bash
chezmoi diff                # See what would change
chezmoi apply --dry-run -v  # Simulate apply
```

### Step 2: Test on Test Machine
```bash
# Run minimal install
curl -fsLS https://raw.githubusercontent.com/solaegis/chezmoi/main/install-minimal.sh | bash

# Review all output carefully:
# - Machine type detection
# - Configuration data
# - File diffs
# - Managed files

# Clean up
rm -rf ~/.local/share/chezmoi
```

### Step 3: Commit When Ready
```bash
chezmoi cd
git add .
git commit -m "Description of changes"
git push
```

### Step 4: Full Test Install
```bash
curl -fsLS https://raw.githubusercontent.com/solaegis/chezmoi/main/install-comprehensive.sh | bash
```

---

## 🔧 Next Steps

### 1. Commit and Push
```bash
cd ~/.local/share/chezmoi
git add .
git commit -m "Add comprehensive automation scripts"
git push
```

### 2. Test Minimal Install
Test on your current machine or a VM:
```bash
curl -fsLS https://raw.githubusercontent.com/solaegis/chezmoi/main/install-minimal.sh | bash
```

### 3. Customize for Your Needs

Edit these files to match your requirements:

- **`.chezmoidata.yaml.tmpl`** - Add more configuration options
- **`run_once_after_02-install-packages.sh.tmpl`** - Add/remove packages
- **`install-comprehensive.sh`** - Customize installation flow
- **Existing dotfiles** - Add conditional logic using `.is_work` / `.is_personal`

### 4. Add More Templates

Convert existing files to templates:
```bash
# Rename file to .tmpl
chezmoi add --template ~/.zshrc

# Edit and add conditionals
chezmoi edit ~/.zshrc

# Test
chezmoi diff
```

### 5. Test on New Machine

When you get a new Mac:
```bash
# One command!
curl -fsLS https://raw.githubusercontent.com/solaegis/chezmoi/main/install-comprehensive.sh | bash
```

---

## 📚 Documentation Files

- **`QUICKSTART.md`** - Quick reference (commands, common tasks)
- **`INSTALLATION.md`** - Complete installation guide
- **`README.md`** - General chezmoi usage guide (existing)
- **`AUTOMATION_SUMMARY.md`** - This file

---

## 🎉 Benefits

### Before
- Manual Homebrew installation
- Manual chezmoi setup
- Manual git clone
- Manual package installation
- Manual shell configuration
- Manual Oh My Zsh setup
- Manual theme installation
- Manual plugin installation
- Different configs for work/personal machines
- Hours of setup time

### After
- ✨ **One command**: `curl ... | bash`
- ✨ **Fully automated**: Everything installed automatically
- ✨ **Machine-specific**: Auto-detects and configures for work/personal
- ✨ **Safe testing**: Minimal script for validation
- ✨ **Easy development**: Test before committing
- ✨ **15-30 minutes**: Complete setup time (mostly downloads)

---

## 🔍 Key Features

1. **Comprehensive Installation** - One command does everything
2. **Minimal Testing** - Safe way to test configurations
3. **Machine Detection** - Automatically determines work vs personal
4. **Conditional Templates** - Different configs per machine type
5. **Package Automation** - Installs packages based on machine type
6. **Shell Setup** - Oh My Zsh, Powerlevel10k, plugins
7. **Run-Once Scripts** - Setup scripts run once per machine
8. **Documentation** - Complete guides and quick references
9. **Safe Development** - Test before committing
10. **Version Controlled** - All in git, reproducible

---

## ⚠️ Important Notes

1. **Push to GitHub First**: Scripts pull from GitHub, so commit and push before testing
2. **Test Minimal First**: Always test with minimal script before comprehensive
3. **Review Diffs**: Check `chezmoi diff` output carefully
4. **Secrets**: Never commit secrets, use environment variables or prompts
5. **Backup**: Keep backups of important configs before testing

---

## 🆘 Troubleshooting

### View configuration data
```bash
chezmoi data
```

### See what would change
```bash
chezmoi diff
```

### Re-run setup scripts
```bash
chezmoi state delete-bucket --bucket=scriptState
chezmoi apply -v
```

### Start completely fresh
```bash
rm -rf ~/.local/share/chezmoi ~/.config/chezmoi
curl -fsLS https://raw.githubusercontent.com/solaegis/chezmoi/main/install-comprehensive.sh | bash
```

---

**You now have a complete automation system for chezmoi installation!** 🎊
