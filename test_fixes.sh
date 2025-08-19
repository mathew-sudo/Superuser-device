#!/bin/bash
# Test Fixes Script - Verify all critical issues are resolved

set -e

echo "🧪 Testing fixes for critical issues..."

# Test counters
tests_passed=0
tests_failed=0

# Helper function for tests
test_result() {
    local test_name="$1"
    local result="$2"
    
    if [[ "$result" == "0" ]]; then
        echo "✅ $test_name"
        ((tests_passed++))
    else
        echo "❌ $test_name"
        ((tests_failed++))
    fi
}

# Test 1: Check file structure
echo "Testing file structure..."
test_result "Superuser_main exists" $(test -f "Superuser_main"; echo $?)
test_result "CI workflow exists" $(test -f ".github/workflows/ci.yml"; echo $?)
test_result "Superuser_main is executable" $(test -x "Superuser_main"; echo $?)

# Test 2: Check syntax
echo "Testing script syntax..."
bash -n Superuser_main 2>/dev/null
test_result "Superuser_main syntax valid" $?

if [[ -f ".github/workflows/ci.yml" ]]; then
    # Basic YAML syntax check (if available)
    if command -v python3 >/dev/null 2>&1; then
        python3 -c "import yaml; yaml.safe_load(open('.github/workflows/ci.yml'))" 2>/dev/null
        test_result "CI workflow YAML valid" $?
    fi
fi

# Test 3: Check required functions
echo "Testing function definitions..."
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

for func in "${required_functions[@]}"; do
    grep -q "^${func}()" Superuser_main
    test_result "Function $func exists" $?
done

# Test 4: Test script execution
echo "Testing script execution..."
export DRY_RUN=1
export SKIP_ROOT_CHECK=1
export LOG_DIR="/tmp/test_logs"
mkdir -p "$LOG_DIR"

timeout 15 bash Superuser_main check >/dev/null 2>&1
test_result "Basic script execution" $?

# Test 5: Test interactive mode preparation
echo "Testing interactive mode..."
if echo "7" | timeout 10 bash Superuser_main interactive >/dev/null 2>&1; then
    test_result "Interactive mode accessible" 0
else
    test_result "Interactive mode accessible" 1
fi

# Test 6: Test Termux detection
echo "Testing Termux detection..."
export TERMUX_ENV=1
export TERMUX_HOME="/tmp/test_termux"
mkdir -p "$TERMUX_HOME"

if bash Superuser_main check 2>&1 | grep -q "Termux Environment Detected"; then
    test_result "Termux detection working" 0
else
    test_result "Termux detection working" 1
fi

# Cleanup
rm -rf "$LOG_DIR" "$TERMUX_HOME" 2>/dev/null || true
unset DRY_RUN SKIP_ROOT_CHECK TERMUX_ENV TERMUX_HOME LOG_DIR

# Summary
echo ""
echo "📊 Test Results Summary:"
echo "  ✅ Passed: $tests_passed"
echo "  ❌ Failed: $tests_failed"
echo ""

if [[ $tests_failed -eq 0 ]]; then
    echo "🎉 All tests passed! Critical issues have been resolved."
    exit 0
else
    echo "⚠️  Some tests failed. Review the output above for details."
    exit 1
fi
    "$(dirname "$0")/Superuser_main" "$@"
}
# Check dependencies
check_dependencies() {
    echo "🔍 Checking dependencies..."
    if ! command -v python3 >/dev/null 2>&1; then
        echo "❌ Python 3 is required but not installed."
        echo "Install with: sudo apt-get install python3 python3-tk"
        exit 1
    fi
    # Check for tkinter
    if ! python3 -c "import tkinter" 2>/dev/null; then
        echo "❌ tkinter is required but not installed."
        echo "Install with: sudo apt-get install python3-tk"
        exit 1
    fi
    echo "✅ All dependencies satisfied"
}
# Main execution
main() {
    check_dependencies
    setup_environment "$@"
    echo "🚀 Starting Superuser GUI..."
    "$(dirname "$0")/Superuser_main" "$@"
}
# Run main function
main "$@"
EOF
    echo "✓ Created .gitignore"
fi [[ ! -f ".gitignore" ]] && echo "No .gitignore file found, created a new one."
echo "Creating standard directories..."
mkdir -p logs backups .github/workflows
echo "✅ Fixes applied successfully!"
echo ""
echo "🎉 All critical issues fixed successfully!"
echo "Please run the test_fixes.sh script to verify all issues are resolved."
fi [ -f ".gitignore" ]] && echo "No .gitignore file found, created a new one."
echo "Creating standard directories..."
mkdir -p logs backups .github/workflows
echo "✅ Fixes applied successfully!"
echo ""
echo "🎉 All critical issues fixed successfully!"
echo "Please run the test_fixes.sh script to verify all issues are resolved."
echo "🚀 Next steps:"
echo "  1. Test the script: ./Superuser_main check"
echo "  2. Run interactive mode: ./Superuser_main interactive"
echo "  3. Check CI pipeline: .github/workflows/ci.yml"
echo "  4. Review logs in: logs/"
echo "  5. Backup important data: backups/"
echo ""
echo "Thank you for using Superuser-device!"
echo "For any issues, please open a ticket on GitHub."
echo "Have a great day! 😊"
exit 0
done
# end of script
end of script