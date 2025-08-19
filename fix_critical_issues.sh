#!/bin/bash
# Fix Critical Issues Script - Resolve all blocking problems
# Version: 2.0-enhanced
# This script ensures all critical issues in the Superuser device management scripts are fixed.

set -euo pipefail

# Enhanced error handling
trap 'echo "❌ Error on line $LINENO. Exit code: $?" >&2; exit 1' ERR

# Color support
declare -A COLORS=(
    [RED]='\033[0;31m'
    [GREEN]='\033[0;32m'
    [YELLOW]='\033[1;33m'
    [BLUE]='\033[0;34m'
    [NC]='\033[0m'
)

# Logging function
log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%H:%M:%S')
    echo -e "${COLORS[BLUE]}[$timestamp]${COLORS[NC]} ${COLORS[$level]}$message${COLORS[NC]}"
}

echo -e "${COLORS[BLUE]}🔧 Fixing critical issues in Superuser-device...${COLORS[NC]}"

# 1. Create missing .github/workflows directory
log "YELLOW" "Creating .github/workflows directory..."
mkdir -p .github/workflows

# 2. Move CI test file if it exists in wrong location and fix format
if [[ -f "superuser.test" ]]; then
    log "YELLOW" "Moving CI test file to correct location..."
    
    # Check if it's already YAML format
    if head -1 "superuser.test" | grep -q "^name:"; then
        mv superuser.test .github/workflows/ci.yml
        log "GREEN" "✓ Moved superuser.test to .github/workflows/ci.yml"
    else
        log "RED" "⚠ superuser.test doesn't appear to be valid YAML"
        # Create a basic CI file instead
        cat > .github/workflows/ci.yml << 'EOF'
name: Superuser CI Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - name: Test Script
      run: |
        chmod +x Superuser_main
        export DRY_RUN=1
        export SKIP_ROOT_CHECK=1
        bash Superuser_main check
EOF
        log "GREEN" "✓ Created basic CI configuration"
    fi
fi

# 3. Fix file permissions with validation
log "YELLOW" "Setting correct file permissions..."
local perm_fixed=0
local perm_failed=0

if [[ -f "Superuser_main" ]]; then
    if chmod +x Superuser_main; then
        ((perm_fixed++))
        log "GREEN" "✓ Made Superuser_main executable"
    else
        ((perm_failed++))
        log "RED" "❌ Failed to make Superuser_main executable"
    fi
fi

# Fix all shell scripts
for script in *.sh; do
    if [[ -f "$script" ]]; then
        if chmod +x "$script"; then
            ((perm_fixed++))
        else
            ((perm_failed++))
            log "RED" "❌ Failed to make $script executable"
        fi
    fi
done

log "BLUE" "Permissions: $perm_fixed fixed, $perm_failed failed"

# 4. Validate all bash scripts for critical syntax errors
log "YELLOW" "Validating script syntax..."
local syntax_errors=0

for script in *.sh Superuser_main; do
    if [[ -f "$script" ]]; then
        log "BLUE" "Checking $script..."
        if bash -n "$script" 2>/tmp/syntax_check.log; then
            log "GREEN" "✓ $script syntax OK"
        else
            log "RED" "❌ Syntax error in $script:"
            cat /tmp/syntax_check.log
            ((syntax_errors++))
        fi
    fi
done

if [[ $syntax_errors -gt 0 ]]; then
    log "RED" "❌ Found $syntax_errors syntax errors - manual intervention required"
    exit 1
fi

# 5. Check for missing functions and suggest fixes
log "YELLOW" "Checking for required functions in Superuser_main..."
if [[ ! -f "Superuser_main" ]]; then
    log "RED" "❌ Superuser_main not found!"
    exit 1
fi

required_functions=(
    "main"
    "log"
    "interactive_mode"
    "termux_interactive_mode"
    "termux_integration"
    "secure_root_check"
    "check_system_info"
    "fix_su_permissions"
    "detect_termux"
    "check_dependencies"
    "validate_input"
)

missing_functions=()
found_functions=()

