#!/bin/bash
# Fix Issues Script - Automatically resolve common problems

set -e

echo "🔧 Fixing common issues in Superuser-device..."

# 1. Fix file permissions
echo "Setting correct file permissions..."
chmod +x Superuser_main
chmod +x termux_auto_setup.sh 2>/dev/null || echo "termux_auto_setup.sh not found"
chmod +x start_gui.sh 2>/dev/null || echo "start_gui.sh not found"

# 2. Create missing directories
echo "Creating missing directories..."
mkdir -p .github/workflows
mkdir -p logs
mkdir -p backups

# 3. Move CI test file to correct location if needed
if [[ -f "superuser.test" ]]; then
    echo "Moving CI test file to correct location..."
    mv superuser.test .github/workflows/ci.yml
fi

# 4. Fix line endings (if on Windows/mixed environment)
if command -v dos2unix >/dev/null 2>&1; then
    echo "Fixing line endings..."
    dos2unix Superuser_main *.py *.sh 2>/dev/null || true
fi

# 5. Validate script syntax
echo "Validating script syntax..."
bash -n Superuser_main || {
    echo "❌ Syntax errors found in Superuser_main"
    exit 1
}

# 6. Check Python syntax if files exist
for py_file in *.py; do
    if [[ -f "$py_file" ]]; then
        echo "Checking Python syntax: $py_file"
        python3 -m py_compile "$py_file" || {
            echo "❌ Syntax errors found in $py_file"
            exit 1
        }
    fi
done

# 7. Create basic gitignore if missing
if [[ ! -f ".gitignore" ]]; then
    echo "Creating .gitignore..."
    cat > .gitignore << EOF
# Logs
*.log
logs/

# Backups
backups/
*.backup

# Temporary files
*.tmp
*.temp

# IDE files
.vscode/
.idea/

# OS files
.DS_Store
Thumbs.db

# Test files
test-env/
coverage/
*.coverage
EOF
fi

echo "✅ Issue fixes completed successfully!"
echo ""
echo "🚀 To run the application:"
echo "  sudo ./Superuser_main"
echo "  sudo ./Superuser_main interactive"
echo ""
echo "🧪 To run tests:"
echo "  bash -n Superuser_main  # Syntax check"
echo "  shellcheck Superuser_main  # Code analysis"
