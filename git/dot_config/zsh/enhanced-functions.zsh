#!/usr/bin/env zsh
# ============================================================================
# Enhanced Zsh Functions - Modern Development Workflows
# ============================================================================

# ============================================================================
# CHEZMOI ENHANCEMENTS
# ============================================================================

# Enhanced chezmoi functions with error handling and validation
czst() { 
  chezmoi status --include=files,scripts,symlinks 2>/dev/null || echo "⚠️  Chezmoi not initialized"
}

czdf() { 
  chezmoi diff --pager=bat 2>/dev/null || chezmoi diff
}

czup() { 
  echo "🔄 Updating dotfiles..."
  chezmoi update --apply=false && chezmoi diff && czap
}

czap() { 
  echo "✅ Applying dotfiles changes..."
  chezmoi apply --verbose
}

czec() { 
  chezmoi edit-config --editor="${EDITOR:-code}"
}

czls() { 
  chezmoi managed | sort | bat --language=txt --style=plain --paging=never
}

# Enhanced edit function with validation
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
  echo "🔄 Creating backup before pull..."
  local backup_dir="$HOME/.config/chezmoi/backups/$(date +%Y%m%d_%H%M%S)"
  mkdir -p "$backup_dir"
  
  chezmoi cd
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
# GIT ENHANCEMENTS
# ============================================================================

# Smart git status with branch info
gst() { 
  git status --short --branch 2>/dev/null || echo "Not a git repository"
}

# Enhanced git add all
gaa() { 
  git add . && git status --short
}

# Push with upstream tracking
gpush() { 
  local branch=$(git branch --show-current 2>/dev/null)
  if [[ -n "$branch" ]]; then
    git push -u origin "$branch"
  else
    echo "Not in a git repository or no current branch"
  fi
}

# Pull with rebase
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

# Interactive commit with conventional format
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

# Smart directory creation and navigation
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
  
  if command -v fd &> /dev/null; then
    fd "$1"
  else
    find . -name "*$1*" -type f
  fi
}

# Directory size analysis
duh() {
  local target="${1:-.}"
  
  if command -v dust &> /dev/null; then
    dust "$target"
  else
    du -h "$target" | sort -h
  fi
}

# List files by size
lss() {
  if command -v eza &> /dev/null; then
    eza -la --sort=size --reverse "$@"
  else
    ls -lah "$@" | sort -k5 -h
  fi
}

# ============================================================================
# HOMEBREW ENHANCEMENTS
# ============================================================================

# Enhanced Brewfile update with backup
brewup() {
  echo "📦 Updating Brewfile with current installations..."
  
  local brewfile_path="$HOME/.config/brewfile/Brewfile"
  local backup_path="${brewfile_path}.backup.$(date +%Y%m%d_%H%M%S)"
  
  # Create backup
  if [[ -f "$brewfile_path" ]]; then
    cp "$brewfile_path" "$backup_path"
    echo "🔒 Backup created: $backup_path"
  fi
  
  # Generate new Brewfile
  brew bundle dump --file="$brewfile_path" --force
  
  # Add to chezmoi if not already managed
  if command -v chezmoi &> /dev/null; then
    chezmoi add "$brewfile_path"
    echo "✅ Brewfile updated and added to chezmoi"
  fi
  
  # Show diff if backup exists
  if [[ -f "$backup_path" ]]; then
    echo "📋 Changes made:"
    if command -v bat &> /dev/null; then
      diff -u "$backup_path" "$brewfile_path" | bat --language=diff
    else
      diff -u "$backup_path" "$brewfile_path"
    fi
  fi
}

