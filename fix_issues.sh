#!/bin/bash
# Fix Issues Script - Automatically resolve common problems
# Version: 2.0-enhanced

set -euo pipefail

# Enhanced error handling
trap 'echo "❌ Error on line $LINENO. Exit code: $?" >&2; cleanup_on_error; exit 1' ERR

cleanup_on_error() {
    echo "🧹 Cleaning up after error..."
    rm -f /tmp/syntax_check_*.log 2>/dev/null || true
}

# Color definitions
declare -A COLORS=(
    [RED]='\033[0;31m'
    [GREEN]='\033[0;32m'
    [YELLOW]='\033[1;33m'
    [BLUE]='\033[0;34m'
    [NC]='\033[0m'
)

log() {
    local level="$1"
    shift
    echo -e "${COLORS[$level]}$*${COLORS[NC]}"
}

echo -e "${COLORS[BLUE]}🔧 Fixing common issues in Superuser-device...${COLORS[NC]}"

# 1. Enhanced file permissions fixing
log "YELLOW" "Setting correct file permissions..."
local perm_count=0

for script in Superuser_main termux_auto_setup.sh start_gui.sh fix_critical_issues.sh; do
    if [[ -f "$script" ]]; then
        if chmod +x "$script"; then
            log "GREEN" "✓ Made $script executable"
            ((perm_count++))
        else
            log "RED" "❌ Failed to make $script executable"
        fi
    fi
done

log "BLUE" "Fixed permissions for $perm_count files"

# 2. Create comprehensive directory structure
log "YELLOW" "Creating missing directories..."
directories=(
    ".github/workflows"
    "logs"
    "backups"
    "docs"
    "test-env"
    "scripts"
    ".vscode"
)

for dir in "${directories[@]}"; do
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
        log "GREEN" "✓ Created directory: $dir"
    fi
done

# 3. Enhanced CI file handling
if [[ -f "superuser.test" ]]; then
    log "YELLOW" "Moving CI test file to correct location..."
    
    # Validate it's YAML format
    if head -1 "superuser.test" | grep -q "^name:"; then
        mv superuser.test .github/workflows/ci.yml
        log "GREEN" "✓ Moved superuser.test to .github/workflows/ci.yml"
    else
        log "YELLOW" "⚠ superuser.test doesn't appear to be valid YAML, creating backup..."
        mv superuser.test "superuser.test.backup"
        log "GREEN" "✓ Backed up superuser.test"
    fi
fi

# 4. Enhanced line ending fixes
if command -v dos2unix >/dev/null 2>&1; then
    log "YELLOW" "Fixing line endings..."
    find . -name "*.sh" -o -name "*.py" -o -name "Superuser_main" | \
    while IFS= read -r file; do
        if dos2unix "$file" 2>/dev/null; then
            log "GREEN" "✓ Fixed line endings: $file"
        fi
    done
else
    log "YELLOW" "dos2unix not available, manually fixing line endings..."
    for file in Superuser_main *.sh *.py; do
        if [[ -f "$file" ]]; then
            sed -i 's/\r$//' "$file" 2>/dev/null || true
        fi
    done
fi

# 5. Comprehensive syntax validation
log "YELLOW" "Validating script syntax..."
local syntax_errors=0

# Check bash scripts
for script in Superuser_main *.sh; do
    if [[ -f "$script" ]]; then
        log "BLUE" "Checking bash syntax: $script"
        if bash -n "$script" 2>/tmp/syntax_check_bash.log; then
            log "GREEN" "✓ $script syntax OK"
        else
            log "RED" "❌ Syntax errors found in $script:"
            cat /tmp/syntax_check_bash.log
            ((syntax_errors++))
        fi
    fi
done

# 6. Enhanced Python syntax checking
for py_file in *.py; do
    if [[ -f "$py_file" ]]; then
        log "BLUE" "Checking Python syntax: $py_file"
        if python3 -m py_compile "$py_file" 2>/tmp/syntax_check_python.log; then
            log "GREEN" "✓ $py_file syntax OK"
        else
            log "RED" "❌ Syntax errors found in $py_file:"
            cat /tmp/syntax_check_python.log
            ((syntax_errors++))
        fi
    fi
done

# 7. Function validation for main script
if [[ -f "Superuser_main" ]]; then
    log "YELLOW" "Checking for required functions..."
    required_functions=(
        "main"
        "log"
        "interactive_mode"
        "secure_root_check"
        "check_system_info"
        "validate_input"
    )
    
    local missing_functions=()
    for func in "${required_functions[@]}"; do
        if grep -q "^${func}()" Superuser_main; then
            log "GREEN" "✓ Found function: $func"
        else
            missing_functions+=("$func")
        fi
    done
    
    if [[ ${#missing_functions[@]} -gt 0 ]]; then
        log "YELLOW" "⚠ Missing functions: ${missing_functions[*]}"
    fi
fi

# 8. Enhanced .gitignore creation
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
*~
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

# Coverage reports
coverage/
*.coverage
htmlcov/

# Python cache
__pycache__/
*.pyc
*.pyo

# Node modules
node_modules/
EOF
    log "GREEN" "✓ Created comprehensive .gitignore"
fi

# 9. Create VS Code configuration
if [[ ! -f ".vscode/settings.json" ]]; then
    log "YELLOW" "Creating VS Code configuration..."
    mkdir -p .vscode
    cat > .vscode/settings.json << 'EOF'
{
    "files.eol": "\n",
    "files.trimTrailingWhitespace": true,
    "files.insertFinalNewline": true,
    "shellcheck.enable": true,
    "shellcheck.run": "onType"
}
EOF
    log "GREEN" "✓ Created VS Code settings"
fi

# 10. Basic functionality test
log "YELLOW" "Testing basic functionality..."
if [[ -f "Superuser_main" ]]; then
    export DRY_RUN=1
    export SKIP_ROOT_CHECK=1
    export LOG_DIR="./test-env"
    
    if timeout 10 bash Superuser_main check >/tmp/func_test.log 2>&1; then
        log "GREEN" "✓ Basic functionality test passed"
    else
        log "YELLOW" "⚠ Basic functionality test failed (may need specific environment)"
        if [[ -f "/tmp/func_test.log" ]]; then
            log "BLUE" "Test output:"
            tail -3 /tmp/func_test.log
        fi
    fi
fi

# Cleanup temporary files
rm -f /tmp/syntax_check_*.log /tmp/func_test.log 2>/dev/null || true

# Summary
echo ""
if [[ $syntax_errors -eq 0 ]]; then
    log "GREEN" "✅ Issue fixes completed successfully!"
else
    log "YELLOW" "⚠️ Fixed most issues, but $syntax_errors syntax errors need attention"
fi

echo ""
log "BLUE" "🚀 To run the application:"
echo "  ./Superuser_main check"
echo "  ./Superuser_main interactive"
echo ""
log "BLUE" "🧪 To run tests:"
echo "  bash -n Superuser_main  # Syntax check"
echo "  shellcheck Superuser_main  # Code analysis"
echo ""
log "BLUE" "📁 Project structure:"
echo "  .github/workflows/  # CI configuration"
echo "  logs/              # Application logs"
echo "  backups/           # Backup files"
echo "  docs/              # Documentation"

exit $syntax_errors
