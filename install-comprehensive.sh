#!/bin/bash

# ============================================================================
# Comprehensive Chezmoi Installation Script
# ============================================================================
# Purpose: Fully automated installation and setup for a new Mac
# Usage: curl -fsLS https://raw.githubusercontent.com/solaegis/chezmoi/main/install-comprehensive.sh | bash
#
# This script will:
# 1. Install Xcode Command Line Tools (if needed)
# 2. Install Homebrew (if not present)
# 3. Install chezmoi via Homebrew
# 4. Clone and apply dotfiles from GitHub
# 5. Run all post-installation scripts
# 6. Configure machine-specific settings
# ============================================================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Configuration
GITHUB_USER="${CHEZMOI_GITHUB_USER:-solaegis}"
GITHUB_REPO="${CHEZMOI_GITHUB_REPO:-chezmoi}"
GITHUB_BRANCH="${CHEZMOI_GITHUB_BRANCH:-main}"

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

log_step() {
    echo ""
    echo -e "${MAGENTA}==>${NC} $1"
    echo "============================================================================"
}

# Error handler
error_exit() {
    log_error "$1"
    exit 1
}

# Check if running on macOS
check_macos() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        error_exit "This script is designed for macOS only. Detected OS: $OSTYPE"
    fi
}

# Install Xcode Command Line Tools
install_xcode_tools() {
    log_step "Step 1: Checking Xcode Command Line Tools"

    if xcode-select -p &> /dev/null; then
        log_success "Xcode Command Line Tools already installed"
    else
        log_info "Installing Xcode Command Line Tools..."
        log_warning "This may take a few minutes and will prompt for your password"

        # Trigger installation
        xcode-select --install 2>/dev/null || true

        # Wait for installation to complete
        log_info "Waiting for installation to complete..."
        until xcode-select -p &> /dev/null; do
            sleep 5
        done

        log_success "Xcode Command Line Tools installed successfully"
    fi
}

# Install Homebrew
install_homebrew() {
    log_step "Step 2: Checking Homebrew"

    if command -v brew &> /dev/null; then
        log_success "Homebrew already installed: $(brew --version | head -n1)"
        log_info "Updating Homebrew..."
        brew update || log_warning "Failed to update Homebrew (continuing anyway)"
    else
        log_info "Installing Homebrew..."
        log_warning "This will prompt for your password"

        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Add Homebrew to PATH for this script
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -f "/usr/local/bin/brew" ]]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi

        log_success "Homebrew installed successfully"
    fi

    # Verify brew is in PATH
    if ! command -v brew &> /dev/null; then
        error_exit "Homebrew installation failed or not in PATH"
    fi
}

# Install chezmoi
install_chezmoi() {
    log_step "Step 3: Installing chezmoi"

    if command -v chezmoi &> /dev/null; then
        CHEZMOI_VERSION=$(chezmoi --version | head -n1)
        log_success "Chezmoi already installed: $CHEZMOI_VERSION"

        log_info "Upgrading chezmoi to latest version..."
        brew upgrade chezmoi || log_warning "Failed to upgrade chezmoi (continuing with current version)"
    else
        log_info "Installing chezmoi via Homebrew..."
        brew install chezmoi
        log_success "Chezmoi installed successfully"
    fi
}

# Detect machine type
detect_machine_type() {
    log_step "Step 4: Detecting machine configuration"

    HOSTNAME=$(hostname -s)
    OS=$(uname -s)
    ARCH=$(uname -m)

    log_info "Machine information:"
    echo "  Hostname: $HOSTNAME"
    echo "  OS: $OS"
    echo "  Architecture: $ARCH"
    echo ""

    # Detect machine type based on hostname
    MACHINE_TYPE="personal"
    if [[ "$HOSTNAME" =~ work|corp|company|office ]]; then
        MACHINE_TYPE="work"
        log_info "Auto-detected: WORK machine"
    else
        log_info "Auto-detected: PERSONAL machine"
    fi

    # Prompt for confirmation if running interactively
    if [ -t 0 ]; then
        echo ""
        read -p "Is this a work machine? (y/n) [detected: $MACHINE_TYPE]: " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            MACHINE_TYPE="work"
        elif [[ $REPLY =~ ^[Nn]$ ]]; then
            MACHINE_TYPE="personal"
        fi
    fi

    log_success "Machine type: $MACHINE_TYPE"
    export CHEZMOI_MACHINE_TYPE="$MACHINE_TYPE"
}

