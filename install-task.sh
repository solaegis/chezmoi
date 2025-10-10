#!/bin/bash

# ============================================================================
# Install Task (Task Runner) for Development
# ============================================================================
# Purpose: Install Task runner for managing development workflows
# Usage: bash install-task.sh
# ============================================================================

set -e

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

# Check if Task is already installed
if command -v task &> /dev/null; then
    TASK_VERSION=$(task --version | head -n1)
    log_success "Task is already installed: $TASK_VERSION"
    exit 0
fi

log_info "Installing Task runner..."

# Detect OS
OS=$(uname -s)
ARCH=$(uname -m)

case "$OS" in
    "Darwin")
        if command -v brew &> /dev/null; then
            log_info "Installing via Homebrew (preferred method)..."
            brew install go-task/tap/go-task
        else
            log_warning "Homebrew not available, falling back to direct download..."
            # Download and install Task for macOS
            if [[ "$ARCH" == "arm64" ]]; then
                TASK_ARCH="arm64"
            else
                TASK_ARCH="amd64"
            fi

            TASK_VERSION="3.36.0"
            TASK_URL="https://github.com/go-task/task/releases/download/v${TASK_VERSION}/task_Darwin_${TASK_ARCH}.tar.gz"

            curl -fsSL "$TASK_URL" | tar -xz -C /usr/local/bin task
            chmod +x /usr/local/bin/task
        fi
        ;;
    "Linux")
        # Check for Homebrew on Linux first
        if command -v brew &> /dev/null; then
            log_info "Installing via Homebrew (preferred method)..."
            brew install go-task/tap/go-task
        elif command -v apt-get &> /dev/null; then
            log_info "Installing via apt..."
            sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b /usr/local/bin
        elif command -v yum &> /dev/null; then
            log_info "Installing via yum..."
            sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b /usr/local/bin
        else
            log_info "Installing via direct download..."
            sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b ~/.local/bin
            export PATH="$HOME/.local/bin:$PATH"
        fi
        ;;
    *)
        log_error "Unsupported OS: $OS"
        exit 1
        ;;
esac

# Verify installation
if command -v task &> /dev/null; then
    TASK_VERSION=$(task --version | head -n1)
    log_success "Task installed successfully: $TASK_VERSION"

    # Show available tasks
    echo ""
    log_info "Available tasks:"
    task --list
else
    log_error "Task installation failed"
    exit 1
fi
