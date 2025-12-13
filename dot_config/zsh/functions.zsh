#!/usr/bin/env zsh
# ============================================================================
# Consolidated Zsh Functions - Optimized and Deduplicated
# ============================================================================
# Managed by chezmoi
# This file merges functionality from functions.zsh and enhanced-functions.zsh
# ============================================================================

# ============================================================================
# Unset conflicting aliases before defining functions
# ============================================================================
# These aliases may be defined in modern-aliases.zsh, unalias them here
unalias tf 2>/dev/null || true
unalias git 2>/dev/null || true


# ============================================================================
# CHEZMOI FUNCTIONS
# ============================================================================

# Chezmoi status with enhanced display
czstatus() {
  chezmoi status --include=files,scripts,symlinks 2>/dev/null || echo "⚠️  Chezmoi not initialized"
}

# Chezmoi diff with bat pager if available
czdiff() {
  if command -v bat &>/dev/null; then
    chezmoi diff --pager=bat 2>/dev/null || chezmoi diff
  else
    chezmoi diff
  fi
}

# Update and show diff before applying
czupdate() {
  echo "🔄 Updating dotfiles..."
  chezmoi update --apply=false && chezmoi diff
  read -q "REPLY?Apply changes? (y/n): "
  echo
  if [[ $REPLY == "y" ]]; then
    czapply
  fi
}

# Apply with verbose output
czapply() {
  echo "✅ Applying dotfiles changes..."
  chezmoi apply --verbose
}

# Edit config with preferred editor
czeditconfig() {
  chezmoi edit-config --editor="${EDITOR:-code}"
}

# List managed files with bat
czmanaged() {
  if command -v bat &>/dev/null; then
    chezmoi managed | sort | bat --language=txt --style=plain --paging=never
  else
    chezmoi managed | sort
  fi
}

# Enhanced edit with validation
czed() {
  if [[ -z "$1" ]]; then
    echo "Usage: czed <file>"
    echo "Available files:"
    chezmoi managed | head -10
    return 1
  fi
  
  # Check if file exists in chezmoi
  if chezmoi managed | grep -q "$1"; then
    chezmoi edit "$1"
  else
    echo "⚠️  File '$1' not managed by chezmoi"
    echo "Did you mean one of these?"
    chezmoi managed | grep -i "$(basename "$1")" | head -5
  fi
}

# Smart push with validation
czpush() {
  local message="${1:-Update dotfiles - $(date "+%Y-%m-%d %H:%M:%S")}"
  
  echo "🔍 Checking for uncommitted changes..."
  chezmoi cd
  
  if ! git diff --quiet || ! git diff --cached --quiet; then
    git add .
    git status --short
    read -q "REPLY?📝 Commit these changes? (y/n): "
    echo
    if [[ $REPLY == "y" ]]; then
      git commit -m "$message"
      read -q "REPLY?🚀 Push to remote? (y/n): "
      echo
      if [[ $REPLY == "y" ]]; then
        git push
        echo "✅ Dotfiles pushed successfully!"
      fi
    fi
  else
    echo "✅ No changes to commit"
  fi
  cd -
}

# Smart pull with backup
czpull() {
  echo "🔄 Pulling latest dotfiles..."
  chezmoi cd
  
  # Stash any local changes
  git stash push -m "Auto-stash before pull $(date)"
  
  git pull
  if [[ $? -eq 0 ]]; then
    cd -
    echo "✅ Applying updated dotfiles..."
    chezmoi apply --verbose
    echo "✅ Dotfiles updated successfully!"
  else
    echo "❌ Pull failed, check for conflicts"
    cd -
  fi
}

# ============================================================================
# GIT FUNCTIONS
# ============================================================================

# Git status (short)
gst() { 
  git status --short --branch 2>/dev/null || echo "Not a git repository"
}

# Git add all with status
gaa() { 
  git add . && git status --short
}

