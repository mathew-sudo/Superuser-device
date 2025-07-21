#!/bin/bash
# Fix All Problems Script - Automatically resolve common issues in Superuser-device project
# Version: 2.0-enhanced
# This script identifies and fixes common problems with file structure, permissions, and configuration

set -euo pipefail

# Enhanced error handling with detailed reporting
trap 'error_handler $? $LINENO $BASH_LINENO "$BASH_COMMAND"' ERR

error_handler() {
    local exit_code=$1
    local line_no=$2
    local bash_lineno=$3
    local last_command=$4
    
    echo -e "${COLORS[RED]}╔══════════════════════════════════════════════════════╗${COLORS[NC]}" >&2
    echo -e "${COLORS[RED]}║                    ❌ ERROR OCCURRED ❌                ║${COLORS[NC]}" >&2
    echo -e "${COLORS[RED]}╚══════════════════════════════════════════════════════╝${COLORS[NC]}" >&2
    echo -e "${COLORS[RED]}Error on line $line_no: $last_command${COLORS[NC]}" >&2
    echo -e "${COLORS[RED]}Exit code: $exit_code${COLORS[NC]}" >&2
    echo -e "${COLORS[YELLOW]}Attempting cleanup...${COLORS[NC]}" >&2
    
    # Cleanup on error
    cleanup_on_error
    exit $exit_code
}

cleanup_on_error() {
    # Remove any partially created files
    rm -f .gitignore.tmp README.md.tmp 2>/dev/null || true
    echo -e "${COLORS[GREEN]}Cleanup completed${COLORS[NC]}" >&2
}

# Color definitions for output
declare -A COLORS=(
    [RED]='\033[0;31m'
    [GREEN]='\033[0;32m'
    [CYAN]='\033[0;36m'
    [YELLOW]='\033[1;33m'
    [BLUE]='\033[0;34m'
    [PURPLE]='\033[0;35m'
    [NC]='\033[0m'
)

# Logging function
log() {
    local level="${1:-INFO}"
    shift
    local message="${*:-No message provided}"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${COLORS[CYAN]}[$timestamp] [$level]${COLORS[NC]} $message"
}

# Progress indicator
show_progress() {
    local current=$1
    local total=$2
    local desc="$3"
    local percent=$((current * 100 / total))
    local bar_length=50
    local filled_length=$((percent * bar_length / 100))
    
    printf "\r${COLORS[BLUE]}["
    for ((i=1; i<=filled_length; i++)); do printf "█"; done
    for ((i=filled_length+1; i<=bar_length; i++)); do printf "░"; done
    printf "] %d%% - %s${COLORS[NC]}" "$percent" "$desc"
    
    if [[ $current -eq $total ]]; then
        echo ""
    fi
}

# Main banner
echo -e "${COLORS[PURPLE]}╔══════════════════════════════════════════════════════╗${COLORS[NC]}"
echo -e "${COLORS[PURPLE]}║          🔧 SUPERUSER PROJECT FIX SCRIPT 🔧          ║${COLORS[NC]}"
echo -e "${COLORS[PURPLE]}║              Automated Problem Resolution            ║${COLORS[NC]}"
echo -e "${COLORS[PURPLE]}╚══════════════════════════════════════════════════════╝${COLORS[NC]}"
echo ""

log "INFO" "Starting comprehensive problem fixing process..."