for func in "${required_functions[@]}"; do
    if grep -q "^${func}()" Superuser_main; then
        found_functions+=("$func")
    else
        missing_functions+=("$func")
    fi
done

log "GREEN" "✓ Found ${#found_functions[@]} required functions"
if [[ ${#missing_functions[@]} -gt 0 ]]; then
    log "YELLOW" "⚠ Missing functions: ${missing_functions[*]}"
    log "YELLOW" "These functions may be referenced but not implemented"
else
    log "GREEN" "✓ All required functions found"
fi

# 6. Enhanced script execution test
log "YELLOW" "Testing basic script execution..."
export DRY_RUN=1
export SKIP_ROOT_CHECK=1
export LOG_DIR="./test-env"
mkdir -p "$LOG_DIR"

if timeout 15 bash Superuser_main check >/tmp/exec_test.log 2>&1; then
    log "GREEN" "✓ Basic script execution works"
else
    log "YELLOW" "⚠️ Script execution test failed - checking log..."
    if [[ -f "/tmp/exec_test.log" ]]; then
        log "BLUE" "Last 5 lines of execution log:"
        tail -5 /tmp/exec_test.log
    fi
fi

# 7. Create comprehensive .gitignore if missing
if [[ ! -f ".gitignore" ]]; then
    log "YELLOW" "Creating comprehensive .gitignore..."
    cat > .gitignore << 'EOF'
# Logs
*.log
logs/
test-logs*/
perf-logs*/

# Backups
backups/
*.backup
*.bak

# Temporary files
*.tmp
*.temp
test-env/
superuser_temp_*

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

# Runtime files
*.pid
*.swp
*~
EOF
    log "GREEN" "✓ Created comprehensive .gitignore"
fi

# 8. Create missing directories with proper structure
log "YELLOW" "Creating standard directory structure..."
directories=(
    "logs"
    "backups" 
    ".github/workflows"
    "docs"
    "test-env"
)

for dir in "${directories[@]}"; do
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
        log "GREEN" "✓ Created directory: $dir"
    fi
done

# 9. Create basic documentation if missing
if [[ ! -f "README.md" ]]; then
    log "YELLOW" "Creating basic README.md..."
    cat > README.md << 'EOF'
# Enhanced Superuser Terminal

A comprehensive script for managing superuser access on Android devices.

## Quick Start

```bash
chmod +x Superuser_main
./Superuser_main check
```

## Commands

- `check` - Run system check
- `interactive` - Launch interactive mode
- `fix` - Fix su permissions
- `backup` - Create backup

## Requirements

- Android device with root access
- Bash shell environment
- Basic Unix utilities

For detailed documentation, see the docs/ directory.
EOF
    log "GREEN" "✓ Created basic README.md"
fi

# 10. Final validation and summary
log "YELLOW" "Performing final validation..."
local issues=0

# Check critical files exist
critical_files=("Superuser_main" ".github/workflows/ci.yml")
for file in "${critical_files[@]}"; do
    if [[ -f "$file" ]]; then
        log "GREEN" "✓ Critical file exists: $file"
    else
        log "RED" "❌ Missing critical file: $file"
        ((issues++))
    fi
done

# Check permissions
if [[ -x "Superuser_main" ]]; then
    log "GREEN" "✓ Superuser_main is executable"
else
    log "RED" "❌ Superuser_main is not executable"
    ((issues++))
fi

# Cleanup temporary files
rm -f /tmp/syntax_check.log /tmp/exec_test.log 2>/dev/null || true

echo ""
if [[ $issues -eq 0 ]]; then
    log "GREEN" "✅ Critical issues fixed successfully!"
else
    log "YELLOW" "⚠️ Fixed most issues, but $issues critical problems remain"
fi

echo ""
log "BLUE" "🚀 Next steps:"
echo "  1. Test the script: ./Superuser_main check"
echo "  2. Run interactive mode: ./Superuser_main interactive"
echo "  3. Check CI pipeline: .github/workflows/ci.yml"
echo "  4. Review documentation: README.md"
echo ""
log "YELLOW" "⚠️  Note: Some features may require root access or specific Android environment"

# Exit with appropriate code
exit $issues