# Smart package installation
brewinstall() {
  local brewfile_path="$HOME/.config/brewfile/Brewfile"
  
  if [[ ! -f "$brewfile_path" ]]; then
    echo "❌ Brewfile not found at $brewfile_path"
    return 1
  fi
  
  echo "📦 Installing packages from Brewfile..."
  brew bundle --file="$brewfile_path"
  
  if [[ $? -eq 0 ]]; then
    echo "✅ All packages installed successfully"
  else
    echo "⚠️  Some packages failed to install"
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

# Enhanced weather function with location fallback
weather() {
  local location="${1:-Suisun City, CA}"
  
  if command -v curl &> /dev/null; then
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

# Network utilities
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

# Project archiver
projarchive() {
  local project_dir="${1:-$(pwd)}"
  local archive_dir="$HOME/Archive/Projects"
  local timestamp=$(date +%Y%m%d_%H%M%S)
  
  mkdir -p "$archive_dir"
  
  local project_name=$(basename "$project_dir")
  local archive_name="${project_name}_${timestamp}.tar.gz"
  
  echo "📦 Archiving project: $project_name"
  tar -czf "$archive_dir/$archive_name" -C "$(dirname "$project_dir")" "$project_name"
  
  if [[ $? -eq 0 ]]; then
    echo "✅ Project archived to: $archive_dir/$archive_name"
    
    read -q "REPLY?Remove original directory? (y/n): "
    echo
    
    if [[ $REPLY == "y" ]]; then
      rm -rf "$project_dir"
      echo "🗑️  Original directory removed"
    fi
  else
    echo "❌ Archive failed"
  fi
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

# Docker stats with formatting
dstats() {
  docker stats --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"
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
# KUBERNETES UTILITIES
# ============================================================================

# Kubernetes context switcher
kctx() {
  if [[ -z "$1" ]]; then
    echo "Available contexts:"
    kubectl config get-contexts
    return 0
  fi
  
  kubectl config use-context "$1"
}

# Kubernetes namespace switcher
kns() {
  if [[ -z "$1" ]]; then
    echo "Available namespaces:"
    kubectl get namespaces
    return 0
  fi
  
  kubectl config set-context --current --namespace="$1"
}

# Pod logs with follow
klogs() {
  local pod="$1"
  local container="$2"
  
  if [[ -z "$pod" ]]; then
    echo "Usage: klogs <pod> [container]"
    echo "Available pods:"
    kubectl get pods
    return 1
  fi
  
  if [[ -n "$container" ]]; then
    kubectl logs -f "$pod" -c "$container"
  else
    kubectl logs -f "$pod"
  fi
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

# Terraform state utilities
tfstate() {
  local action="$1"
  
  case "$action" in
    "list")
      terraform state list
      ;;
    "show")
      terraform state show "$2"
      ;;
    "pull")
      terraform state pull > terraform.tfstate.backup
      echo "State backed up to terraform.tfstate.backup"
      ;;
    *)
      echo "Usage: tfstate <list|show|pull> [resource]"
      ;;
  esac
}

# ============================================================================
# AWS UTILITIES
# ============================================================================

# AWS profile switcher
awsp() {
  if [[ -z "$1" ]]; then
    echo "Current profile: ${AWS_PROFILE:-default}"
    echo "Available profiles:"
    aws configure list-profiles
    return 0
  fi
  
  export AWS_PROFILE="$1"
  echo "✅ AWS profile set to: $1"
}

# AWS SSO login helper
awslogin() {
  local profile="${1:-$AWS_PROFILE}"
  
  if [[ -z "$profile" ]]; then
    echo "Usage: awslogin [profile]"
    echo "Available profiles:"
    aws configure list-profiles
    return 1
  fi
  
  echo "🔐 Logging in with profile: $profile"
  aws sso login --profile "$profile"
}

# S3 bucket size
s3size() {
  local bucket="$1"
  
  if [[ -z "$bucket" ]]; then
    echo "Usage: s3size <bucket>"
    return 1
  fi
  
  aws s3 ls "s3://$bucket" --recursive --human-readable --summarize
}

# ============================================================================
# PERFORMANCE UTILITIES
# ============================================================================

# System performance overview
sysinfo() {
  echo "💻 System Information:"
  echo "OS: $(uname -s) $(uname -r)"
  echo "Hostname: $(hostname)"
  echo "Uptime: $(uptime | awk '{print $3,$4}' | sed 's/,//')"
  echo "Load: $(uptime | awk -F'load average:' '{print $2}')"
  echo "Memory: $(free -h 2>/dev/null | grep Mem || vm_stat | head -5)"
  echo "Disk: $(df -h / | tail -1)"
  echo "CPU: $(sysctl -n machdep.cpu.brand_string 2>/dev/null || cat /proc/cpuinfo | grep 'model name' | head -1 | cut -d: -f2)"
}

# Process tree
pstree() {
  if command -v pstree &> /dev/null; then
    pstree -a
  else
    ps aux | head -1
    ps aux | sort -k3 -nr | head -20
  fi
}

# Memory usage by process
memtop() {
  echo "🧠 Top Memory Consumers:"
  ps aux | sort -k4 -nr | head -10 | awk '{printf "%-8s %-8s %-8s %s\n", $2, $3"%", $4"%", $11}'
}

# CPU usage by process
cputop() {
  echo "⚡ Top CPU Consumers:"
  ps aux | sort -k3 -nr | head -10 | awk '{printf "%-8s %-8s %-8s %s\n", $2, $3"%", $4"%", $11}'
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

# YAML validation
yaml() {
  if [[ -z "$1" ]]; then
    echo "Usage: yaml <file>"
    return 1
  fi
  
  python3 -c "import yaml; yaml.safe_load(open('$1'))" && echo "✅ Valid YAML"
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

# URL encode/decode
url() {
  local action="$1"
  local input="$2"
  
  case "$action" in
    "encode"|"e")
      if [[ -z "$input" ]]; then
        python3 -c "import sys, urllib.parse; print(urllib.parse.quote(sys.stdin.read().strip()))"
      else
        python3 -c "import urllib.parse; print(urllib.parse.quote('$input'))"
      fi
      ;;
    "decode"|"d")
      if [[ -z "$input" ]]; then
        python3 -c "import sys, urllib.parse; print(urllib.parse.unquote(sys.stdin.read().strip()))"
      else
        python3 -c "import urllib.parse; print(urllib.parse.unquote('$input'))"
      fi
      ;;
    *)
      echo "Usage: url <encode|decode> [string]"
      ;;
  esac
}