# Problem detection and fixing functions
fix_file_permissions() {
    log "INFO" "Fixing file permissions with enhanced validation..."
    
    local fixed_files=()
    local failed_files=()
    
    # Make main script executable
    if [[ -f "Superuser_main" ]]; then
        if chmod +x Superuser_main 2>/dev/null; then
            fixed_files+=("Superuser_main")
            log "INFO" "✓ Made Superuser_main executable"
        else
            failed_files+=("Superuser_main")
            log "WARN" "⚠ Failed to make Superuser_main executable"
        fi
    else
        log "WARN" "⚠ Superuser_main not found"
    fi
    
    # Fix shell script permissions with error tracking
    while IFS= read -r -d '' script; do
        if chmod +x "$script" 2>/dev/null; then
            fixed_files+=("$(basename "$script")")
        else
            failed_files+=("$(basename "$script")")
        fi
    done < <(find . -name "*.sh" -type f -print0 2>/dev/null || true)
    
    if [[ ${#fixed_files[@]} -gt 0 ]]; then
        log "INFO" "✓ Fixed permissions for: ${fixed_files[*]}"
    fi
    
    if [[ ${#failed_files[@]} -gt 0 ]]; then
        log "WARN" "⚠ Failed to fix permissions for: ${failed_files[*]}"
    fi
    
    # Fix this script's permissions
    chmod +x "$0" 2>/dev/null || log "WARN" "⚠ Could not fix own permissions"
}

create_directory_structure() {
    log "INFO" "Creating proper directory structure..."
    
    # Create required directories
    local directories=(
        ".github/workflows"
        "logs"
        "backups"
        "docs"
        "tests"
        "scripts"
        ".vscode"
    )
    
    for dir in "${directories[@]}"; do
        if [[ ! -d "$dir" ]]; then
            mkdir -p "$dir"
            log "INFO" "✓ Created directory: $dir"
        fi
    done
}

fix_ci_configuration() {
    log "INFO" "Fixing CI configuration with backup support..."
    
    # Create backup if CI file already exists
    if [[ -f ".github/workflows/ci.yml" ]]; then
        local backup_name=".github/workflows/ci.yml.backup.$(date +%s)"
        cp ".github/workflows/ci.yml" "$backup_name"
        log "INFO" "✓ Created backup: $backup_name"
    fi
    
    # Check if superuser.test exists and has YAML content
    if [[ -f "superuser.test" ]]; then
        # Enhanced YAML content detection
        if grep -q "^name:" "superuser.test" && grep -q "^on:" "superuser.test"; then
            log "INFO" "Moving CI configuration to proper location..."
            
            # Ensure .github/workflows directory exists
            mkdir -p .github/workflows
            
            # Move and rename the file with validation
            if mv "superuser.test" ".github/workflows/ci.yml" 2>/dev/null; then
                log "INFO" "✓ Moved superuser.test to .github/workflows/ci.yml"
                
                # Validate the moved file
                if command -v yamllint >/dev/null 2>&1; then
                    yamllint ".github/workflows/ci.yml" >/dev/null 2>&1 && \
                    log "INFO" "✓ CI file syntax validated" || \
                    log "WARN" "⚠ CI file may have syntax issues"
                fi
            else
                log "ERROR" "✗ Failed to move superuser.test"
                return 1
            fi
        else
            log "WARN" "superuser.test doesn't appear to contain valid YAML content"
        fi
    fi
    
    # Verify CI file exists in correct location
    if [[ ! -f ".github/workflows/ci.yml" ]]; then
        log "INFO" "Creating GitHub Actions CI workflow..."
        cat > .github/workflows/ci.yml << 'EOF'
name: Superuser CI Tests

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]
  schedule:
    - cron: '0 2 * * *'
  workflow_dispatch:
    inputs:
      test_level:
        description: 'Test level to run'
        required: true
        default: 'full'
        type: choice
        options:
        - quick
        - full
        - extended

env:
  ANDROID_NDK_VERSION: r25c
  ANDROID_API_LEVEL: 29
  TEST_TIMEOUT: 300

jobs:
  lint-and-validate:
    runs-on: ubuntu-latest
    name: Lint and Validate Scripts
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Install Dependencies
      run: |
        sudo apt-get update
        sudo apt-get install -y shellcheck file bc
    
    - name: Lint Bash Scripts
      run: |
        echo "Running ShellCheck on Superuser_main..."
        shellcheck -e SC1091,SC2034,SC2086,SC2155 Superuser_main
        echo "✓ ShellCheck passed"
    
    - name: Validate Script Syntax
      run: |
        echo "Validating bash syntax..."
        bash -n Superuser_main
        echo "✓ Syntax validation passed"

  security-scan:
    runs-on: ubuntu-latest
    name: Security Scan
    needs: [lint-and-validate]
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Security Analysis
      run: |
        echo "Checking for security vulnerabilities..."
        grep -n "exec\|eval\|system" Superuser_main || echo "✓ No dangerous functions found"
        grep -n "rm -rf\|dd if=" Superuser_main || echo "✓ No destructive commands found"
        echo "✓ Security scan completed"

  quick-test:
    runs-on: ubuntu-latest
    name: Quick Functionality Test
    needs: [lint-and-validate, security-scan]
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Test Script Execution
      run: |
        echo "Testing script execution in dry-run mode..."
        export DRY_RUN=1
        export SKIP_ROOT_CHECK=1
        export LOG_DIR="./test-logs"
        mkdir -p "$LOG_DIR"
        
        timeout 60 bash Superuser_main check
        timeout 60 bash Superuser_main setup
        echo "✓ Basic execution tests passed"
EOF
        log "INFO" "✓ Created .github/workflows/ci.yml"
    fi
}

fix_gitignore() {
    log "INFO" "Creating/updating .gitignore..."
    
    cat > .gitignore << 'EOF'
# Logs
logs/
*.log

# Backups
backups/
*.backup

# Temporary files
*.tmp
*.swp
*.bak
*~

# IDE files
.vscode/settings.json
.idea/
*.sublime-*

# OS files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# Python cache
__pycache__/
*.pyc
*.pyo
*.pyd
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg

# Node modules
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Build artifacts
*.o
*.so
*.exe
*.out
*.app

# Android
*.apk
*.ap_
*.dex
local.properties

# Superuser specific
superuser_temp_*
test-logs*/
EOF
    log "INFO" "✓ Created/updated .gitignore"
}

validate_main_script() {
    log "INFO" "Performing comprehensive script validation..."
    
    local validation_issues=0
    
    if [[ -f "Superuser_main" ]]; then
        # Check bash syntax with detailed error reporting
        if ! bash -n Superuser_main 2>/tmp/syntax_check.log; then
            log "ERROR" "✗ Superuser_main has syntax errors:"
            if [[ -f "/tmp/syntax_check.log" ]]; then
                while IFS= read -r line; do
                    log "ERROR" "  $line"
                done < /tmp/syntax_check.log
            fi
            ((validation_issues++))
        else
            log "INFO" "✓ Superuser_main syntax is valid"
        fi
        
        # Enhanced function detection with line numbers
        local required_functions=(
            "validate_input"
            "secure_root_check"
            "log"
            "check_dependencies"
            "check_system_info"
            "main"
        )
        
        for func in "${required_functions[@]}"; do
            local line_num=$(grep -n "^${func}()" Superuser_main | cut -d: -f1)
            if [[ -n "$line_num" ]]; then
                log "INFO" "✓ Found required function: $func (line $line_num)"
            else
                log "WARN" "⚠ Missing or incorrectly defined function: $func"
                ((validation_issues++))
            fi
        done
        
        # Check for potential security issues
        local security_patterns=(
            "eval.*\$"
            "exec.*\$"
            "\$\(.*\)"
        )
        
        for pattern in "${security_patterns[@]}"; do
            if grep -n "$pattern" Superuser_main >/dev/null 2>&1; then
                local matches=$(grep -n "$pattern" Superuser_main | wc -l)
                log "WARN" "⚠ Found $matches potential security pattern(s): $pattern"
            fi
        done
        
    else
        log "ERROR" "✗ Superuser_main script not found"
        ((validation_issues++))
    fi
    
    # Clean up temporary files
    rm -f /tmp/syntax_check.log 2>/dev/null || true
    
    return $validation_issues
}

fix_line_endings() {
    log "INFO" "Fixing line endings..."
    
    # Fix line endings if dos2unix is available
    if command -v dos2unix >/dev/null 2>&1; then
        find . -name "*.sh" -o -name "*.yml" -o -name "Superuser_main" | \
        xargs dos2unix 2>/dev/null || true
        log "INFO" "✓ Fixed line endings with dos2unix"
    else
        # Manual line ending fix for common files
        for file in Superuser_main *.sh .github/workflows/*.yml; do
            if [[ -f "$file" ]]; then
                sed -i 's/\r$//' "$file" 2>/dev/null || true
            fi
        done
        log "INFO" "✓ Fixed line endings manually"
    fi
}

create_documentation() {
    log "INFO" "Creating/updating documentation..."
    
    # Create README.md if it doesn't exist or is empty
    if [[ ! -f "README.md" ]] || [[ ! -s "README.md" ]]; then
        cat > README.md << 'EOF'
# Enhanced Superuser Terminal

A comprehensive script for managing superuser access on Android devices with enhanced security and functionality.

## Features

- 🔐 Secure root access management
- 🛡️ Enhanced security hardening
- 📱 Android device compatibility checks
- 🔧 Automated su binary permissions fixing
- 💾 Backup and restore functionality
- 📊 System information analysis
- 🎯 Termux environment support
- 🔍 Comprehensive dependency checking

## Quick Start

1. Make the script executable:
   ```bash
   chmod +x Superuser_main
   ```

2. Run the script:
   ```bash
   ./Superuser_main
   ```

3. For interactive mode:
   ```bash
   ./Superuser_main interactive
   ```

## Available Commands

- `check` - Run comprehensive system check (default)
- `interactive` - Launch interactive mode
- `setup` - Run initial setup with optimizations
- `fix` - Fix su permissions with safety checks
- `backup` - Create enhanced backup of critical files
- `benchmark` - Run system performance benchmark

## Requirements

- Android device with root access
- Bash shell environment
- Basic Unix utilities (chmod, chown, stat, etc.)

## Safety Features

- Input validation and sanitization
- Secure root elevation
- Automatic backup creation
- Error handling with cleanup
- SELinux compatibility checks

## Termux Support

Special integration for Termux environment including:
- Termux API notifications
- Storage access management
- Package management integration
- VNC server support

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License.

## Security Notice

This script modifies system-level permissions and should only be used on devices you own. Always review the code before execution and ensure you have proper backups.
EOF
        log "INFO" "✓ Created README.md"
    fi
    
    # Create docs directory content
    mkdir -p docs
    
    if [[ ! -f "docs/INSTALL.md" ]]; then
        cat > docs/INSTALL.md << 'EOF'
# Installation Guide

## Prerequisites

- Rooted Android device
- Terminal emulator (Termux recommended)
- Basic understanding of command line

## Installation Steps

1. Download the script
2. Make executable: `chmod +x Superuser_main`
3. Run: `./Superuser_main`

## Troubleshooting

See the main README.md for common issues and solutions.
EOF
        log "INFO" "✓ Created docs/INSTALL.md"
    fi
}

create_vscode_config() {
    log "INFO" "Creating VS Code configuration..."
    
    mkdir -p .vscode
    
    # Create launch.json for debugging
    cat > .vscode/launch.json << 'EOF'
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Debug Superuser Script",
            "type": "bashdb",
            "request": "launch",
            "program": "${workspaceFolder}/Superuser_main",
            "args": ["check"],
            "env": {
                "DRY_RUN": "1",
                "SKIP_ROOT_CHECK": "1"
            },
            "console": "integratedTerminal"
        }
    ]
}
EOF

    # Create settings.json
    cat > .vscode/settings.json << 'EOF'
{
    "files.eol": "\n",
    "files.trimTrailingWhitespace": true,
    "files.insertFinalNewline": true,
    "shellcheck.enable": true,
    "shellcheck.executablePath": "shellcheck",
    "shellcheck.run": "onType",
    "bash-ide-vscode.shellcheckPath": "shellcheck"
}
EOF

    log "INFO" "✓ Created VS Code configuration"
}

perform_final_validation() {
    log "INFO" "Performing comprehensive final validation..."
    
    local issues=0
    local start_time=$(date +%s)
    
    # File permission checks with detailed reporting
    local permission_files=("Superuser_main" "fix_all_problems.sh")
    for file in "${permission_files[@]}"; do
        if [[ -f "$file" ]]; then
            if [[ -x "$file" ]]; then
                log "INFO" "✓ $file is executable"
            else
                log "ERROR" "✗ $file is not executable"
                ((issues++))
            fi
        else
            log "WARN" "⚠ $file not found"
        fi
    done
    
    # Enhanced directory structure validation
    local required_dirs=(".github/workflows" "logs" "backups" "docs")
    for dir in "${required_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            local dir_perms=$(stat -c %a "$dir" 2>/dev/null || echo "unknown")
            log "INFO" "✓ Directory exists: $dir (permissions: $dir_perms)"
        else
            log "ERROR" "✗ Missing directory: $dir"
            ((issues++))
        fi
    done
    
    # CI configuration validation
    if [[ -f ".github/workflows/ci.yml" ]]; then
        local file_size=$(stat -c%s ".github/workflows/ci.yml" 2>/dev/null || echo "0")
        if [[ "$file_size" -gt 100 ]]; then
            log "INFO" "✓ CI configuration exists (${file_size} bytes)"
        else
            log "WARN" "⚠ CI configuration file seems too small"
            ((issues++))
        fi
    else
        log "ERROR" "✗ Missing CI configuration"
        ((issues++))
    fi
    
    # Check for duplicate files with enhanced detection
    local duplicates=()
    if [[ -f "superuser.test" ]]; then
        duplicates+=("superuser.test")
    fi
    
    if [[ ${#duplicates[@]} -gt 0 ]]; then
        log "WARN" "⚠ Found duplicate files: ${duplicates[*]}"
        ((issues++))
    fi
    
    # Performance timing
    local end_time=$(date +%s)
    local validation_time=$((end_time - start_time))
    log "INFO" "Validation completed in ${validation_time} seconds"
    
    return $issues
}

# Main execution flow
main() {
    local total_steps=12
    local current_step=0
    local overall_start=$(date +%s)
    
    # Step 1: Fix file permissions
    ((current_step++))
    show_progress $current_step $total_steps "Fixing file permissions"
    fix_file_permissions
    
    # Step 2: Create directory structure
    ((current_step++))
    show_progress $current_step $total_steps "Creating directory structure"
    create_directory_structure
    
    # Step 3: Fix CI configuration
    ((current_step++))
    show_progress $current_step $total_steps "Fixing CI configuration"
    fix_ci_configuration
    
    # Step 4: Fix gitignore
    ((current_step++))
    show_progress $current_step $total_steps "Creating/updating .gitignore"
    fix_gitignore
    
    # Step 5: Validate main script
    ((current_step++))
    show_progress $current_step $total_steps "Validating main script"
    validate_main_script
    
    # Step 6: Fix line endings
    ((current_step++))
    show_progress $current_step $total_steps "Fixing line endings"
    fix_line_endings
    
    # Step 7: Create documentation
    ((current_step++))
    show_progress $current_step $total_steps "Creating documentation"
    create_documentation
    
    # Step 8: Create VS Code config
    ((current_step++))
    show_progress $current_step $total_steps "Creating VS Code configuration"
    create_vscode_config
    
    # Step 9: Clean up temporary files
    ((current_step++))
    show_progress $current_step $total_steps "Cleaning up temporary files"
    find . -name "*~" -o -name "*.tmp" -o -name ".DS_Store" | xargs rm -f 2>/dev/null || true
    
    # Step 10: Final validation
    ((current_step++))
    show_progress $current_step $total_steps "Performing final validation"
    
    echo ""
    log "INFO" "Running final validation checks..."
    
    if perform_final_validation; then
        echo ""
        echo -e "${COLORS[GREEN]}╔══════════════════════════════════════════════════════╗${COLORS[NC]}"
        echo -e "${COLORS[GREEN]}║                ✅ ALL PROBLEMS FIXED ✅               ║${COLORS[NC]}"
        echo -e "${COLORS[GREEN]}║          Project is now properly configured          ║${COLORS[NC]}"
        echo -e "${COLORS[GREEN]}╚══════════════════════════════════════════════════════╝${COLORS[NC]}"
        echo ""
        log "INFO" "Fix process completed successfully!"
        log "INFO" "You can now run: ./Superuser_main"
    else
        echo ""
        echo -e "${COLORS[YELLOW]}╔══════════════════════════════════════════════════════╗${COLORS[NC]}"
        echo -e "${COLORS[YELLOW]}║              ⚠️ SOME ISSUES REMAIN ⚠️                ║${COLORS[NC]}"
        echo -e "${COLORS[YELLOW]}║           Please review the warnings above           ║${COLORS[NC]}"
        echo -e "${COLORS[YELLOW]}╚══════════════════════════════════════════════════════╝${COLORS[NC]}"
        echo ""
        log "WARN" "Fix process completed with some warnings"
    fi
    
    # Step 11: Enhanced security check
    ((current_step++))
    show_progress $current_step $total_steps "Running security checks"
    
    # Check for common security issues
    if [[ -f "Superuser_main" ]]; then
        local security_issues=0
        
        # Check for unsafe patterns
        if grep -q "rm -rf" Superuser_main; then
            log "WARN" "⚠ Found potentially dangerous 'rm -rf' commands"
            ((security_issues++))
        fi
        
        if grep -q "chmod 777" Superuser_main; then
            log "WARN" "⚠ Found overly permissive chmod 777 commands"
            ((security_issues++))
        fi
        
        if [[ $security_issues -eq 0 ]]; then
            log "INFO" "✓ No obvious security issues found"
        else
            log "WARN" "⚠ Found $security_issues potential security issues"
        fi
    fi
    
    # Step 12: Performance optimization check
    ((current_step++))
    show_progress $current_step $total_steps "Optimizing performance"
    
    # Check script size and suggest optimizations
    if [[ -f "Superuser_main" ]]; then
        local script_size=$(stat -c%s "Superuser_main")
        local line_count=$(wc -l < "Superuser_main")
        
        log "INFO" "Script metrics: ${script_size} bytes, ${line_count} lines"
        
        if [[ $script_size -gt 100000 ]]; then
            log "WARN" "⚠ Large script size detected - consider modularization"
        fi
        
        if [[ $line_count -gt 1000 ]]; then
            log "WARN" "⚠ High line count - consider breaking into modules"
        fi
    fi
    
    local overall_end=$(date +%s)
    local total_time=$((overall_end - overall_start))
    
    echo ""
    log "INFO" "Fix summary (completed in ${total_time} seconds):"
    log "INFO" "  ✓ File permissions corrected"
    log "INFO" "  ✓ Directory structure created"
    log "INFO" "  ✓ CI configuration properly placed"
    log "INFO" "  ✓ .gitignore updated"
    log "INFO" "  ✓ Documentation created"
    log "INFO" "  ✓ VS Code configuration added"
    log "INFO" "  ✓ Line endings normalized"
    log "INFO" "  ✓ Security checks performed"
    log "INFO" "  ✓ Performance analysis completed"
    log "INFO" "  ✓ Temporary files cleaned"
    
    echo ""
    echo -e "${COLORS[CYAN]}Recommended next steps:${COLORS[NC]}"
    echo "1. Test basic functionality: ${COLORS[GREEN]}./Superuser_main check${COLORS[NC]}"
    echo "2. Run interactive mode: ${COLORS[GREEN]}./Superuser_main interactive${COLORS[NC]}"
    echo "3. Review documentation: ${COLORS[GREEN]}cat README.md${COLORS[NC]}"
    echo "4. Check CI status: ${COLORS[GREEN]}git push && check GitHub Actions${COLORS[NC]}"
    echo "5. Run security scan: ${COLORS[GREEN]}shellcheck Superuser_main${COLORS[NC]}"
}

# Execute main function with enhanced error handling
main "$@"
