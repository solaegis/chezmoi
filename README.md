# Automated Installation Guide

This repository includes comprehensive automation for installing chezmoi and your dotfiles on a new Mac.

## Quick Start

### One-Line Comprehensive Installation

For a complete, automated setup on a new Mac:

```bash
curl -fsLS https://raw.githubusercontent.com/solaegis/chezmoi/main/install-comprehensive.sh | bash
```

This will:
- ✓ Install Xcode Command Line Tools
- ✓ Install Homebrew
- ✓ Install chezmoi
- ✓ Clone your dotfiles
- ✓ Detect machine type (work/personal)
- ✓ Apply dotfiles with templates
- ✓ Install packages based on machine type
- ✓ Configure shell (Oh My Zsh, Powerlevel10k, plugins)

### Minimal Test Installation

To test configuration detection without applying dotfiles:

```bash
curl -fsLS https://raw.githubusercontent.com/solaegis/chezmoi/main/install-minimal.sh | bash
```

This will:
- ✓ Detect machine type (work/personal)
- ✓ Install chezmoi (if needed)
- ✓ Clone repository
- ✓ Show what would be applied (dry-run)
- ✗ **Does NOT apply** any dotfiles

Perfect for:
- Testing on a new machine
- Validating templates
- Developing conditional configurations
- Previewing changes before committing

## Installation Scripts

### 1. Comprehensive Installation (`install-comprehensive.sh`)

**Purpose:** Complete automation for production use

**Features:**
- Installs all dependencies (Xcode, Homebrew, chezmoi)
- Auto-detects machine type (work/personal) based on hostname
- Prompts for user information (email, name, GitHub username)
- Applies all dotfiles with proper templating
- Runs all `run_once_*` scripts for package installation
- Configures shell environment
- Interactive confirmations at key steps

**Usage:**
```bash
# Via curl
curl -fsLS https://raw.githubusercontent.com/solaegis/chezmoi/main/install-comprehensive.sh | bash

# Or download and run
wget https://raw.githubusercontent.com/solaegis/chezmoi/main/install-comprehensive.sh
chmod +x install-comprehensive.sh
./install-comprehensive.sh
```

**Environment Variables:**
```bash
# Customize repository
export CHEZMOI_GITHUB_USER="your-username"
export CHEZMOI_GITHUB_REPO="your-repo"
export CHEZMOI_GITHUB_BRANCH="your-branch"

curl -fsLS https://raw.githubusercontent.com/${CHEZMOI_GITHUB_USER}/${CHEZMOI_GITHUB_REPO}/${CHEZMOI_GITHUB_BRANCH}/install-comprehensive.sh | bash
```

### 2. Minimal Test Installation (`install-minimal.sh`)

**Purpose:** Safe testing and development

**Features:**
- Minimal installation (just chezmoi)
- Shows diffs without applying
- Tests machine type detection
- Validates template rendering
- No destructive changes
- Easy cleanup

**Usage:**
```bash
# Via curl
curl -fsLS https://raw.githubusercontent.com/solaegis/chezmoi/main/install-minimal.sh | bash

# Or download and run
wget https://raw.githubusercontent.com/solaegis/chezmoi/main/install-minimal.sh
chmod +x install-minimal.sh
./install-minimal.sh
```

**Workflow:**
1. Run minimal install on test machine
2. Review configuration and diffs
3. If everything looks good, apply changes:
   ```bash
   chezmoi apply -v
   ```
4. Or start over:
   ```bash
   rm -rf ~/.local/share/chezmoi
   ```

## Machine-Specific Configuration

The installation system supports different configurations for work and personal machines.

### Machine Type Detection

The system automatically detects machine type based on hostname:
- Contains "work", "corp", "company", or "office" → **WORK**
- Otherwise → **PERSONAL**

You can override during installation when prompted.

### Configuration File (`.chezmoidata.yaml`)

After first run, your configuration is stored in `~/.config/chezmoi/.chezmoidata.yaml`:

```yaml
machine_type: "work"  # or "personal"
email: "your@email.com"
github_user: "solaegis"
full_name: "Your Name"
hostname: "your-hostname"
os: "darwin"
arch: "arm64"

# Conditional flags
is_work: true
is_personal: false
git_work_enabled: true
vpn_required: true

# Package installation preferences
install_dev_tools: true
install_cloud_tools: true  # work only
install_gaming_tools: false  # personal only
```

### Using Configuration in Templates

In any `.tmpl` file, you can use these values:

```bash
# ~/.zshrc.tmpl
{{- if .is_work }}
# Work-specific configuration
export WORK_PROXY="http://proxy.company.com:8080"
alias vpn="sudo openconnect vpn.company.com"
{{- end }}

{{- if .is_personal }}
# Personal configuration
export HOBBY_PROJECT_DIR="~/projects"
{{- end }}

# Common configuration
export EMAIL="{{ .email }}"
export GITHUB_USER="{{ .github_user }}"
```

## Run-Once Scripts

These scripts run automatically during `chezmoi apply`:

### `run_once_before_01-install-homebrew.sh`
- Runs **before** applying dotfiles
- Installs Homebrew if not present
- macOS only

### `run_once_after_02-install-packages.sh`
- Runs **after** applying dotfiles
- Installs packages based on machine type:
  - **Essential:** git, curl, vim, direnv, jq, ripgrep, etc.
  - **Dev Tools:** go, python3, node, rust (if enabled)
  - **Work:** terraform, gcloud, awscli, kubectl (work only)
  - **Personal:** gaming/media tools (personal only)

### `run_once_after_03-configure-shell.sh`
- Runs **after** applying dotfiles
- Sets zsh as default shell
- Installs Oh My Zsh
- Installs Powerlevel10k theme
- Installs zsh plugins (autosuggestions, syntax-highlighting)

### Force Re-running Scripts

Run-once scripts only execute once. To re-run:

```bash
# Re-run all
chezmoi state delete-bucket --bucket=scriptState

# Re-run specific script
rm ~/.config/chezmoi/chezmoistate.boltdb
chezmoi apply -v
```

## Development Workflow

### Testing New Configurations

1. **Test on current machine:**
   ```bash
   chezmoi diff
   chezmoi apply --dry-run -v
   ```

2. **Test on new machine (minimal):**
   ```bash
   curl -fsLS https://raw.githubusercontent.com/solaegis/chezmoi/main/install-minimal.sh | bash
   # Review output
   rm -rf ~/.local/share/chezmoi  # Clean up
   ```

3. **Commit and push changes:**
   ```bash
   chezmoi cd
   git add .
   git commit -m "Update configurations"
   git push
   ```

4. **Full test installation:**
   ```bash
   curl -fsLS https://raw.githubusercontent.com/solaegis/chezmoi/main/install-comprehensive.sh | bash
   ```

### Adding Machine-Specific Configurations

1. **Edit template files:**
   ```bash
   chezmoi edit ~/.zshrc
   ```

2. **Add conditionals:**
   ```bash
   {{- if .is_work }}
   # Work-specific code
   {{- end }}
   ```

3. **Test locally:**
   ```bash
   chezmoi diff
   chezmoi apply
   ```

4. **Test with minimal install** on another machine

5. **Commit when ready:**
   ```bash
   chezmoi cd
   git add .
   git commit -m "Add work-specific configuration"
   git push
   ```

## Troubleshooting

### Check Configuration Data

```bash
chezmoi data
```

### View Rendered Template

```bash
chezmoi cat ~/.zshrc
```

### See What Would Change

```bash
chezmoi diff
```

### Re-initialize

```bash
# Backup current
mv ~/.local/share/chezmoi ~/.local/share/chezmoi.backup

# Re-initialize
chezmoi init --apply=false solaegis/chezmoi
chezmoi diff
chezmoi apply -v
```

### Debug Templates

```bash
# Check for template errors
chezmoi execute-template < ~/.local/share/chezmoi/dot_zshrc.tmpl

# Verbose apply
chezmoi apply -v
```

### Clean State and Restart

```bash
# Remove chezmoi completely
rm -rf ~/.local/share/chezmoi
rm -rf ~/.config/chezmoi

# Reinstall
curl -fsLS https://raw.githubusercontent.com/solaegis/chezmoi/main/install-comprehensive.sh | bash
```

## Advanced Usage

### Environment Variables

Control installation behavior:

```bash
# Use different repository
export CHEZMOI_GITHUB_USER="your-username"
export CHEZMOI_GITHUB_REPO="dotfiles"

# Force machine type
export CHEZMOI_MACHINE_TYPE="work"

# Skip interactive prompts (use defaults)
export CHEZMOI_NON_INTERACTIVE="true"
```

### Custom Installation

```bash
# Install chezmoi only (no apply)
brew install chezmoi

# Initialize without applying
chezmoi init --apply=false solaegis/chezmoi

# Review
chezmoi diff

# Apply selectively
chezmoi apply ~/.zshrc
chezmoi apply ~/.gitconfig

# Apply everything
chezmoi apply -v
```

### Update Existing Installation

```bash
# Pull latest changes and apply
chezmoi update

# Or manually
chezmoi cd
git pull
exit
chezmoi apply -v
```

## Security Notes

1. **Secrets Management:** This configuration uses environment variables and prompts for sensitive data. Never commit secrets directly.

2. **Review Before Applying:** Always review diffs before applying:
   ```bash
   chezmoi diff
   ```

3. **Test First:** Use the minimal installation script to test on new machines before committing to full installation.

4. **Private Files:** Files prefixed with `private_` are set to `0600` permissions automatically.

## Next Steps

After installation:

1. **Restart terminal** to load new configuration
2. **Review applied files:** `chezmoi managed`
3. **Customize further:** `chezmoi edit <file>`
4. **Keep updated:** `chezmoi update`

## Resources

- [Chezmoi Documentation](https://www.chezmoi.io/)
- [Template Reference](https://www.chezmoi.io/reference/templates/)
- [Your Repository](https://github.com/solaegis/chezmoi)

---

*For detailed chezmoi usage, see [README.md](README.md)*
