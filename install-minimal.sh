#!/bin/bash

# ============================================================================
# Minimal Chezmoi Test Installation Script
# ============================================================================
# Purpose: Test configuration detection and validate machine-specific setup
# Usage: curl -fsLS https://raw.githubusercontent.com/solaegis/chezmoi/main/install-minimal.sh | bash
#
# This script will:
# 1. Detect machine type (work/personal)
# 2. Install chezmoi (if not present)
# 3. Initialize chezmoi repository (dry-run mode)
# 4. Show what configurations would be applied
# 5. NOT apply any dotfiles (for testing only)
# ============================================================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
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

# Banner
echo "============================================================================"
echo "  Minimal Chezmoi Test Installation"
echo "============================================================================"
echo ""

# 1. Detect machine information
log_info "Detecting machine information..."
HOSTNAME=$(hostname -s)
OS=$(uname -s)
ARCH=$(uname -m)

echo "  Hostname: $HOSTNAME"
echo "  OS: $OS"
echo "  Architecture: $ARCH"
echo ""

# 2. Check for existing chezmoi configuration
CHEZMOI_CONFIG_FILE="$HOME/.config/chezmoi/.chezmoidata.yaml"
CONFIG_EXISTS=false

if [ -f "$CHEZMOI_CONFIG_FILE" ]; then
    CONFIG_EXISTS=true
    log_success "Found existing chezmoi configuration at: $CHEZMOI_CONFIG_FILE"
    
    # Load existing configuration
    log_info "Loading previous configuration..."
    
    # Use simple text parsing (more reliable than requiring yaml/yq)
    STORED_MACHINE_TYPE=$(grep "^machine_type:" "$CHEZMOI_CONFIG_FILE" 2>/dev/null | sed 's/machine_type: *//; s/"//g; s/'"'"'//g' || echo "personal")
    STORED_EMAIL=$(grep "^email:" "$CHEZMOI_CONFIG_FILE" 2>/dev/null | sed 's/email: *//; s/"//g; s/'"'"'//g' || echo "")
    STORED_GITHUB_USER=$(grep "^github_user:" "$CHEZMOI_CONFIG_FILE" 2>/dev/null | sed 's/github_user: *//; s/"//g; s/'"'"'//g' || echo "solaegis")
    STORED_FULL_NAME=$(grep "^full_name:" "$CHEZMOI_CONFIG_FILE" 2>/dev/null | sed 's/full_name: *//; s/"//g; s/'"'"'//g' || echo "")
        
    echo "  Previous Machine Type: $STORED_MACHINE_TYPE"
    echo "  Previous Email: $STORED_EMAIL"
    echo "  Previous GitHub User: $STORED_GITHUB_USER"
    echo "  Previous Full Name: $STORED_FULL_NAME"
    echo ""
else
    log_info "No existing chezmoi configuration found"
fi
echo ""

# 3. Detect machine type based on hostname (with stored value as fallback)
log_info "Detecting machine type..."
if [ "$CONFIG_EXISTS" = true ] && [ -n "$STORED_MACHINE_TYPE" ]; then
    MACHINE_TYPE="$STORED_MACHINE_TYPE"
    log_success "Using stored machine type: $MACHINE_TYPE"
else
    MACHINE_TYPE="personal"
    if [[ "$HOSTNAME" =~ work|corp|company|office ]]; then
        MACHINE_TYPE="work"
        log_success "Auto-detected WORK machine (based on hostname pattern)"
    else
        log_success "Auto-detected PERSONAL machine (default)"
    fi
fi
echo ""

# 4. Prompt for confirmation or override
if [ "$CONFIG_EXISTS" = true ]; then
    read -p "Use stored configuration? (y/n/edit) [y]: " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        log_info "Collecting new configuration..."
        read -p "Machine type (work/personal) [$MACHINE_TYPE]: " NEW_MACHINE_TYPE
        MACHINE_TYPE=${NEW_MACHINE_TYPE:-$MACHINE_TYPE}
        
        read -p "Email address [$STORED_EMAIL]: " NEW_EMAIL
        EMAIL=${NEW_EMAIL:-$STORED_EMAIL}
        
        read -p "GitHub username [$STORED_GITHUB_USER]: " NEW_GITHUB_USER
        GITHUB_USER=${NEW_GITHUB_USER:-$STORED_GITHUB_USER}
        
        read -p "Full name [$STORED_FULL_NAME]: " NEW_FULL_NAME
        FULL_NAME=${NEW_FULL_NAME:-$STORED_FULL_NAME}
    elif [[ $REPLY =~ ^[Ee]$ ]]; then
        log_info "Edit mode - press Enter to keep current values..."
        read -p "Machine type (work/personal) [$MACHINE_TYPE]: " NEW_MACHINE_TYPE
        MACHINE_TYPE=${NEW_MACHINE_TYPE:-$MACHINE_TYPE}
        
        read -p "Email address [$STORED_EMAIL]: " NEW_EMAIL
        EMAIL=${NEW_EMAIL:-$STORED_EMAIL}
        
        read -p "GitHub username [$STORED_GITHUB_USER]: " NEW_GITHUB_USER
        GITHUB_USER=${NEW_GITHUB_USER:-$STORED_GITHUB_USER}
        
        read -p "Full name [$STORED_FULL_NAME]: " NEW_FULL_NAME
        FULL_NAME=${NEW_FULL_NAME:-$STORED_FULL_NAME}
    else
        # Use stored values
        EMAIL="$STORED_EMAIL"
        GITHUB_USER="$STORED_GITHUB_USER"
        FULL_NAME="$STORED_FULL_NAME"
    fi
