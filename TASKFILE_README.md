# Taskfile Development Workflow

This repository uses [Task](https://taskfile.dev/) to manage development workflows and common operations.

## Installation

### Install Task Runner

```bash
# Install Task (if not already installed)
bash install-task.sh

# Or install manually (prefers Homebrew)
# macOS/Linux with Homebrew
brew install go-task/tap/go-task

# Linux without Homebrew
sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b ~/.local/bin
```

## Homebrew Preference

This Taskfile is designed to prefer **Homebrew** for all tool installations when available. This provides:

- **Consistent tool management** across macOS and Linux
- **Automatic dependency resolution**
- **Easy updates** with `brew upgrade`
- **Better integration** with system package management

### Tool Installation Priority

1. **Homebrew** (preferred) - `brew install <tool>`
2. **System package manager** - `apt`, `yum`, etc.
3. **Direct download** - fallback method

## Quick Start

```bash
# Show all available tasks
task --list

# Run a specific task (colon-style naming)
task <primary:secondary>

# Run task with arguments
task <primary:secondary> -- <arguments>

# Examples
task tools:check
task chezmoi:status
task git:commit -- "Add new feature"
```

## Development Workflow

### 1. Initial Setup
```bash
# Complete development setup
task setup:init

# Or step by step
task tools:check
task tools:install
task chezmoi:init
task setup:verify
```

### 2. Daily Development
```bash
# Check current status
task chezmoi:status

# See what would change
task chezmoi:diff

# Test changes without applying
task test:dry-run

# Apply changes
task chezmoi:apply
```

### 3. Testing
```bash
# Test minimal installation
task test:minimal

# Test comprehensive installation
task test:comprehensive

# Test template rendering
task test:templates

# Validate repository
task validate:repo
```

### 4. Git Operations
```bash
# Check git status
task git:status

# Add changes
task git:add -- <files>

# Commit changes
task git:commit -- "commit message"

# Push changes
task git:push
```

## Available Tasks

### Development Setup
- `setup:init` - Complete development setup
- `setup:verify` - Verify development setup

### Tool Management
- `tools:check` - Check if required tools are installed
- `tools:install` - Install development tools
- `tools:install-homebrew` - Install Homebrew package manager

### Chezmoi Operations
- `chezmoi:status` - Show chezmoi status
- `chezmoi:diff` - Show what would change
- `chezmoi:apply` - Apply dotfiles
- `chezmoi:update` - Update and apply dotfiles
- `chezmoi:managed` - List managed files
- `chezmoi:data` - Show configuration data
- `chezmoi:doctor` - Run chezmoi doctor
- `chezmoi:init` - Initialize chezmoi for development

### Chezmoi File Management
- `chezmoi:add` - Add a file to chezmoi management
- `chezmoi:edit` - Edit a managed file
- `chezmoi:remove` - Remove a file from chezmoi management

### Testing
- `test:minimal` - Test minimal installation script
- `test:comprehensive` - Test comprehensive installation script
- `test:dry-run` - Test dotfiles without applying
- `test:templates` - Test template rendering

### Git Management
- `git:status` - Show git status
- `git:diff` - Show git diff
- `git:add` - Add changes to git
- `git:commit` - Commit changes
- `git:push` - Push changes to remote
- `git:pull` - Pull changes from remote
- `git:log` - Show git log

### Workflow Tasks
- `workflow:dev` - Complete development workflow
- `workflow:commit` - Commit and push workflow
- `workflow:update` - Update and test workflow

### Installation Tasks
- `install:minimal` - Run minimal installation
- `install:comprehensive` - Run comprehensive installation

### Documentation
- `docs:serve` - Serve documentation locally
- `docs:build` - Build documentation

### Maintenance
- `maintenance:clean` - Clean up temporary files
- `maintenance:backup` - Create backup of current state
- `maintenance:reset` - Reset to clean state

### Validation
- `validate:repo` - Validate repository structure and files
- `validate:lint` - Lint shell scripts

### Help
- `help:list` - Show available tasks

## Common Workflows

### 1. Making Changes to Dotfiles
```bash
# 1. Check current status
task chezmoi:status

# 2. Edit a file
task chezmoi:edit -- ~/.zshrc

# 3. See what changed
task chezmoi:diff

# 4. Test the changes
task test:dry-run

# 5. Apply changes
task chezmoi:apply

# 6. Commit changes
task git:add -- .
task git:commit -- "Update zsh configuration"
task git:push
```

### 2. Testing Installation Scripts
```bash
# 1. Test minimal installation
task test:minimal

# 2. Test comprehensive installation
task test:comprehensive

# 3. Validate everything
task validate:repo
```

### 3. Updating from Remote
```bash
# 1. Pull latest changes
task git:pull

# 2. Update chezmoi
task chezmoi:update

# 3. Test changes
task test:dry-run

# 4. Apply if good
task chezmoi:apply
```

### 4. Development Session
```bash
# 1. Start development session
task workflow:dev

# 2. Make changes
task chezmoi:edit -- <file>

# 3. Test changes
task test:templates
task chezmoi:diff

# 4. Apply and commit
task chezmoi:apply
task workflow:commit
```

## Configuration

The Taskfile uses these variables:
- `CHEZMOI_SOURCE`: Path to chezmoi source directory
- `CHEZMOI_CONFIG`: Path to chezmoi config directory
- `GITHUB_USER`: GitHub username
- `GITHUB_REPO`: Repository name

## Tips

1. **Use `task --list`** to see all available tasks
2. **Use `task <task-name> --dry-run`** to see what a task would do
3. **Use `task <task-name> --verbose`** for detailed output
4. **Use `task <task-name> -- <args>`** to pass arguments to tasks
5. **Use `task --silent`** to suppress output
6. **Use `task --parallel`** to run tasks in parallel

## Troubleshooting

### Task Not Found
```bash
# Make sure Task is installed
bash install-task.sh

# Or check PATH
echo $PATH
```

### Permission Issues
```bash
# Make sure scripts are executable
chmod +x *.sh
```

### Chezmoi Issues
```bash
# Run chezmoi doctor
task doctor

# Check chezmoi status
task status
```

## Contributing

When adding new tasks to the Taskfile:

1. Follow the existing naming conventions
2. Add a description using `desc:`
3. Group related tasks together
4. Use clear, descriptive names
5. Add the task to this README
6. Test the task before committing

## Examples

### Custom Task Example
```yaml
my-custom-task:
  desc: "My custom task description"
  cmds:
    - echo "Running custom task..."
    - # Add your commands here
```

### Task with Dependencies
```yaml
build-and-test:
  desc: "Build and test the project"
  deps: [clean, validate]
  cmds:
    - echo "Building..."
    - echo "Testing..."
```

### Task with Variables
```yaml
deploy:
  desc: "Deploy to environment"
  vars:
    ENV: "production"
  cmds:
    - echo "Deploying to {{.ENV}}..."
```
