#!/usr/bin/env zsh
# ============================================================================
# P10K Color Test Script
# ============================================================================

# Test different color schemes for p10k
test_p10k_colors() {
    echo "🎨 Testing p10k color schemes..."
    echo
    
    # Test basic colors
    echo "Basic colors:"
    for i in {0..15}; do
        printf "\033[38;5;${i}mColor %2d\033[0m " $i
        if (( (i + 1) % 8 == 0 )); then echo; fi
    done
    echo
    echo
    
    # Test extended colors (16-231)
    echo "Extended colors (sample):"
    for i in 16 22 28 34 40 46 52 58 64 70 76 82 88 94 100 106 112 118 124 130 136 142 148 154 160 166 172 178 184 190 196 202 208 214 220 226; do
        printf "\033[38;5;${i}mColor %3d\033[0m " $i
        if (( (i - 16 + 1) % 8 == 0 )); then echo; fi
    done
    echo
    echo
    
    # Test current p10k colors
    echo "Current p10k color scheme:"
    echo "Directory: \033[38;5;39m~/path/to/directory\033[0m"
    echo "Git clean: \033[38;5;76m✓ clean\033[0m"
    echo "Git modified: \033[38;5;220m● modified\033[0m"
    echo "Git untracked: \033[38;5;214m? untracked\033[0m"
    echo "Status OK: \033[38;5;76m✓\033[0m"
    echo "Status Error: \033[38;5;196m✗\033[0m"
    echo "Time: \033[38;5;117m12:34:56\033[0m"
    echo "Background jobs: \033[38;5;214m1 job\033[0m"
    echo "Virtual env: \033[38;5;141mvenv\033[0m"
    echo
}

# Quick color scheme switcher
switch_p10k_theme() {
    case $1 in
        "dark")
            echo "Switching to dark theme..."
            # Dark theme colors
            ;;
        "light")
            echo "Switching to light theme..."
            # Light theme colors
            ;;
        "colorful")
            echo "Switching to colorful theme..."
            # Colorful theme colors
            ;;
        *)
            echo "Available themes: dark, light, colorful"
            echo "Usage: switch_p10k_theme <theme>"
            ;;
    esac
}

# Show current p10k configuration
show_p10k_config() {
    echo "Current p10k configuration:"
    echo "Left segments: ${POWERLEVEL9K_LEFT_PROMPT_ELEMENTS[@]}"
    echo "Right segments: ${POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS[@]}"
    echo "Background: $POWERLEVEL9K_BACKGROUND"
    echo "Mode: $POWERLEVEL9K_MODE"
    echo
}

# Aliases for easy testing
alias p10k-test="test_p10k_colors"
alias p10k-show="show_p10k_config"
alias p10k-switch="switch_p10k_theme"

echo "P10K color test functions loaded!"
echo "Use: p10k-test, p10k-show, p10k-switch <theme>"
