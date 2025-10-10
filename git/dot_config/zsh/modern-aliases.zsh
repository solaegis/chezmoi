#!/usr/bin/env zsh
# ============================================================================
# Modern Zsh Aliases - 2025 Developer Workflow Optimization
# ============================================================================

# ============================================================================
# MODERN TOOL REPLACEMENTS
# ============================================================================

# Enhanced file operations (use modern rust-based tools when available)
if command -v eza &> /dev/null; then
  alias ls='eza --color=auto --group-directories-first --icons'
  alias ll='eza -la --group-directories-first --header --icons --git'
  alias la='eza -la --group-directories-first --icons'
  alias lt='eza --tree --level=2 --icons'
  alias lta='eza --tree --level=3 --icons --all'
  alias ltd='eza --tree --level=2 --icons --only-dirs'
else
  alias ls='ls -G --color=auto'
  alias ll='ls -alF'
  alias la='ls -A'
  alias lt='tree -L 2'
fi

# Better cat with syntax highlighting
if command -v bat &> /dev/null; then
  alias cat='bat --paging=never'
  alias batl='bat --paging=always'
  alias catn='cat'  # fallback to original cat
else
  alias bat='less'
fi

# Better grep with ripgrep
if command -v rg &> /dev/null; then
  alias grep='rg --color=auto'
  alias grepi='rg -i'
  alias grepr='rg -r'
  alias fgrep='rg -F'
  alias egrep='rg -E'
else
  alias grep='grep --color=auto'
  alias grepi='grep -i'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

# Better find with fd
if command -v fd &> /dev/null; then
  alias find='fd'
  alias findi='fd -i'
  alias findt='fd -t f'  # files only
  alias findd='fd -t d'  # directories only
fi

# Better du with dust
if command -v dust &> /dev/null; then
  alias du='dust'
  alias duh='dust -H'
  alias dus='dust -s'
else
  alias duh='du -h'
  alias dus='du -sh'
fi

# Better df with duf
if command -v duf &> /dev/null; then
  alias df='duf'
  alias dfall='duf --all'
else
  alias df='df -h'
fi

# Better top with btop/htop
if command -v btop &> /dev/null; then
  alias top='btop'
elif command -v htop &> /dev/null; then
  alias top='htop'
fi

# Better ps with procs
if command -v procs &> /dev/null; then
  alias ps='procs'
  alias psa='procs --pager'
  alias pscpu='procs --sortd cpu'
  alias psmem='procs --sortd memory'
fi

# Better dig with dog
if command -v dog &> /dev/null; then
  alias dig='dog'
fi

# Better ping with gping
if command -v gping &> /dev/null; then
  alias ping='gping'
  alias pingg='gping'
fi

# ============================================================================
# EDITOR ALIASES
# ============================================================================

# Modern editors
if command -v cursor &> /dev/null; then
  alias code='cursor'
  alias edit='cursor'
  alias c='cursor'
fi

if command -v nvim &> /dev/null; then
  alias vim='nvim'
  alias vi='nvim'
  alias v='nvim'
elif command -v vim &> /dev/null; then
  alias vi='vim'
  alias v='vim'
fi

# Quick file editing
alias zshrc='$EDITOR ~/.zshrc'
alias vimrc='$EDITOR ~/.vimrc'
alias gitconfig='$EDITOR ~/.gitconfig'
alias hosts='sudo $EDITOR /etc/hosts'

# ============================================================================
# NAVIGATION ALIASES
# ============================================================================

# Directory navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ~='cd ~'
alias -- -='cd -'

# Common directories
alias home='cd ~'
alias root='cd /'
alias desk='cd ~/Desktop'
alias docs='cd ~/Documents'
alias down='cd ~/Downloads'
alias proj='cd ~/Projects'
alias work='cd ~/git-work'
alias personal='cd ~/git'

# Directory shortcuts with better tools
if command -v zoxide &> /dev/null; then
  alias cd='z'
  alias cdi='zi'  # interactive
  alias j='z'     # autojump style
fi

# ============================================================================
# GIT ALIASES (ENHANCED)
# ============================================================================

# Basic git operations
alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gap='git add --patch'
alias gau='git add --update'