# Initialize chezmoi with dotfiles
initialize_chezmoi() {
    log_step "Step 5: Initializing chezmoi with dotfiles"

    # Check if already initialized
    if [ -d "$HOME/.local/share/chezmoi/.git" ]; then
        log_warning "Chezmoi already initialized"
        read -p "Reinitialize? This will backup existing config (y/n): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            log_info "Backing up existing chezmoi directory..."
            BACKUP_DIR="$HOME/.local/share/chezmoi.backup.$(date +%Y%m%d_%H%M%S)"
            mv "$HOME/.local/share/chezmoi" "$BACKUP_DIR"
            log_success "Backed up to: $BACKUP_DIR"
        else
            log_info "Skipping initialization, using existing repository"
            return 0
        fi
    fi

    log_info "Cloning dotfiles from GitHub: ${GITHUB_USER}/${GITHUB_REPO}"

    # Initialize without applying
    chezmoi init --apply=false "https://github.com/${GITHUB_USER}/${GITHUB_REPO}.git"

    log_success "Dotfiles repository cloned"
}

# Apply dotfiles
apply_dotfiles() {
    log_step "Step 6: Applying dotfiles"

    log_info "Showing what will be changed..."
    echo ""
    chezmoi diff || true
    echo ""

    # Prompt for confirmation if running interactively
    if [ -t 0 ]; then
        read -p "Apply these changes? (y/n): " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_warning "Dotfile application skipped by user"
            log_info "To apply later, run: chezmoi apply -v"
            return 0
        fi
    fi

    log_info "Applying dotfiles..."
    chezmoi apply -v

    log_success "Dotfiles applied successfully"
}

# Run post-installation tasks
post_installation() {
    log_step "Step 7: Running post-installation tasks"

    # Source the new shell configuration if available
    if [ -f "$HOME/.zshrc" ]; then
        log_info "New shell configuration applied"
        log_warning "Please restart your terminal or run: source ~/.zshrc"
    fi

    # Install Oh My Zsh if not present
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        log_info "Oh My Zsh not detected"
        if [ -t 0 ]; then
            read -p "Install Oh My Zsh? (y/n): " -n 1 -r
            echo ""
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                log_info "Installing Oh My Zsh..."
                sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
                log_success "Oh My Zsh installed"
            fi
        fi
    else
        log_success "Oh My Zsh already installed"
    fi

    # Check for Brewfile
    if [ -f "$HOME/.Brewfile" ] || chezmoi managed | grep -q "Brewfile"; then
        if [ -t 0 ]; then
            log_info "Brewfile detected"
            read -p "Install packages from Brewfile? (y/n): " -n 1 -r
            echo ""
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                log_info "Installing packages from Brewfile..."
                brew bundle --global || log_warning "Some packages failed to install"
                log_success "Brewfile packages installed"
            fi
        fi
    fi

    log_success "Post-installation tasks complete"
}

# Final summary
show_summary() {
    log_step "Installation Complete!"

    echo ""
    echo "✓ Xcode Command Line Tools installed"
    echo "✓ Homebrew installed and updated"
    echo "✓ Chezmoi installed and configured"
    echo "✓ Dotfiles applied from GitHub"
    echo "✓ Machine configured as: $MACHINE_TYPE"
    echo ""
    log_info "Next steps:"
    echo ""
    echo "  1. Restart your terminal or run: ${GREEN}source ~/.zshrc${NC}"
    echo "  2. Review applied changes: ${GREEN}chezmoi managed${NC}"
    echo "  3. Update dotfiles anytime: ${GREEN}chezmoi update${NC}"
    echo "  4. Edit dotfiles: ${GREEN}chezmoi edit <file>${NC}"
    echo "  5. Apply changes: ${GREEN}chezmoi apply -v${NC}"
    echo ""
    log_info "Useful commands:"
    echo ""
    echo "  chezmoi diff          # Show pending changes"
    echo "  chezmoi status        # Show status of managed files"
    echo "  chezmoi update        # Pull and apply updates from git"
    echo "  chezmoi cd            # Navigate to source directory"
    echo "  chezmoi doctor        # Check for common issues"
    echo ""
    log_success "Your Mac is now configured! 🎉"
    echo ""
}

# Main installation flow
main() {
    # Banner
    echo ""
    echo "============================================================================"
    echo "  Comprehensive Mac Setup with Chezmoi"
    echo "  Repository: ${GITHUB_USER}/${GITHUB_REPO}"
    echo "============================================================================"
    echo ""

    # Confirmation
    if [ -t 0 ]; then
        read -p "This will install/update Homebrew, chezmoi, and apply dotfiles. Continue? (y/n): " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_warning "Installation cancelled by user"
            exit 0
        fi
    fi

    # Run installation steps
    check_macos
    install_xcode_tools
    install_homebrew
    install_chezmoi
    detect_machine_type
    initialize_chezmoi
    apply_dotfiles
    post_installation
    show_summary
}

# Run main function
main "$@"
