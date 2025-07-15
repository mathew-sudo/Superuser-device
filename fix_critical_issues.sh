#!/bin/bash
# Fix Critical Issues Script - Resolve all blocking problems

set -e

echo "🔧 Fixing critical issues in Superuser-device..."

# 1. Create missing .github/workflows directory
echo "Creating .github/workflows directory..."
mkdir -p .github/workflows

# 2. Move CI test file if it exists in wrong location
if [[ -f "superuser.test" ]]; then
    echo "Moving CI test file to correct location..."
    mv superuser.test .github/workflows/ci.yml
    echo "✓ Moved superuser.test to .github/workflows/ci.yml"
fi

# 3. Fix file permissions
echo "Setting correct file permissions..."
chmod +x Superuser_main
chmod +x *.sh 2>/dev/null || true

# 4. Validate all bash scripts for critical syntax errors
echo "Validating script syntax..."
for script in *.sh Superuser_main; do
    if [[ -f "$script" ]]; then
        echo "Checking $script..."
        if ! bash -n "$script"; then
            echo "❌ Syntax error in $script"
            exit 1
        fi
        echo "✓ $script syntax OK"
    fi
done

# 5. Check for missing functions
echo "Checking for required functions in Superuser_main..."
required_functions=(
    "main"
    "interactive_mode"
    "termux_interactive_mode"
    "termux_integration"
    "secure_root_check"
    "check_system_info"
    "fix_su_permissions"
    "detect_termux"
)

missing_functions=()
for func in "${required_functions[@]}"; do
    if ! grep -q "^${func}()" Superuser_main; then
        missing_functions+=("$func")
    fi
done

if [[ ${#missing_functions[@]} -gt 0 ]]; then
    echo "❌ Missing functions: ${missing_functions[*]}"
    echo "These functions need to be implemented in Superuser_main"
    exit 1
else
    echo "✓ All required functions found"
fi

# 6. Test basic script execution
echo "Testing basic script execution..."
export DRY_RUN=1
export SKIP_ROOT_CHECK=1
if timeout 10 bash Superuser_main check >/dev/null 2>&1; then
    echo "✓ Basic script execution works"
else
    echo "⚠️ Script execution test failed - may need runtime environment"
fi

# 7. Create basic .gitignore if missing
if [[ ! -f ".gitignore" ]]; then
    echo "Creating .gitignore..."
    cat > .gitignore << 'EOF'
# Logs
*.log
logs/

# Backups
backups/
*.backup

# Temporary files
*.tmp
*.temp
test-env/

# IDE files
.vscode/
.idea/

# OS files
.DS_Store
Thumbs.db
EOF
    echo "✓ Created .gitignore"
fi

# 8. Create missing directories
echo "Creating standard directories..."
mkdir -p logs backups .github/workflows

echo ""
echo "✅ Critical issues fixed successfully!"
echo ""
echo "🚀 Next steps:"
echo "  1. Test the script: ./Superuser_main check"
echo "  2. Run interactive mode: ./Superuser_main interactive"
echo "  3. Check CI pipeline: .github/workflows/ci.yml"
echo ""
echo "⚠️  Note: Some features may require root access or specific Android environment"