# Commit operations
alias gc='git commit --verbose'
alias gca='git commit --verbose --all'
alias gcam='git commit --all --message'
alias gcm='git commit --message'
alias gcs='git commit --signoff'
alias gcf='git commit --fixup'

# Branch operations
alias gb='git branch'
alias gba='git branch --all'
alias gbd='git branch --delete'
alias gbD='git branch --delete --force'
alias gco='git checkout'
alias gcob='git checkout -b'
alias gcom='git checkout main'
alias gcod='git checkout develop'

# Status and diff
alias gst='git status --short --branch'
alias gss='git status --short'
alias gd='git diff'
alias gdc='git diff --cached'
alias gdw='git diff --word-diff'
alias gdt='git diff-tree --no-commit-id --name-only -r'

# Log and history
alias gl='git log --oneline --graph --decorate'
alias gla='git log --oneline --graph --decorate --all'
alias glg='git log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset"'
alias glo='git log --oneline --decorate'
alias glog='git log --graph --oneline --decorate --all'

# Remote operations
alias gf='git fetch'
alias gfa='git fetch --all'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gph='git push origin HEAD'
alias gpu='git push --set-upstream origin $(git branch --show-current 2>/dev/null)'
alias gpull='git pull'
alias gup='git pull --rebase'

# Merge and rebase
alias gm='git merge'
alias gma='git merge --abort'
alias gmc='git merge --continue'
alias gr='git rebase'
alias gra='git rebase --abort'
alias grc='git rebase --continue'
alias gri='git rebase --interactive'

# Stash operations
alias gsta='git stash'
alias gstaa='git stash apply'
alias gstd='git stash drop'
alias gstl='git stash list'
alias gstp='git stash pop'
alias gsts='git stash show --text'

# Advanced git operations
alias gclean='git clean -fd'
alias gunwip='git log -n 1 | grep -q -c "\-\-wip\-\-" && git reset HEAD~1'
alias gwip='git add -A; git rm $(git ls-files --deleted) 2> /dev/null; git commit --no-verify -m "--wip-- [skip ci]"'
alias gignore='git update-index --assume-unchanged'
alias gunignore='git update-index --no-assume-unchanged'

# ============================================================================
# DOCKER ALIASES
# ============================================================================

alias d='docker'
alias dc='docker-compose'
alias dcu='docker-compose up'
alias dcd='docker-compose down'
alias dcr='docker-compose restart'
alias dcl='docker-compose logs'
alias dcp='docker-compose ps'
alias dcb='docker-compose build'

# Docker system
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias dv='docker volume ls'
alias dn='docker network ls'

# Docker cleanup
alias dprune='docker system prune -af'
alias dclean='docker container prune -f && docker image prune -f && docker volume prune -f'

# Quick docker operations
alias drun='docker run --rm -it'
alias dexec='docker exec -it'
alias dlogs='docker logs -f'
alias dstop='docker stop $(docker ps -q)'
alias drm='docker rm $(docker ps -aq)'
alias drmi='docker rmi $(docker images -q)'

# ============================================================================
# KUBERNETES ALIASES
# ============================================================================

alias k='kubectl'
alias kg='kubectl get'
alias kd='kubectl describe'
alias kc='kubectl create'
alias ka='kubectl apply'
alias kdel='kubectl delete'

# Pods
alias kgp='kubectl get pods'
alias kgpw='kubectl get pods -o wide'
alias kdp='kubectl describe pod'
alias kdelp='kubectl delete pod'
alias kgpa='kubectl get pods --all-namespaces'

# Services
alias kgs='kubectl get services'
alias kds='kubectl describe service'
alias kdels='kubectl delete service'

# Deployments
alias kgd='kubectl get deployments'
alias kdd='kubectl describe deployment'
alias kdeld='kubectl delete deployment'

# Namespaces
alias kgns='kubectl get namespaces'
alias kcns='kubectl config set-context --current --namespace'

# Logs and debugging
alias kl='kubectl logs'
alias klf='kubectl logs -f'
alias kex='kubectl exec -it'
alias kpf='kubectl port-forward'

# Context switching
alias kctx='kubectl config current-context'
alias kctxs='kubectl config get-contexts'
alias kuse='kubectl config use-context'

