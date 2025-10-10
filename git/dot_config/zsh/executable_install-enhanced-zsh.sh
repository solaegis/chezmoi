#!/bin/bash
# ============================================================================
# Enhanced Zsh Ecosystem Implementation Script
# ============================================================================

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.zsh-backup-$(date +%Y%m%d_%H%M%S)"

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Create backup directory
create_backup() {
    log_info "Creating backup directory: $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
    
    # Backup existing zsh files
    for file in ~/.zshrc ~/.zshenv ~/.zprofile ~/.p10k.zsh; do
        if [[ -f "$file" ]]; then
            cp "$file" "$BACKUP_DIR/"
            log_success "Backed up $(basename "$file")"
        fi
    done
    
    # Backup existing config directory
    if [[ -d ~/.config/zsh ]]; then
        cp -r ~/.config/zsh "$BACKUP_DIR/zsh-config"
        log_success "Backed up existing zsh config"
    fi
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check if we're on macOS
    if [[ "$OSTYPE" != "darwin"* ]]; then
        log_warning "This script is optimized for macOS. Some features may not work on other systems."
    fi
    
    # Check for Homebrew
    if ! command -v brew &> /dev/null; then
        log_error "Homebrew not found. Please install Homebrew first:"
        echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        exit 1
    fi
    
    # Check for Zsh
    if ! command -v zsh &> /dev/null; then
        log_error "Zsh not found. Installing via Homebrew..."
        brew install zsh
    fi
    
    log_success "Prerequisites check completed"
}

# Install modern CLI tools
install_modern_tools() {
    log_info "Installing modern CLI tools..."
    
    local tools=(
        "eza"           # Better ls
        "bat"           # Better cat
        "ripgrep"       # Better grep
        "fd"            # Better find
        "dust"          # Better du
        "duf"           # Better df
        "htop"          # Better top
        "btop"          # Modern resource monitor
        "procs"         # Better ps
        "zoxide"        # Smart cd
        "fzf"           # Fuzzy finder
        "git-delta"     # Better git diff
        "hyperfine"     # Benchmarking tool
        "gping"         # Better ping
        "jq"            # JSON processor
        "yq"            # YAML processor
        "atuin"         # Magical shell history
        "mcfly"         # Neural network history search
        "tldr"          # Simplified man pages
        "gh"            # GitHub CLI
        "lazygit"       # Terminal UI for git
        "lazydocker"    # Terminal UI for docker
        "dog"           # Better dig
        "entr"          # File watcher
        "watchexec"     # File watcher with commands
        "tree"          # Directory tree viewer
    )
    
    for tool in "${tools[@]}"; do
        if brew list "$tool" &>/dev/null; then
            log_info "$tool is already installed"
        else
            log_info "Installing $tool..."
            brew install "$tool"
        fi
    done
    
    log_success "Modern CLI tools installation completed"
}

# Install Powerlevel10k if not present
install_powerlevel10k() {
    log_info "Checking Powerlevel10k installation..."
    
    local p10k_path="/usr/local/share/powerlevel10k"
    
    if [[ ! -d "$p10k_path" ]]; then
        log_info "Installing Powerlevel10k..."
        brew install powerlevel10k
    else
        log_success "Powerlevel10k is already installed"
    fi
}

# Setup directory structure
setup_directories() {
    log_info "Setting up directory structure..."
    
    local dirs=(
        "$HOME/.config/zsh"
        "$HOME/.config/shell"
        "$HOME/.cache/zsh"
        "$HOME/.local/bin"
        "$HOME/.local/share"
        "$HOME/.local/state"
    )
    
    for dir in "${dirs[@]}"; do
        mkdir -p "$dir"
        log_success "Created directory: $dir"
    done
}

# Install configuration files
install_configs() {
    log_info "Installing enhanced configuration files..."
    
    # Copy enhanced functions
    if [[ -f "$SCRIPT_DIR/enhanced-functions.zsh" ]]; then
        cp "$SCRIPT_DIR/enhanced-functions.zsh" "$HOME/.config/zsh/"
        chmod +x "$HOME/.config/zsh/enhanced-functions.zsh"
        log_success "Installed enhanced functions"
    fi
    
    # Copy modern aliases
    if [[ -f "$SCRIPT_DIR/modern-aliases.zsh" ]]; then
        cp "$SCRIPT_DIR/modern-aliases.zsh" "$HOME/.config/zsh/"
        chmod +x "$HOME/.config/zsh/modern-aliases.zsh"
        log_success "Installed modern aliases"
    fi
    
    # Install optimized .zshrc
    if [[ -f "$SCRIPT_DIR/optimized-zshrc" ]]; then
        cp "$SCRIPT_DIR/optimized-zshrc" "$HOME/.zshrc"
        log_success "Installed optimized .zshrc"
    fi
    
    # Create .zshrc.local for user customizations
    if [[ ! -f "$HOME/.zshrc.local" ]]; then
        cat > "$HOME/.zshrc.local" << 'EOF'
# ============================================================================
# Local Zsh Customizations
# ============================================================================
# Add your personal customizations here
# This file is sourced last and won't be overwritten by updates

# Example: Custom aliases
# alias myalias='command'

# Example: Custom functions
# myfunction() {
#     echo "Hello from custom function"
# }

# Example: Environment variables
# export MY_CUSTOM_VAR="value"

echo "🏠 Local customizations loaded"
EOF
        log_success "Created .zshrc.local for local customizations"
    fi
}