# Git push with upstream tracking
gpush() {
  local branch=$(git branch --show-current 2>/dev/null)
  if [[ -n "$branch" ]]; then
    git push -u origin "$branch"
  else
    echo "Not in a git repository or no current branch"
  fi
}

# Git pull with rebase
gpull() { 
  git pull --rebase --autostash
}

# Enhanced commit with validation
gcm() {
  if [[ -z "$1" ]]; then
    echo "Usage: gcm <message>"
    echo "Recent commits:"
    git log --oneline -5
    return 1
  fi
  
  # Check for staged changes
  if git diff --cached --quiet; then
    echo "⚠️  No staged changes. Stage files first with 'git add'"
    return 1
  fi
  
  git commit -m "$1"
}

# Interactive conventional commit
gci() {
  local types=("feat" "fix" "docs" "style" "refactor" "perf" "test" "chore" "ci" "build")
  echo "Select commit type:"
  select type in "${types[@]}"; do
    if [[ -n "$type" ]]; then
      break
    fi
  done
  
  read -r "scope?Enter scope (optional): "
  read -r "message?Enter commit message: "
  
  if [[ -z "$message" ]]; then
    echo "❌ Commit message cannot be empty"
    return 1
  fi
  
  local commit_msg="$type"
  [[ -n "$scope" ]] && commit_msg="$commit_msg($scope)"
  commit_msg="$commit_msg: $message"
  
  echo "Commit message: $commit_msg"
  read -q "REPLY?Commit? (y/n): "
  echo
  if [[ $REPLY == "y" ]]; then
    git commit -m "$commit_msg"
  fi
}

# Git branch cleanup
gbclean() {
  echo "🧹 Cleaning up merged branches..."
  git branch --merged main | grep -v "main\|master\|develop" | xargs -n 1 git branch -d
  git remote prune origin
  echo "✅ Branch cleanup complete"
}

# Git worktree management
gwt() {
  local action="$1"
  case "$action" in
    "add")
      git worktree add "$2" "$3"
      ;;
    "list")
      git worktree list
      ;;
    "remove")
      git worktree remove "$2"
      ;;
    *)
      echo "Usage: gwt <add|list|remove> [args...]"
      echo "  gwt add <path> <branch>"
      echo "  gwt list"
      echo "  gwt remove <path>"
      ;;
  esac
}

# ============================================================================
# DEVELOPMENT FUNCTIONS
# ============================================================================

# Create directory and cd into it
mkcd() {
  if [[ -z "$1" ]]; then
    echo "Usage: mkcd <directory>"
    return 1
  fi
  mkdir -p "$1" && cd "$1"
  echo "📁 Created and entered: $(pwd)"
}

# Enhanced file finding
ff() {
  if [[ -z "$1" ]]; then
    echo "Usage: ff <pattern>"
    return 1
  fi
  find . -name "*$1*" -type f
}

# Directory size analysis
duh() {
  local target="${1:-.}"
  if command -v dust &>/dev/null; then
    dust "$target"
  else
    du -h "$target" | sort -h
  fi
}

# List files by size
lss() {
  if command -v eza &>/dev/null; then
    eza -la --sort=size --reverse "$@"
  else
    ls -lah "$@" | sort -k5 -h
  fi
}

# ============================================================================
# HOMEBREW FUNCTIONS
# ============================================================================

# Enhanced Brewfile update with backup
brewup() {
  echo "📦 Updating Brewfile with current installations..."
  local brewfile_path="$HOME/.Brewfile"
  local backup_path="${brewfile_path}.backup.$(date +%Y%m%d_%H%M%S)"
  
  # Create backup
  if [[ -f "$brewfile_path" ]]; then
    cp "$brewfile_path" "$backup_path"
    echo "🔒 Backup created: $backup_path"
  fi
  
  # Generate new Brewfile
  brew bundle dump --file="$brewfile_path" --force
  
  # Add to chezmoi if not already managed
  if command -v chezmoi &>/dev/null; then
    chezmoi add "$brewfile_path"
    echo "✅ Brewfile updated and added to chezmoi"
  fi
  
  # Show diff if backup exists
  if [[ -f "$backup_path" ]] && command -v bat &>/dev/null; then
    echo "📋 Changes made:"
    diff -u "$backup_path" "$brewfile_path" | bat --language=diff
  fi
}