# ============================================================================
# TERRAFORM ALIASES
# ============================================================================

alias tf='terraform'
alias tfi='terraform init'
alias tfp='terraform plan'
alias tfa='terraform apply'
alias tfd='terraform destroy'
alias tfs='terraform show'
alias tfv='terraform validate'
alias tff='terraform fmt'
alias tfg='terraform graph'
alias tfo='terraform output'
alias tfr='terraform refresh'

# Terraform workspace
alias tfw='terraform workspace'
alias tfws='terraform workspace show'
alias tfwl='terraform workspace list'
alias tfwn='terraform workspace new'
alias tfwsel='terraform workspace select'

# ============================================================================
# AWS ALIASES
# ============================================================================

alias aws-profiles='aws configure list-profiles'
alias aws-whoami='aws sts get-caller-identity'
alias aws-regions='aws ec2 describe-regions --output table'
alias aws-instances='aws ec2 describe-instances --output table'
alias aws-buckets='aws s3 ls'

# AWS SSO
alias aws-login='aws sso login'
alias aws-logout='aws sso logout'

# ============================================================================
# NETWORK ALIASES
# ============================================================================

# Network information
alias myip='curl -s ifconfig.me'
alias localip='ipconfig getifaddr en0'
alias ips='ifconfig -a | grep -o "inet6\? \(addr:\)\?\s\?\(\(\([0-9]\+\.\)\{3\}[0-9]\+\)\|[a-fA-F0-9:]\+\)" | awk "{ sub(/inet6? (addr:)? ?/, \"\"); print }"'

# Network testing
alias pingg='ping google.com'
alias ping8='ping 8.8.8.8'
alias speedtest='curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3 -'

# Port scanning
alias ports='netstat -tulanp'
alias listening='lsof -i -P | grep LISTEN'

# ============================================================================
# SYSTEM ALIASES
# ============================================================================

# Process management
alias psg='ps aux | grep'
alias topcpu='ps aux | sort -nr -k 3 | head -10'
alias topmem='ps aux | sort -nr -k 4 | head -10'

# System information
alias meminfo='free -h'
alias cpuinfo='lscpu'
alias diskinfo='fdisk -l'
alias osinfo='uname -a'

# macOS specific
if [[ "$OSTYPE" == "darwin"* ]]; then
  alias flushdns='sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder'
  alias showfiles='defaults write com.apple.finder AppleShowAllFiles YES && killall Finder'
  alias hidefiles='defaults write com.apple.finder AppleShowAllFiles NO && killall Finder'
  alias emptytrash='sudo rm -rfv /Volumes/*/.Trashes; sudo rm -rfv ~/.Trash; sudo rm -rfv /private/var/log/asl/*.asl'
  alias battery='pmset -g batt'
  alias sleep='pmset sleepnow'
  alias restart='sudo shutdown -r now'
  alias shutdown='sudo shutdown -h now'
fi

# ============================================================================
# DEVELOPMENT ALIASES
# ============================================================================

# Python
alias py='python3'
alias pip='pip3'
alias pipi='pip3 install'
alias pipiu='pip3 install --upgrade'
alias pipr='pip3 install -r requirements.txt'
alias venv='python3 -m venv'
alias activate='source venv/bin/activate'

# Node.js
alias n='node'
alias ni='npm install'
alias nid='npm install --save-dev'
alias nig='npm install --global'
alias nr='npm run'
alias ns='npm start'
alias nt='npm test'
alias nb='npm run build'
alias nw='npm run watch'
alias nc='npm run clean'
alias nu='npm update'
alias nci='npm ci'

# Yarn
alias y='yarn'
alias ya='yarn add'
alias yad='yarn add --dev'
alias yag='yarn global add'
alias yr='yarn run'
alias ys='yarn start'
alias yt='yarn test'
alias yb='yarn build'
alias yw='yarn watch'
alias yu='yarn upgrade'

# Rust
alias c='cargo'
alias cb='cargo build'
alias cr='cargo run'
alias ct='cargo test'
alias cc='cargo check'
alias cf='cargo fmt'
alias cl='cargo clippy'
alias cn='cargo new'
alias ci='cargo init'
alias cu='cargo update'