else
    # First time setup - prompt for confirmation and collect info
    read -p "Is this a work machine? (y/n) [auto-detected: $MACHINE_TYPE]: " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        MACHINE_TYPE="work"
    elif [[ $REPLY =~ ^[Nn]$ ]]; then
        MACHINE_TYPE="personal"
    fi
    
    log_info "Collecting user information..."
    read -p "Email address: " EMAIL
    read -p "GitHub username [solaegis]: " GITHUB_USER
    GITHUB_USER=${GITHUB_USER:-solaegis}
    read -p "Full name: " FULL_NAME
fi

log_info "Configuration set to: $MACHINE_TYPE"
echo ""

# 6. Display configuration summary
echo "============================================================================"
log_info "Configuration Summary"
echo "============================================================================"
echo "  Machine Type: $MACHINE_TYPE"
echo "  Email: $EMAIL"
echo "  GitHub User: $GITHUB_USER"
echo "  Full Name: $FULL_NAME"
echo "  Hostname: $HOSTNAME"
echo ""

# 7. Check if chezmoi is installed
log_info "Checking for chezmoi installation..."
if command -v chezmoi &> /dev/null; then
    CHEZMOI_VERSION=$(chezmoi --version | head -n1)
    log_success "Chezmoi is already installed: $CHEZMOI_VERSION"
else
    log_warning "Chezmoi is not installed"
    read -p "Install chezmoi now? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "Installing chezmoi..."

        # Check if Homebrew is available
        if command -v brew &> /dev/null; then
            log_info "Installing via Homebrew..."
            brew install chezmoi
        else
            log_info "Installing via shell script..."
            sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
            export PATH="$HOME/.local/bin:$PATH"
        fi

        log_success "Chezmoi installed successfully"
    else
        log_error "Chezmoi installation skipped. Cannot proceed with test."
        exit 1
    fi
fi
echo ""

# 8. Check if chezmoi is already initialized
if [ -d "$HOME/.local/share/chezmoi" ]; then
    log_warning "Chezmoi is already initialized at ~/.local/share/chezmoi"
    read -p "Remove existing chezmoi directory and re-initialize? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "Removing existing chezmoi directory..."
        rm -rf "$HOME/.local/share/chezmoi"
    else
        log_info "Using existing chezmoi directory"
    fi
fi
echo ""

# 9. Initialize chezmoi (but don't apply)
log_info "Initializing chezmoi from repository..."
chezmoi init --apply=false "https://github.com/${GITHUB_USER}/chezmoi.git"
log_success "Chezmoi initialized successfully"
echo ""

# 10. Show what would be applied
log_info "Showing differences (what would be applied)..."
echo "============================================================================"
chezmoi diff || true
echo "============================================================================"
echo ""

# 11. Show managed files
log_info "Files that would be managed:"
echo "============================================================================"
chezmoi managed
echo "============================================================================"
echo ""

# 12. Show data values
log_info "Configuration data that will be used:"
echo "============================================================================"
chezmoi data || true
echo "============================================================================"
echo ""

# 13. Summary and next steps
echo "============================================================================"
log_success "Minimal Test Installation Complete!"
echo "============================================================================"
echo ""
echo "Next steps:"
echo "  1. Review the differences shown above"
echo "  2. Verify the configuration data is correct"
echo "  3. If everything looks good, run the comprehensive install:"
echo ""
echo "     ${GREEN}chezmoi apply -v${NC}"
echo ""
echo "  4. Or use the comprehensive installation script:"
echo ""
echo "     ${GREEN}curl -fsLS https://raw.githubusercontent.com/${GITHUB_USER}/chezmoi/main/install-comprehensive.sh | bash${NC}"
echo ""
echo "  5. To make changes to templates before applying:"
echo ""
echo "     ${GREEN}chezmoi edit ~/.zshrc${NC}"
echo "     ${GREEN}chezmoi diff${NC}"
echo "     ${GREEN}chezmoi apply${NC}"
echo ""
echo "  6. To clean up this test installation:"
echo ""
echo "     ${GREEN}rm -rf ~/.local/share/chezmoi${NC}"
echo ""
log_info "Test installation directory preserved at: ~/.local/share/chezmoi"

# Fix zsh completion permissions (Intel & Apple Silicon Mac compatible)
if command -v brew &> /dev/null; then
    log_info "Fixing zsh completion directory permissions..."
    
    # Get active brew prefix and fix common paths
    BREW_PREFIX="$(brew --prefix)"
    ZSH_DIRS=(
        "$BREW_PREFIX/share/zsh/site-functions"
        "$BREW_PREFIX/share/zsh-completions"
        "/opt/homebrew/share/zsh/site-functions"    # Apple Silicon
        "/opt/homebrew/share/zsh-completions"
        "/usr/local/share/zsh/site-functions"       # Intel Mac
        "/usr/local/share/zsh-completions"
    )
    
    for dir in "${ZSH_DIRS[@]}"; do
        if [ -d "$dir" ]; then
            chmod -R go-w "$dir" 2>/dev/null || true
            echo "  ✓ Fixed permissions on $dir"
        fi
    done
    
    # Clear completion cache (multiple possible locations)
    CACHE_DIRS=(
        "$HOME/.cache/zsh"
        "$HOME/.zcompdump"*
        "/tmp/zsh-*"
    )
    
    for cache_pattern in "${CACHE_DIRS[@]}"; do
        if ls $cache_pattern 2>/dev/null; then
            rm -rf $cache_pattern 2>/dev/null || true
            echo "  ✓ Cleared completion cache: $cache_pattern"
        fi
    done
fi

echo "============================================================================"