# Homebrew cleanup and maintenance
brewclean() {
  echo "🧹 Cleaning up Homebrew..."
  brew cleanup
  brew doctor
  brew missing
  echo "✅ Homebrew cleanup complete"
}

# ============================================================================
# SYSTEM UTILITIES
# ============================================================================

# Enhanced weather function
weather() {
  local location="${1:-Suisun City, CA}"
  if command -v curl &>/dev/null; then
    curl -s "wttr.in/$location?format=3"
    echo
    curl -s "wttr.in/$location"
  else
    echo "❌ curl not available"
  fi
}

# Smart backup with timestamp
backup() {
  if [[ -z "$1" ]]; then
    echo "Usage: backup <file|directory>"
    return 1
  fi
  
  local source="$1"
  local timestamp=$(date +%Y%m%d_%H%M%S)
  local backup_name="${source}.backup.${timestamp}"
  
  if [[ -f "$source" ]]; then
    cp "$source" "$backup_name"
    echo "✅ File backup created: $backup_name"
  elif [[ -d "$source" ]]; then
    cp -r "$source" "$backup_name"
    echo "✅ Directory backup created: $backup_name"
  else
    echo "❌ Source not found: $source"
    return 1
  fi
}

# Process management
pskill() {
  if [[ -z "$1" ]]; then
    echo "Usage: pskill <process_name>"
    return 1
  fi
  
  local pids=$(pgrep -f "$1")
  if [[ -n "$pids" ]]; then
    echo "Found processes matching '$1':"
    ps -p $pids -o pid,ppid,user,comm
    read -q "REPLY?Kill these processes? (y/n): "
    echo
    if [[ $REPLY == "y" ]]; then
      echo $pids | xargs kill
      echo "✅ Processes killed"
    fi
  else
    echo "No processes found matching '$1'"
  fi
}

# Network information
netinfo() {
  echo "🌐 Network Information:"
  echo "External IP: $(curl -s ifconfig.me 2>/dev/null || echo 'Unable to fetch')"
  echo "Local IP: $(ipconfig getifaddr en0 2>/dev/null || echo 'Not connected')"
  echo "DNS Servers: $(scutil --dns | grep 'nameserver\[[0-9]*\]' | head -3)"
  echo "WiFi Network: $(networksetup -getairportnetwork en0 2>/dev/null | cut -d' ' -f4-)"
}

# Port checker
portcheck() {
  local port="$1"
  if [[ -z "$port" ]]; then
    echo "Usage: portcheck <port>"
    return 1
  fi
  
  if lsof -Pi :$port -sTCP:LISTEN -t &>/dev/null; then
    echo "✅ Port $port is in use:"
    lsof -Pi :$port -sTCP:LISTEN
  else
    echo "❌ Port $port is not in use"
  fi
}

# ============================================================================
# SSH AGENT MANAGEMENT
# ============================================================================

# Load SSH agent configuration if it exists
if [[ -f ~/.config/ssh/ssh-agent.conf ]]; then
  source ~/.config/ssh/ssh-agent.conf
fi

# Start SSH agent if not running
start_ssh_agent() {
  if ! pgrep -u "$USER" ssh-agent >/dev/null; then
    echo "🔑 Starting SSH agent..."
    eval "$(ssh-agent -s)" >/dev/null
    echo "✓ SSH agent started"
  else
    echo "✓ SSH agent already running"
  fi
}

