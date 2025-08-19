#!/bin/bash
# GUI Launcher Script for Enhanced Superuser Terminal

# Check for Python dependencies
check_dependencies() {
    echo "Checking GUI dependencies..."
    
    if ! command -v python3 >/dev/null 2>&1; then
        echo "Error: Python 3 is required but not installed."
        echo "Install with: sudo apt-get install python3 python3-tk"
        exit 1
    fi
    
    # Check for tkinter
    if ! python3 -c "import tkinter" 2>/dev/null; then
        echo "Error: tkinter is required but not installed."
        echo "Install with: sudo apt-get install python3-tk"
        exit 1
    fi
    
    echo "✓ All dependencies satisfied"
}

# Set up environment
setup_environment() {
    export DISPLAY=${DISPLAY:-:0}
    
    # Ensure script is executable
    chmod +x "$(dirname "$0")/Superuser_main"
    
    # Create desktop entry if requested
    if [[ "$1" == "--install-desktop" ]]; then
        create_desktop_entry
    fi
}

# Create desktop entry
create_desktop_entry() {
    local desktop_file="$HOME/.local/share/applications/superuser-terminal.desktop"
    local script_dir="$(cd "$(dirname "$0")" && pwd)"
    
    mkdir -p "$(dirname "$desktop_file")"
    
    cat > "$desktop_file" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Enhanced Superuser Terminal
Comment=Manage Android superuser access with GUI
Exec=$script_dir/start_gui.sh
Icon=utilities-terminal
Terminal=false
Categories=System;Security;
Keywords=root;superuser;android;su;
EOF
    
    chmod +x "$desktop_file"
    echo "✓ Desktop entry created: $desktop_file"
}

# Main execution
main() {
    echo "🔐 Enhanced Superuser Terminal GUI Launcher"
    echo "==========================================="
    
    check_dependencies
    setup_environment "$@"
    
    # Launch GUI
    echo "Starting GUI application..."
    cd "$(dirname "$0")"
    python3 superuser_gui.py
}

# Handle command line arguments
case "${1:-}" in
    "--help"|"-h")
        echo "Usage: $0 [--install-desktop]"
        echo ""
        echo "Options:"
        echo "  --install-desktop    Create desktop entry for easy access"
        echo "  --help, -h          Show this help message"
        exit 0
        ;;
    *)
        main "$@"
        ;;
esac
