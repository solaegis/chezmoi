# Security Guide

## Age Encryption

This dotfiles setup uses [age](https://github.com/FiloSottile/age) encryption for sensitive files.

### Key Management

**Identity (Private Key):**
- Location: `~/.config/chezmoi/key.txt`
- **CRITICAL:** Backup this file securely!

**Recipient (Public Key):**
- Configured in `~/.config/chezmoi/chezmoi.toml`
- Current: `age14gv0zs9kfn70tmmt7cpxx5zhdys5cy69dkm5epxrv8zthwt7zfxq4maad6`

### Backup Strategy

**Recommended approach:**

1. **Secure backup of private key:**
   ```bash
   # Copy to secure location (external drive, password manager, etc.)
   cp ~/.config/chezmoi/key.txt /path/to/secure/backup/
   ```

2. **Multiple backups:**
   - Password manager (1Password, Bitwarden, etc.)
   - Encrypted USB drive
   - Secure cloud storage (encrypted)

3. **Test recovery:**
   ```bash
   # Periodically verify you can decrypt with backup
   age -d -i /path/to/backup/key.txt ~/.ssh/id_rsa.age
   ```

### Encrypting Files

```bash
# Add encrypted file to chezmoi
chezmoi add --encrypt ~/.ssh/id_rsa

# Using Taskfile
task chezmoi:encrypt ~/.ssh/config

# Add template that generates encrypted file
chezmoi add --encrypt --template ~/.env
```

### Viewing Encrypted Files

```bash
# View decrypted content
chezmoi cat ~/.ssh/id_rsa

# Edit encrypted file
chezmoi edit ~/.ssh/config
```

### What to Encrypt

**Should be encrypted:**
- SSH private keys
- API tokens and secrets
- AWS credentials
- GPG private keys
- `.env` files with secrets
- Sensitive configuration files

**Should NOT be encrypted:**
- Public configuration files
- Shell aliases and functions
- Non-sensitive dotfiles
- README and documentation

### Key Rotation

If you need to rotate your age key:

```bash
# 1. Generate new key pair
age-keygen -o ~/.config/chezmoi/key-new.txt

# 2. Update chezmoi.toml with new recipient
chezmoi edit --config

# 3. Re-encrypt all files
chezmoi re-add --encrypt ~/.ssh/id_rsa
# Repeat for all encrypted files

# 4. Replace old key
mv ~/.config/chezmoi/key-new.txt ~/.config/chezmoi/key.txt

# 5. Backup new key securely
```

### Security Best Practices

1. **Never commit secrets directly**
   - Always use encryption or environment variables
   - Use `.chezmoiignore` for local secrets

2. **Review diffs before applying**
   ```bash
   chezmoi diff
   ```

3. **Use private files**
   - Prefix: `private_` sets file to 0600 permissions
   - Example: `private_dot_ssh_config`

4. **Regular audits**
   ```bash
   # Check for potential secrets
   task security:audit
   
   # Or manually with trufflehog
   trufflehog filesystem ~/.local/share/chezmoi
   ```

5. **Emergency procedures**
   - If key is compromised, rotate immediately
   - Review git history for accidental commits
   - Update all encrypted files

### Troubleshooting

**Problem:** Can't decrypt files  
**Solution:** Verify identity file location and permissions

**Problem:** Lost encryption key  
**Solution:** Restore from backup, re-encrypt if necessary

**Problem:** Want to remove encryption  
**Solution:**
```bash
# Remove file from chezmoi
chezmoi remove ~/.ssh/id_rsa

# Add back without encryption
chezmoi add ~/.ssh/id_rsa
```

## Additional Security

### SSH Agent Configuration

See [SSH_AGENT.md](SSH_AGENT.md) for SSH agent setup and security.

### Git Commit Verification

Consider signing commits:
```bash
# In .gitconfig
[user]
    signingkey = YOUR_GPG_KEY
[commit]
    gpgsign = true
```

### Regular Security Checks

```bash
# Run pre-commit hooks
pre-commit run --all-files

# Lint shell scripts
task validate:lint

# Check repository structure
task validate:repo
```
