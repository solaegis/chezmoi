# SSH Agent Configuration

This chezmoi configuration includes comprehensive SSH agent management for your zsh shell.

## Features

- **Automatic SSH agent startup** on shell initialization
- **Automatic key loading** for common SSH key types
- **Configurable key management** via `~/.config/ssh/ssh-agent.conf`
- **Convenient aliases** for SSH agent operations
- **Status monitoring** and key management functions

## Quick Start

The SSH agent will start automatically when you open a new shell. Your SSH keys will be loaded automatically.

## Available Commands

### Aliases
- `sshstatus` - Show SSH agent status and loaded keys
- `sshstart` - Start SSH agent manually
- `sshload` - Load SSH keys into agent
- `sshkill` - Stop SSH agent
- `sshrestart` - Restart SSH agent and reload keys
- `sshsetup` - Full setup (start agent + load keys)

### Functions
- `start_ssh_agent()` - Start SSH agent if not running
- `load_ssh_keys()` - Load available SSH keys
- `ssh_status()` - Display detailed status
- `kill_ssh_agent()` - Stop SSH agent
- `restart_ssh_agent()` - Restart and reload
- `setup_ssh_agent()` - Auto-setup on shell start

## Configuration

Edit `~/.config/ssh/ssh-agent.conf` to customize:

```bash
# Auto-add keys on startup (default: true)
export SSH_AUTO_ADD_KEYS=true

# Key files to load (space-separated)
export SSH_KEY_FILES="id_ed25519 id_rsa id_rsa_work id_rsa_dnlc id_ecdsa"

# Verbose output (default: false)
export SSH_VERBOSE=false

# SSH agent timeout (default: 0 = no timeout)
# export SSH_AGENT_TIMEOUT=3600
```

## Supported Key Types

The system automatically detects and loads:
- `id_ed25519` (Ed25519 keys)
- `id_rsa` (RSA keys)
- `id_rsa_work` (Work-specific RSA keys)
- `id_rsa_dnlc` (DNLC-specific RSA keys)
- `id_ecdsa` (ECDSA keys)

## Troubleshooting

1. **Check status**: `sshstatus`
2. **Manual setup**: `sshsetup`
3. **Restart agent**: `sshrestart`
4. **Enable verbose mode**: Set `SSH_VERBOSE=true` in config

## Integration with Chezmoi

All SSH agent configuration is managed by chezmoi and will be deployed to other servers when you run `chezmoi apply`.