# Go
alias gob='go build'
alias gor='go run'
alias got='go test'
alias gom='go mod'
alias gomi='go mod init'
alias gomt='go mod tidy'
alias gof='go fmt'
alias gov='go vet'

# ============================================================================
# UTILITY ALIASES
# ============================================================================

# File operations
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias mkdir='mkdir -pv'
alias rmdir='rmdir -v'

# Archive operations
alias tarc='tar -czf'
alias tarx='tar -xzf'
alias tarl='tar -tzf'

# Date and time
alias now='date +"%T"'
alias nowdate='date +"%d-%m-%Y"'
alias nowtime='date +"%T"'
alias nowfull='date +"%d-%m-%Y %T"'

# Quick edits
alias reload='source ~/.zshrc'
alias rlzsh='source ~/.zshrc'
alias editrc='$EDITOR ~/.zshrc'
alias editalias='$EDITOR ~/.config/zsh/modern-aliases.zsh'

# System monitoring
alias watch='watch -n 1'
alias free='free -h'
alias disk='df -h'
alias mount='mount | column -t'

# Security
alias sha='shasum -a 256'
alias sha1='shasum -a 1'
alias sha256='shasum -a 256'
alias sha512='shasum -a 512'
alias md5='md5sum'

# ============================================================================
# CHEZMOI ALIASES
# ============================================================================

alias cz='chezmoi'
alias czs='chezmoi status'
alias czd='chezmoi diff'
alias cza='chezmoi apply'
alias cze='chezmoi edit'
alias czc='chezmoi edit-config'
alias czcat='chezmoi cat'
alias czls='chezmoi managed'
alias czcd='chezmoi cd'

# Chezmoi with git
alias czgit='chezmoi cd && git'
alias czlog='chezmoi cd && git log --oneline -10 && cd -'
alias czremote='chezmoi cd && git remote -v && cd -'

# Quick dotfiles management
alias dotfiles='chezmoi cd'
alias dotpush='czpush'
alias dotpull='czpull'
alias dotstatus='chezmoi status'
alias dotdiff='chezmoi diff'

# ============================================================================
# HOMEBREW ALIASES
# ============================================================================

alias br='brew'
alias bri='brew install'
alias bru='brew uninstall'
alias brup='brew update && brew upgrade'
alias brs='brew search'
alias brinfo='brew info'
alias brlist='brew list'
alias brclean='brew cleanup'
alias brdoc='brew doctor'
alias brout='brew outdated'

# Homebrew cask
alias brc='brew install --cask'
alias brcu='brew uninstall --cask'
alias brcs='brew search --cask'
alias brcinfo='brew info --cask'
alias brclist='brew list --cask'
alias brcout='brew outdated --cask'

# ============================================================================
# FZF INTEGRATION ALIASES
# ============================================================================

# FZF shortcuts
alias fzfp='fzf --preview "bat --style=numbers --color=always {}"'
alias fzfd='fzf --preview "eza --tree --level=2 --color=always {}"'

# Quick fuzzy operations
alias vf='fe'                    # Edit file with fuzzy finder
alias cdf='fcd'                  # CD with fuzzy finder
alias kf='fkill'                 # Kill process with fuzzy finder
alias hf='fh'                    # Search history with fuzzy finder

# ============================================================================
# PRODUCTIVITY ALIASES
# ============================================================================

# Quick commands
alias h='history'
alias j='jobs -l'
alias path='echo -e ${PATH//:/\\n}'
alias now='date +"%T"'
alias nowdate='date +"%d-%m-%Y"'

# Directory size
alias dirsize='du -sh'
alias largest='du -h . | sort -hr | head -20'

# Process utilities
alias pscpu10='ps aux | sort -k3 -nr | head -10'
alias psmem10='ps aux | sort -k4 -nr | head -10'

# Network utilities
alias header='curl -I'
alias httpserv='python3 -m http.server'
alias myip='curl -s ifconfig.me && echo'

# Text processing
alias count='sort | uniq -c | sort -nr'
alias lower="tr '[:upper:]' '[:lower:]'"
alias upper="tr '[:lower:]' '[:upper:]"

echo "🚀 Modern Zsh aliases loaded successfully!"