# Load SSH keys into agent
load_ssh_keys() {
  local keys=()
  local loaded=0
  
  # Check for common SSH key files
  [[ -f ~/.ssh/id_ed25519 ]] && keys+=(~/.ssh/id_ed25519)
  [[ -f ~/.ssh/id_rsa ]] && keys+=(~/.ssh/id_rsa)
  [[ -f ~/.ssh/id_rsa_work ]] && keys+=(~/.ssh/id_rsa_work)
  [[ -f ~/.ssh/id_rsa_dnlc ]] && keys+=(~/.ssh/id_rsa_dnlc)
  [[ -f ~/.ssh/id_ecdsa ]] && keys+=(~/.ssh/id_ecdsa)
  [[ -f ~/.ssh/id_spartan ]] && keys+=(~/.ssh/id_spartan)
  
  if [[ ${#keys[@]} -eq 0 ]]; then
    echo "❌ No SSH keys found in ~/.ssh/"
    return 1
  fi
  
  echo "🔑 Loading SSH keys..."
  for key in "${keys[@]}"; do
    if ssh-add -l 2>/dev/null | grep -q "$(basename "$key")"; then
      echo "  ✓ $(basename "$key") already loaded"
    else
      if ssh-add "$key" 2>/dev/null; then
        echo "  ✓ Loaded $(basename "$key")"
        ((loaded++))
      else
        echo "  ❌ Failed to load $(basename "$key")"
      fi
    fi
  done
  
  if [[ $loaded -gt 0 ]]; then
    echo "✓ SSH agent ready with $loaded new keys"
  else
    echo "✓ SSH agent ready (all keys already loaded)"
  fi
}

# Show SSH agent status and loaded keys
ssh_status() {
  echo "🔑 SSH Agent Status:"
  if pgrep -u "$USER" ssh-agent >/dev/null; then
    echo "  ✓ SSH agent is running"
    echo "  📋 Loaded keys:"
    ssh-add -l 2>/dev/null | sed 's/^/    /' || echo "    No keys loaded"
  else
    echo "  ❌ SSH agent is not running"
  fi
  echo
  echo "  📁 Available keys:"
  ls -lh ~/.ssh/*.pub 2>/dev/null | sed 's/^/    /' || echo "    No public keys found"
}

# SSH agent aliases for convenience
ssh_list_keys() { ssh-add -l 2>/dev/null || echo "No keys loaded"; }
ssh_clear_keys() { ssh-add -D && echo "✓ All keys removed from agent"; }
ssh_reload_keys() { ssh_clear_keys && load_ssh_keys; }
stop_ssh_agent() { 
  if pgrep -u "$USER" ssh-agent >/dev/null; then
    pkill -u "$USER" ssh-agent && echo "✓ SSH agent stopped"
  else
    echo "SSH agent is not running"
  fi
}

# Auto-setup SSH agent (call this in your shell startup)
setup_ssh_agent() {
  start_ssh_agent
  load_ssh_keys
}

# ============================================================================
# TEXT PROCESSING UTILITIES
# ============================================================================

# JSON pretty print
json() {
  if [[ -z "$1" ]]; then
    python3 -m json.tool
  else
    python3 -m json.tool "$1"
  fi
}

# Base64 encode/decode
b64() {
  local action="$1"
  local input="$2"
  case "$action" in
    "encode"|"e")
      if [[ -z "$input" ]]; then
        base64
      else
        echo -n "$input" | base64
      fi
      ;;
    "decode"|"d")
      if [[ -z "$input" ]]; then
        base64 -d
      else
        echo -n "$input" | base64 -d
      fi
      ;;
    *)
      echo "Usage: b64 <encode|decode> [string]"
      echo "  b64 encode 'hello world'"
      echo "  echo 'hello' | b64 encode"
      ;;
  esac
}

# Generate secure password
genpass() {
  local length="${1:-16}"
  if command -v openssl &>/dev/null; then
    openssl rand -base64 $((length * 3 / 4)) | tr -d "=+/" | cut -c1-${length}
  else
    LC_ALL=C tr -dc 'A-Za-z0-9!"#$%&'\''()*+,-./:;<=>?@[\]^_`{|}~' < /dev/urandom | head -c ${length}
    echo
  fi
}

# ============================================================================
# PROJECT MANAGEMENT
# ============================================================================

# Smart project initialization
projinit() {
  local name="$1"
  local type="${2:-basic}"
  
  if [[ -z "$name" ]]; then
    echo "Usage: projinit <name> [type]"
    echo "Types: basic, python, node, rust, go"
    return 1
  fi
  
  mkdir -p "$name" && cd "$name"
  
  case "$type" in
    "python")
      echo "🐍 Initializing Python project..."
      echo "# $name" > README.md
      echo "*.pyc\n__pycache__/\n.venv/\n.env" > .gitignore
      python3 -m venv .venv
      source .venv/bin/activate
      pip install --upgrade pip
      ;;
    "node")
      echo "📦 Initializing Node.js project..."
      npm init -y
      echo "node_modules/\n.env\n*.log" > .gitignore
      echo "# $name" > README.md
      ;;
    "rust")
      echo "🦀 Initializing Rust project..."
      cargo init --name "$name"
      ;;
    "go")
      echo "🐹 Initializing Go project..."
      go mod init "$name"
      echo "# $name" > README.md
      echo "*.exe\n*.dll\n*.so\n*.dylib" > .gitignore
      ;;
    *)
      echo "📁 Initializing basic project..."
      echo "# $name" > README.md
      touch .gitignore
      ;;
  esac
  
  git init
  git add .
  git commit -m "Initial commit"
  echo "✅ Project '$name' initialized as $type project"
}

# ============================================================================
# DOCKER UTILITIES
# ============================================================================

# Docker cleanup
dclean() {
  echo "🐳 Cleaning Docker resources..."
  echo "Removing stopped containers..."
  docker container prune -f
  echo "Removing unused images..."
  docker image prune -f
  echo "Removing unused volumes..."
  docker volume prune -f
  echo "Removing unused networks..."
  docker network prune -f
  echo "✅ Docker cleanup complete"
  docker system df
}

# Quick container shell
dshell() {
  local container="$1"
  local shell="${2:-bash}"
  
  if [[ -z "$container" ]]; then
    echo "Usage: dshell <container> [shell]"
    echo "Running containers:"
    docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"
    return 1
  fi
  
  docker exec -it "$container" "$shell"
}

# ============================================================================
# TERRAFORM UTILITIES
# ============================================================================

# Terraform wrapper with safety checks
tf() {
  local cmd="$1"
  shift
  
  case "$cmd" in
    "plan")
      terraform plan -out=tfplan "$@"
      ;;
    "apply")
      if [[ -f "tfplan" ]]; then
        terraform apply tfplan
        rm -f tfplan
      else
        echo "⚠️  No plan file found. Run 'tf plan' first."
        return 1
      fi
      ;;
    "destroy")
      echo "🚨 DANGER: This will destroy infrastructure!"
      read -q "REPLY?Are you sure? (y/n): "
      echo
      if [[ $REPLY == "y" ]]; then
        terraform destroy "$@"
      fi
      ;;
    *)
      terraform "$cmd" "$@"
      ;;
  esac
}

# ============================================================================
# FUNCTION ALIASES (Provide short names after functions are defined)
# ============================================================================
alias czst="czstatus"
alias czdf="czdiff"
alias czup="czupdate"
alias czap="czapply"
alias czec="czeditconfig"
alias czls="czmanaged"

# SSH agent aliases
alias sshstatus="ssh_status"
alias sshstart="start_ssh_agent"
alias sshload="load_ssh_keys"
alias sshsetup="setup_ssh_agent"

# ============================================================================
# End of consolidated functions
# ============================================================================
