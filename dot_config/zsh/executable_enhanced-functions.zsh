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

echo "🎯 Enhanced Zsh functions loaded successfully!"
