# Changelog

All notable changes to this chezmoi configuration will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Comprehensive documentation consolidation (README + docs/)
- Pre-commit hooks with validation, linting, and security checks
- Security audit task (`task security:audit`)
- Dependency update task (`task deps:update`)
- Encryption helper task (`task chezmoi:encrypt`)
- Pre-commit setup task (`task setup:pre-commit`)
- Comprehensive SECURITY.md documentation
- Comprehensive TROUBLESHOOTING.md documentation
- GitHub Actions workflow for automated validation
- CHANGELOG.md for tracking changes

### Changed
- Fixed architecture mismatch (amd64 → arm64) in chezmoi.toml
- Fixed Taskfile variables from Windows-style to dynamic paths
- Simplified Brewfile template to use `.is_work` instead of hostname checks
- Consolidated 5 README files into organized documentation structure
- Updated pre-commit configuration with comprehensive hooks
- Enhanced Taskfile with 45+ commands

### Removed
- Unused `zsh_defer_init()` function from .zshrc
- Redundant README files (moved to docs/)

### Fixed
- Architecture detection for Apple Silicon Macs
- Taskfile cross-platform compatibility
- Template logic consistency

## [1.0.0] - 2025-12-09

### Initial Release
- Age encryption setup
- Machine-specific templating (work/personal)
- Comprehensive installation scripts
- Taskfile automation (40+ commands)
- Run-once scripts for reproducible setups
- Modular zsh configuration
- Brewfile for package management
- Oh My Zsh + Powerlevel10k theme
- SSH agent configuration
- iTerm2 integration