# ============================================================================
# SECURITY UTILITIES
# ============================================================================

# Generate secure password
genpass() {
  local length="${1:-16}"
  
  if command -v openssl &> /dev/null; then
    openssl rand -base64 $((length * 3 / 4)) | tr -d "=+/" | cut -c1-${length}
  else
    LC_ALL=C tr -dc 'A-Za-z0-9!"#$%&'\''()*+,-./:;<=>?@[\]^_`{|}~' < /dev/urandom | head -c ${length}
    echo
  fi
}

# Check SSL certificate
sslcheck() {
  local domain="$1"
  local port="${2:-443}"
  
  if [[ -z "$domain" ]]; then
    echo "Usage: sslcheck <domain> [port]"
    return 1
  fi
  
  echo | openssl s_client -servername "$domain" -connect "$domain:$port" 2>/dev/null | openssl x509 -noout -dates
}

# Hash file
hashfile() {
  local file="$1"
  local algorithm="${2:-sha256}"
  
  if [[ -z "$file" ]]; then
    echo "Usage: hashfile <file> [algorithm]"
    echo "Algorithms: md5, sha1, sha256, sha512"
    return 1
  fi
  
  case "$algorithm" in
    "md5")
      md5sum "$file" 2>/dev/null || md5 "$file"
      ;;
    "sha1")
      sha1sum "$file" 2>/dev/null || shasum -a 1 "$file"
      ;;
    "sha256")
      sha256sum "$file" 2>/dev/null || shasum -a 256 "$file"
      ;;
    "sha512")
      sha512sum "$file" 2>/dev/null || shasum -a 512 "$file"
      ;;
    *)
      echo "Unsupported algorithm: $algorithm"
      ;;
  esac
}

# ============================================================================
# SECURITY ENHANCEMENTS
# ============================================================================

# SSH key management
sshkeys() {
  echo "🔑 SSH Keys:"
  ssh-add -l 2>/dev/null || echo "No keys loaded in agent"
  echo
  echo "Available keys:"
  ls -lh ~/.ssh/*.pub 2>/dev/null || echo "No public keys found"
}

# Load SSH keys with keychain (if available)
load_ssh_keys() {
  if command -v keychain &> /dev/null; then
    # Try common key names
    local keys=()
    [[ -f ~/.ssh/id_ed25519 ]] && keys+=(id_ed25519)
    [[ -f ~/.ssh/id_rsa ]] && keys+=(id_rsa)
    
    if [[ ${#keys[@]} -gt 0 ]]; then
      eval $(keychain --eval --quiet ${keys[@]} 2>/dev/null)
      echo "🔑 SSH keys loaded via keychain"
    fi
  fi
}

# Git commit signing check
gitsign() {
  if ! git config --get user.signingkey &> /dev/null; then
    echo "⚠️  No GPG signing key configured"
    echo "Configure with: git config --global user.signingkey <KEY_ID>"
    echo "Enable signing: git config --global commit.gpgsign true"
    return 1
  fi
  
  local key=$(git config --get user.signingkey)
  echo "✅ GPG signing enabled with key: $key"
  
  if command -v gpg &> /dev/null; then
    gpg --list-secret-keys --keyid-format=long "$key" 2>/dev/null || echo "⚠️  Key not found in GPG keyring"
  fi
}

# ============================================================================
# ADVANCED GIT WORKFLOWS
# ============================================================================

# Interactive rebase helper
grib() {
  local base="${1:-main}"
  
  # Check if we're in a git repo
  if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "❌ Not a git repository"
    return 1
  fi
  
  # Check if base branch exists
  if ! git rev-parse --verify "$base" > /dev/null 2>&1; then
    echo "❌ Branch '$base' not found"
    return 1
  fi
  
  local count=$(git rev-list --count HEAD ^$base 2>/dev/null)
  
  if [[ $count -eq 0 ]]; then
    echo "✅ No commits to rebase from $base"
    return 0
  fi
  
  echo "📝 Interactive rebase of last $count commits from $base"
  git rebase -i HEAD~$count
}

# Git bisect helper
gbisect() {
  local action="$1"
  
  case "$action" in
    "start")
      if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "❌ Not a git repository"
        return 1
      fi
      
      git bisect start
      git bisect bad HEAD
      
      read -r "good?Enter known good commit: "
      if [[ -n "$good" ]]; then
        git bisect good "$good"
      fi
      ;;
    "good")
      git bisect good
      ;;
    "bad")
      git bisect bad
      ;;
    "skip")
      git bisect skip
      ;;
    "reset")
      git bisect reset
      ;;
    "log")
      git bisect log
      ;;
    *)
      echo "Usage: gbisect <start|good|bad|skip|reset|log>"
      echo
      echo "Git bisect helper for finding bugs"
      echo "  start - Start bisecting"
      echo "  good  - Mark current commit as good"
      echo "  bad   - Mark current commit as bad"
      echo "  skip  - Skip current commit"
      echo "  reset - End bisecting"
      echo "  log   - Show bisect log"
      ;;
  esac
}

# Semantic versioning helper
gsemver() {
  local type="${1:-patch}"
  
  if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "❌ Not a git repository"
    return 1
  fi
  
  local latest_tag=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
  
  # Parse version
  local version=${latest_tag#v}
  local major=$(echo "$version" | cut -d. -f1)
  local minor=$(echo "$version" | cut -d. -f2)
  local patch=$(echo "$version" | cut -d. -f3)
  
  case "$type" in
    "major")
      major=$((major + 1))
      minor=0
      patch=0
      ;;
    "minor")
      minor=$((minor + 1))
      patch=0
      ;;
    "patch")
      patch=$((patch + 1))
      ;;
    *)
      echo "Usage: gsemver <major|minor|patch>"
      echo "Current version: $latest_tag"
      return 1
      ;;
  esac
  
  local new_tag="v${major}.${minor}.${patch}"
  echo "📦 Current version: $latest_tag"
  echo "📦 New version: $new_tag"
  echo
  
  read -q "REPLY?Create tag $new_tag? (y/n): "
  echo
  
  if [[ $REPLY == "y" ]]; then
    read -r "message?Enter release message (optional): "
    
    if [[ -n "$message" ]]; then
      git tag -a "$new_tag" -m "$message"
    else
      git tag -a "$new_tag" -m "Release $new_tag"
    fi
    
    echo "✅ Tag created: $new_tag"
    echo "Push with: git push origin $new_tag"
  fi
}

# ============================================================================
# FZF INTEGRATION FUNCTIONS
# ============================================================================

# Fuzzy file finder with editor
fe() {
  local file
  file=$(fzf --query="$1" --select-1 --exit-0 \
    --preview 'bat --style=numbers --color=always {} 2>/dev/null || cat {}')
  
  [[ -n "$file" ]] && ${EDITOR:-vim} "$file"
}

# Fuzzy directory finder with cd
fcd() {
  local dir
  dir=$(fd --type d --hidden --follow --exclude .git 2>/dev/null | \
    fzf --query="$1" --select-1 --exit-0 \
    --preview 'eza --tree --level=2 --color=always {} 2>/dev/null || ls -la {}')
  
  [[ -n "$dir" ]] && cd "$dir"
}

# Fuzzy git branch checkout
fco() {
  local branch
  branch=$(git branch --all | grep -v HEAD | \
    sed 's/^..//' | sed 's#remotes/origin/##' | sort -u | \
    fzf --query="$1" --select-1 --exit-0 \
    --preview 'git log --oneline --graph --color=always --date=short --pretty="format:%C(auto)%h %C(blue)%ad %C(green)%an %C(white)%s" {} | head -50')
  
  [[ -n "$branch" ]] && git checkout "$branch"
}

# Fuzzy git log browser
fgl() {
  local commit
  commit=$(git log --graph --color=always \
    --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" | \
    fzf --ansi --no-sort --reverse --tiebreak=index \
    --preview 'echo {} | grep -o "[a-f0-9]\{7\}" | head -1 | xargs git show --color=always' \
    --bind "enter:execute:echo {} | grep -o '[a-f0-9]\{7\}' | head -1 | xargs git show | less -R")
}

# Fuzzy process killer
fkill() {
  local pid
  pid=$(ps aux | sed 1d | fzf -m --header="Select process(es) to kill" | awk '{print $2}')
  
  if [[ -n "$pid" ]]; then
    echo "$pid" | xargs kill -${1:-15}
    echo "✅ Sent signal ${1:-15} to process(es): $pid"
  fi
}

# Fuzzy history search and execute
fh() {
  eval $(history | fzf --tac --no-sort | sed 's/^[ ]*[0-9]*[ ]*//')
}

# Fuzzy environment variable viewer
fenv() {
  env | fzf --preview 'echo {}' --preview-window=right:60%:wrap
}

# ============================================================================
# MONITORING AND DEBUGGING
# ============================================================================

# Zsh startup profiling
zshprof() {
  local iterations="${1:-10}"
  echo "🔍 Profiling zsh startup ($iterations runs)..."
  
  if command -v hyperfine &> /dev/null; then
    hyperfine --warmup 3 --runs "$iterations" 'zsh -i -c exit'
  else
    echo "Using basic timing (install hyperfine for better results)..."
    for i in {1..$iterations}; do
      time zsh -i -c exit
    done
  fi
}

# Show what's slowing down startup
zshslow() {
  echo "🐌 Analyzing zsh startup components..."
  echo
  
  # Profile different components
  echo "Testing basic shell startup..."
  time zsh -i -c exit
  
  echo
  echo "Testing with plugin loading..."
  if [[ -f ~/.zshrc ]]; then
    # Create temp file without plugins
    local temp_rc=$(mktemp)
    grep -v "zinit\|plugin\|source.*zsh" ~/.zshrc > "$temp_rc"
    
    echo "Without plugins:"
    time zsh --rcs "$temp_rc" -i -c exit
    rm -f "$temp_rc"
  fi
  
  echo
  echo "💡 Tips:"
  echo "  - Check ~/.cache/zsh/ for stale completion cache"
  echo "  - Use 'zprof' for detailed profiling (uncomment in .zshrc)"
  echo "  - Review lazy-loaded tools"
}

# Show loaded plugins and modules
zshinfo() {
  echo "📊 Zsh Configuration Info"
  echo
  echo "Shell: $SHELL (version: $(zsh --version))"
  echo "Config: $ZDOTDIR"
  echo
  
  if command -v zinit &> /dev/null; then
    echo "Zinit plugins:"
    zinit list 2>/dev/null | head -20
    echo
  fi
  
  echo "Loaded modules:"
  zmodload | head -20
  echo
  
  echo "Functions defined: $(typeset -f | grep -c "^[a-zA-Z_]")"
  echo "Aliases defined: $(alias | wc -l)"
  echo
  
  echo "History: $HISTSIZE entries (saved: $SAVEHIST)"
  echo "History file: $HISTFILE"
}

# ============================================================================
# CLOUD PROVIDER ENHANCEMENTS
# ============================================================================

# GCP project switcher
gcpp() {
  if ! command -v gcloud &> /dev/null; then
    echo "❌ gcloud CLI not installed"
    return 1
  fi
  
  if [[ -z "$1" ]]; then
    echo "Current project: $(gcloud config get-value project 2>/dev/null)"
    echo
    echo "Available projects:"
    gcloud projects list --format="table(projectId,name,projectNumber)"
    return 0
  fi
  
  gcloud config set project "$1"
  echo "✅ GCP project set to: $1"
}

# GCP authentication helper
gcpauth() {
  if ! command -v gcloud &> /dev/null; then
    echo "❌ gcloud CLI not installed"
    return 1
  fi
  
  echo "🔐 Authenticating with GCP..."
  gcloud auth login
  
  read -q "REPLY?Set up application default credentials? (y/n): "
  echo
  
  if [[ $REPLY == "y" ]]; then
    gcloud auth application-default login
  fi
}

# GCP service list
gcps() {
  if ! command -v gcloud &> /dev/null; then
    echo "❌ gcloud CLI not installed"
    return 1
  fi
  
  echo "📦 GCP Services:"
  echo
  echo "Compute Instances:"
  gcloud compute instances list 2>/dev/null | head -10
  echo
  echo "Cloud Run Services:"
  gcloud run services list 2>/dev/null | head -10
  echo
  echo "GKE Clusters:"
  gcloud container clusters list 2>/dev/null | head -10
}

# Azure subscription switcher
azs() {
  if ! command -v az &> /dev/null; then
    echo "❌ Azure CLI not installed"
    return 1
  fi
  
  if [[ -z "$1" ]]; then
    echo "Current subscription:"
    az account show --output table 2>/dev/null
    echo
    echo "Available subscriptions:"
    az account list --output table
    return 0
  fi
  
  az account set --subscription "$1"
  echo "✅ Azure subscription set to: $1"
}

# Azure login helper
azlogin() {
  if ! command -v az &> /dev/null; then
    echo "❌ Azure CLI not installed"
    return 1
  fi
  
  echo "🔐 Authenticating with Azure..."
  az login
}

# Azure resource list
azls() {
  if ! command -v az &> /dev/null; then
    echo "❌ Azure CLI not installed"
    return 1
  fi
  
  echo "📦 Azure Resources:"
  echo
  echo "Resource Groups:"
  az group list --output table | head -10
  echo
  echo "VMs:"
  az vm list --output table | head -10
  echo
  echo "App Services:"
  az webapp list --output table | head -10
}

# ============================================================================
# TESTING AND CI/CD HELPERS
# ============================================================================

# Run tests with coverage
testcov() {
  local type="${1:-auto}"
  
  # Auto-detect project type
  if [[ "$type" == "auto" ]]; then
    if [[ -f "setup.py" ]] || [[ -f "pyproject.toml" ]]; then
      type="python"
    elif [[ -f "package.json" ]]; then
      type="node"
    elif [[ -f "Cargo.toml" ]]; then
      type="rust"
    elif [[ -f "go.mod" ]]; then
      type="go"
    else
      echo "❌ Could not detect project type"
      echo "Usage: testcov <python|node|rust|go>"
      return 1
    fi
  fi
  
  echo "🧪 Running tests with coverage for $type project..."
  echo
  
  case "$type" in
    "python")
      if command -v pytest &> /dev/null; then
        pytest --cov=. --cov-report=html --cov-report=term-missing
      else
        echo "Install pytest-cov: pip install pytest pytest-cov"
      fi
      ;;
    "node")
      npm run test -- --coverage
      ;;
    "rust")
      if command -v cargo-tarpaulin &> /dev/null; then
        cargo tarpaulin --out Html --output-dir coverage
      else
        echo "Install tarpaulin: cargo install cargo-tarpaulin"
      fi
      ;;
    "go")
      go test -coverprofile=coverage.out ./...
      go tool cover -html=coverage.out -o coverage.html
      echo "✅ Coverage report: coverage.html"
      ;;
    *)
      echo "Unsupported project type: $type"
      return 1
      ;;
  esac
}

# Watch tests (re-run on file changes)
testwatch() {
  if command -v watchexec &> /dev/null; then
    echo "👀 Watching for changes..."
    watchexec --clear --restart -- ${1:-"npm test"}
  elif command -v entr &> /dev/null; then
    echo "👀 Watching for changes..."
    find . -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.rs" | entr -c ${1:-pytest}
  else
    echo "Install watchexec or entr for test watching"
    echo "  brew install watchexec"
    echo "  brew install entr"
  fi
}

# CI/CD pipeline status checker
cistatus() {
  if git remote -v | grep -q github.com; then
    if command -v gh &> /dev/null; then
      echo "📊 GitHub Actions Status:"
      gh run list --limit 5
    else
      echo "Install GitHub CLI: brew install gh"
    fi
  elif git remote -v | grep -q gitlab.com; then
    echo "📊 GitLab CI/CD pipelines:"
    echo "Visit: $(git remote get-url origin | sed 's/\.git$//')/-/pipelines"
  else
    echo "CI status checking not supported for this remote"
  fi
}

# ============================================================================
# HELP SYSTEM
# ============================================================================

# Show all custom functions with descriptions
helpzsh() {
  cat <<'EOF'
🎯 Enhanced Zsh Functions

📁 NAVIGATION & FILES:
  mkcd <dir>           - Create and enter directory
  ff <pattern>         - Find files by pattern
  fe [query]           - Fuzzy find and edit file
  fcd [query]          - Fuzzy find and cd to directory
  fh                   - Fuzzy search command history

🔄 GIT WORKFLOWS:
  gci                  - Interactive conventional commit
  gbclean              - Clean up merged branches
  grib [base]          - Interactive rebase from base branch
  gbisect <action>     - Git bisect helper
  gsemver <type>       - Semantic versioning tag creator
  fco [query]          - Fuzzy checkout branch
  fgl                  - Fuzzy git log browser
  gitsign              - Check GPG signing configuration

🐳 DOCKER:
  dclean               - Clean all docker resources
  dshell <container>   - Quick shell access to container
  dstats               - Formatted container stats

☸️  KUBERNETES:
  kctx [context]       - Switch kubernetes context
  kns [namespace]      - Switch namespace
  klogs <pod>          - Follow pod logs

☁️  CLOUD PROVIDERS:
  awsp [profile]       - AWS profile switcher
  awslogin [profile]   - AWS SSO login
  gcpp [project]       - GCP project switcher
  gcpauth              - GCP authentication
  gcps                 - List GCP services
  azs [subscription]   - Azure subscription switcher
  azlogin              - Azure login
  azls                 - List Azure resources

🔧 DEVELOPMENT:
  projinit <name> [type] - Initialize new project
  testcov [type]       - Run tests with coverage
  testwatch [cmd]      - Watch and re-run tests
  cistatus             - Check CI/CD pipeline status

📦 CHEZMOI:
  czst                 - Status with file types
  czpush [message]     - Interactive commit and push
  czpull               - Safe pull with backup
  czed <file>          - Edit managed file

⚡ SYSTEM UTILITIES:
  weather [location]   - Weather information
  sysinfo              - System diagnostics
  netinfo              - Network information
  healthcheck          - System health check
  portcheck <port>     - Check if port is in use
  fkill                - Fuzzy process killer
  fenv                 - Fuzzy environment variable viewer

🔐 SECURITY:
  genpass [length]     - Generate secure password
  sshkeys              - Show SSH keys
  gitsign              - Check Git GPG signing
  sslcheck <domain>    - Check SSL certificate
  hashfile <file>      - Hash file with multiple algorithms

🔍 DEBUGGING & PROFILING:
  zshprof [runs]       - Profile zsh startup time
  zshslow              - Analyze startup bottlenecks
  zshinfo              - Show configuration info

🍺 HOMEBREW:
  brewup               - Update Brewfile
  brewinstall          - Install from Brewfile
  brewclean            - Cleanup and doctor

📝 TEXT PROCESSING:
  json [file]          - Pretty print JSON
  yaml <file>          - Validate YAML
  b64 <encode|decode>  - Base64 encoding
  url <encode|decode>  - URL encoding

Type 'helpme <function>' to see details about a specific function
EOF
}

# Quick reference for specific command
helpme() {
  local cmd="$1"
  
  if [[ -z "$cmd" ]]; then
    helpzsh
    return
  fi
  
  echo "📖 Help for: $cmd"
  echo
  
  # Show function definition
  if type "$cmd" | grep -q "function"; then
    if command -v bat &> /dev/null; then
      type "$cmd" | bat --language=zsh --style=plain --paging=never
    else
      type "$cmd"
    fi
  else
    echo "❌ '$cmd' is not a function or command not found"
    echo
    echo "Try: helpzsh - to see all available functions"
  fi
}

# ============================================================================
# HEALTH CHECK SYSTEM
# ============================================================================

# Comprehensive environment health check
healthcheck() {
  echo "🏥 Environment Health Check"
  echo "══════════════════════════════════════════════════════════════"
  echo
  
  # System info
  echo "💻 SYSTEM:"
  echo "  OS: $(uname -s) $(uname -r)"
  echo "  Hostname: $(hostname)"
  echo "  Shell: $SHELL ($(zsh --version))"
  echo "  Uptime: $(uptime | awk '{print $3,$4}' | sed 's/,//')"
  echo
  
  # Check critical tools
  echo "📦 CRITICAL TOOLS:"
  local critical_tools=(git curl wget zsh brew)
  for tool in $critical_tools; do
    if command -v "$tool" &> /dev/null; then
      local version=$(${tool} --version 2>&1 | head -1 | awk '{print $NF}')
      echo "  ✅ $tool ($version)"
    else
      echo "  ❌ $tool (missing - CRITICAL)"
    fi
  done
  echo
  
  # Check modern tools
  echo "🚀 MODERN TOOLS:"
  local modern_tools=(eza bat ripgrep fd zoxide fzf dust duf)
  for tool in $modern_tools; do
    if command -v "$tool" &> /dev/null; then
      echo "  ✅ $tool"
    else
      echo "  ⚠️  $tool (recommended but not critical)"
    fi
  done
  echo
  
  # Check cloud tools
  echo "☁️  CLOUD TOOLS:"
  local cloud_tools=(aws gcloud az kubectl terraform)
  for tool in $cloud_tools; do
    if command -v "$tool" &> /dev/null; then
      echo "  ✅ $tool"
    else
      echo "  ⚪ $tool (optional)"
    fi
  done
  echo
  
  # Performance check
  echo "⏱️  PERFORMANCE:"
  if command -v hyperfine &> /dev/null; then
    local startup_time=$(hyperfine --warmup 2 --runs 3 'zsh -i -c exit' 2>&1 | grep "Time" | awk '{print $3, $4}')
    echo "  Startup time: $startup_time"
  else
    echo "  Install hyperfine for startup benchmarks"
  fi
  echo
  
  # Disk space
  echo "💾 DISK SPACE:"
  df -h / | tail -1 | awk '{printf "  Root: %s/%s (%s used)\n", $3, $2, $5}'
  
  if [[ -d "$HOME" ]]; then
    local home_size=$(du -sh "$HOME" 2>/dev/null | awk '{print $1}')
    echo "  Home: $home_size"
  fi
  echo
  
  # Updates check
  echo "🔄 UPDATES:"
  if command -v brew &> /dev/null; then
    local outdated=$(brew outdated 2>/dev/null | wc -l | tr -d ' ')
    if [[ $outdated -gt 0 ]]; then
      echo "  ⚠️  Homebrew: $outdated packages need updating"
      echo "     Run: brew upgrade"
    else
      echo "  ✅ Homebrew: All packages up to date"
    fi
  fi
  
  if command -v zinit &> /dev/null; then
    echo "  💡 Zinit: Run 'zinit update' to update plugins"
  fi
  echo
  
  # Git configuration
  echo "🔧 GIT CONFIGURATION:"
  if git config --get user.name &> /dev/null; then
    echo "  ✅ User: $(git config --get user.name) <$(git config --get user.email)>"
  else
    echo "  ⚠️  Git user not configured"
  fi
  
  if git config --get user.signingkey &> /dev/null; then
    echo "  ✅ GPG signing enabled"
  else
    echo "  ⚪ GPG signing not configured (optional)"
  fi
  echo
  
  # Summary
  echo "══════════════════════════════════════════════════════════════"
  echo "Health check complete! 🎉"
  echo
  echo "💡 Quick fixes:"
  echo "  - Missing tools: brew install eza bat ripgrep fd zoxide fzf"
  echo "  - Slow startup: Run 'zshslow' for analysis"
  echo "  - Updates: Run 'brew upgrade' and 'zinit update'"
}

echo "🎯 Enhanced Zsh functions loaded successfully!"