# Configure Powerlevel10k
configure_powerlevel10k() {
    log_info "Configuring Powerlevel10k..."
    
    if [[ ! -f "$HOME/.p10k.zsh" ]]; then
        log_info "Powerlevel10k config not found. Run 'p10k configure' after installation."
    else
        log_success "Powerlevel10k configuration already exists"
    fi
}

# Update shell to zsh
update_shell() {
    log_info "Checking default shell..."
    
    local current_shell=$(dscl . -read /Users/$USER UserShell | awk '{print $2}')
    local zsh_path=$(which zsh)
    
    if [[ "$current_shell" != "$zsh_path" ]]; then
        log_info "Changing default shell to zsh..."
        
        # Add zsh to allowed shells if not present
        if ! grep -q "$zsh_path" /etc/shells; then
            echo "$zsh_path" | sudo tee -a /etc/shells
        fi
        
        chsh -s "$zsh_path"
        log_success "Default shell changed to zsh"
    else
        log_success "Zsh is already the default shell"
    fi
}

# Create chezmoi integration
setup_chezmoi_integration() {
    log_info "Setting up chezmoi integration..."
    
    if command -v chezmoi &> /dev/null; then
        # Add config files to chezmoi if it's being used
        local files=(
            ".zshrc"
            ".config/zsh/enhanced-functions.zsh"
            ".config/zsh/modern-aliases.zsh"
        )
        
        for file in "${files[@]}"; do
            if [[ -f "$HOME/$file" ]]; then
                chezmoi add "$HOME/$file" 2>/dev/null || true
                log_success "Added $file to chezmoi"
            fi
        done
    else
        log_info "Chezmoi not found, skipping integration"
    fi
}

# Performance test
run_performance_test() {
    log_info "Running performance test..."
    
    if command -v hyperfine &> /dev/null; then
        log_info "Testing zsh startup time..."
        hyperfine --warmup 3 --runs 10 'zsh -i -c exit'
    else
        log_info "Installing hyperfine for performance testing..."
        brew install hyperfine
        hyperfine --warmup 3 --runs 10 'zsh -i -c exit'
    fi
}

# Generate report
generate_report() {
    log_info "Generating installation report..."
    
    local report_file="$HOME/zsh-enhancement-report.txt"
    
    cat > "$report_file" << EOF
# Zsh Enhancement Installation Report
Generated on: $(date)

## Files Modified/Created:
- ~/.zshrc (enhanced with performance optimizations)
- ~/.config/zsh/enhanced-functions.zsh (modern development functions)
- ~/.config/zsh/modern-aliases.zsh (contemporary aliases)
- ~/.zshrc.local (local customizations)

## Backup Location:
$BACKUP_DIR

## Modern Tools Installed:
- eza (better ls)
- bat (better cat)  
- ripgrep (better grep)
- fd (better find)
- dust (better du)
- duf (better df)
- htop (better top)
- procs (better ps)
- zoxide (smart cd)
- fzf (fuzzy finder)

## Key Features Added:
✅ Lazy loading for performance
✅ Advanced completion system
✅ Modern CLI tool aliases
✅ Enhanced git workflows
✅ Docker/Kubernetes utilities
✅ AWS/Terraform helpers
✅ Smart project management
✅ Security utilities
✅ Network diagnostics

## Next Steps:
1. Restart your terminal or run: source ~/.zshrc
2. Run 'p10k configure' if you want to customize your prompt
3. Explore new commands: czst, gci, mkcd, ff, weather, etc.
4. Check ~/.zshrc.local for local customizations

## Performance Tips:
- Use 'z' instead of 'cd' for smart navigation
- Use 'll' for enhanced directory listing
- Use 'gci' for conventional git commits
- Use 'projinit' for quick project setup

## Troubleshooting:
- If startup seems slow, check ~/.cache/zsh/
- For issues, check the backup in: $BACKUP_DIR
- Run 'zsh -xvs' to debug startup issues

Happy coding! 🚀
EOF

    log_success "Installation report saved to: $report_file"
}

# Main installation function
main() {
    echo "🚀 Enhanced Zsh Ecosystem Installation"
    echo "======================================"
    echo
    
    # Confirmation prompt
    read -p "This will modify your Zsh configuration. Continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Installation cancelled"
        exit 0
    fi
    
    # Run installation steps
    create_backup
    check_prerequisites
    install_modern_tools
    install_powerlevel10k
    setup_directories
    install_configs
    configure_powerlevel10k
    update_shell
    setup_chezmoi_integration
    generate_report
    
    echo
    log_success "🎉 Enhanced Zsh ecosystem installation completed!"
    echo
    echo "Next steps:"
    echo "1. Restart your terminal or run: source ~/.zshrc"
    echo "2. Run 'p10k configure' to customize your prompt"
    echo "3. Check the report: ~/zsh-enhancement-report.txt"
    echo "4. Backup location: $BACKUP_DIR"
    echo
    echo "New commands to try:"
    echo "  czst    - chezmoi status"
    echo "  gci     - interactive git commit"
    echo "  ll      - enhanced directory listing"
    echo "  mkcd    - create and enter directory"
    echo "  weather - local weather"
    echo "  sysinfo - system information"
    echo
    
    # Optional performance test
    read -p "Run performance test? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        run_performance_test
    fi
    
    log_success "Installation complete! Enjoy your enhanced Zsh experience! 🎯"
}

# Run main function
main "$@"
