#!/bin/bash
# Termux Auto-Setup Script for Enhanced Superuser Terminal
# Automatically configures Termux environment with root access, GUI, and tools

set -e

# Configuration variables
TERMUX_PREFIX="/data/data/com.termux/files/usr"
TERMUX_HOME="/data/data/com.termux/files/home"
ROOT_USER="root"
AUTO_LOGIN_USER="localhost"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${COLORS[CYAN]}[$timestamp] [$level]${COLORS[NC]} $message"
}

# Check if running in Termux
check_termux_environment() {
    log "INFO" "Checking Termux environment..."
    
    if [[ ! -d "/data/data/com.termux" ]]; then
        echo -e "${COLORS[RED]}Error: Not running in Termux environment${COLORS[NC]}"
        exit 1
    fi
    
    if [[ "$PREFIX" != "$TERMUX_PREFIX" ]]; then
        export PREFIX="$TERMUX_PREFIX"
        export PATH="$PREFIX/bin:$PATH"
    fi
    
    log "INFO" "Termux environment confirmed"
}

# Install essential packages
install_termux_packages() {
    log "INFO" "Installing essential Termux packages..."
    
    # Update package lists
    pkg update -y
    pkg upgrade -y
    
    # Essential packages
    local essential_packages=(
        "bash" "coreutils" "findutils" "grep" "sed" "gawk"
        "curl" "wget" "git" "nano" "vim" "openssh"
        "python" "python-pip" "nodejs" "ruby"
        "termux-api" "termux-tools" "termux-exec"
        "proot" "tsu" "unstable-repo" "x11-repo"
    )
    
    log "INFO" "Installing packages: ${essential_packages[*]}"
    pkg install -y "${essential_packages[@]}"
    
    # Development tools
    local dev_packages=(
        "build-essential" "cmake" "clang" "make"
        "autoconf" "automake" "libtool" "pkg-config"
        "git" "subversion" "mercurial"
    )
    
    log "INFO" "Installing development tools..."
    pkg install -y "${dev_packages[@]}"
    
    # Android-specific tools
    local android_packages=(
        "android-tools" "aapt" "aapt2" "dx"
        "ecj" "apksigner" "zipalign"
    )
    
    log "INFO" "Installing Android tools..."
    pkg install -y "${android_packages[@]}" || log "WARN" "Some Android tools may not be available"
}

# Install GUI packages for X11
install_gui_packages() {
    log "INFO" "Installing GUI packages..."
    
    # X11 and GUI packages
    local gui_packages=(
        "x11-repo" "xorg-xauth" "xorg-xhost"
        "tigervnc" "openbox" "pcmanfm"
        "firefox" "gedit" "gimp"
        "python-tkinter" "tk"
    )
    
    pkg install -y x11-repo
    pkg install -y "${gui_packages[@]}" || log "WARN" "Some GUI packages may not be available"
}

# Setup root user account
setup_root_account() {
    log "INFO" "Setting up root user account..."
    
    # Install and configure tsu (Termux SU)
    if ! command -v tsu >/dev/null 2>&1; then
        pkg install -y tsu
    fi
    
    # Create root directories
    local root_dirs=(
        "$TERMUX_HOME/.config/root"
        "$TERMUX_HOME/.local/share/root"
        "$TERMUX_HOME/.cache/root"
        "$TERMUX_PREFIX/etc/root"
    )
    
    for dir in "${root_dirs[@]}"; do
        mkdir -p "$dir"
        chmod 700 "$dir"
    done
    
    # Configure root profile
    cat > "$TERMUX_HOME/.config/root/profile" << 'EOF'
#!/bin/bash
# Root user profile for Termux

export PATH="/data/data/com.termux/files/usr/bin:$PATH"
export PREFIX="/data/data/com.termux/files/usr"
export HOME="/data/data/com.termux/files/home"
export TERMUX_APP_PACKAGE="com.termux"
export SHELL="/data/data/com.termux/files/usr/bin/bash"

# Custom prompt for root
export PS1='\[\033[01;31m\]root@localhost\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]# '

# Aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias su-gui='DISPLAY=:1 python3 /data/data/com.termux/files/home/superuser_gui.py'
alias superuser='sudo /data/data/com.termux/files/home/Superuser_main'

# Auto-start functions
auto_start_services() {
    # Start VNC server if GUI requested
    if [[ "$ENABLE_GUI" == "1" ]]; then
        start_vnc_server
    fi
}

# VNC server setup
start_vnc_server() {
    if ! pgrep -f "Xvnc" >/dev/null; then
        vncserver :1 -geometry 1024x768 -depth 24 >/dev/null 2>&1 &
        export DISPLAY=:1
        echo "VNC server started on :1"
    fi
}

# Auto-execute on login
auto_start_services
EOF

    chmod +x "$TERMUX_HOME/.config/root/profile"
}

# Configure auto-login to root@localhost
setup_auto_login() {
    log "INFO" "Configuring auto-login to root@localhost..."
    
    # Create auto-login script
    cat > "$TERMUX_HOME/.bashrc_auto_root" << 'EOF'
#!/bin/bash
# Auto-login to root@localhost

# Function to switch to root
auto_root_login() {
    if [[ "$(id -u)" -ne 0 ]]; then
        echo "🔐 Auto-switching to root@localhost..."
        source "$HOME/.config/root/profile"
        
        # Check if tsu is available
        if command -v tsu >/dev/null 2>&1; then
            exec tsu
        elif command -v su >/dev/null 2>&1; then
            exec su -
        else
            echo "⚠️  Root access not available - continuing as regular user"
            export PS1='\[\033[01;33m\]user@localhost\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]$ '
        fi
    else
        echo "✅ Already running as root@localhost"
        export PS1='\[\033[01;31m\]root@localhost\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]# '
    fi
}

# Auto-execute if not in sub-shell
if [[ "${AUTO_ROOT_LOGIN:-1}" == "1" && "$SHLVL" -le 2 ]]; then
    auto_root_login
fi
EOF

    # Append to main .bashrc
    if ! grep -q "bashrc_auto_root" "$TERMUX_HOME/.bashrc" 2>/dev/null; then
        echo "source \"$TERMUX_HOME/.bashrc_auto_root\"" >> "$TERMUX_HOME/.bashrc"
    fi
}

# Install Android development tools
install_android_tools() {
    log "INFO" "Installing Android development tools..."
    
    # Download and install Android SDK command line tools
    local sdk_tools_url="https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip"
    local sdk_dir="$TERMUX_HOME/android-sdk"
    
    mkdir -p "$sdk_dir"
    cd "$sdk_dir"
    
    if [[ ! -f "cmdline-tools.zip" ]]; then
        wget -O cmdline-tools.zip "$sdk_tools_url"
        unzip -q cmdline-tools.zip
        mkdir -p cmdline-tools/latest
        mv cmdline-tools/* cmdline-tools/latest/ 2>/dev/null || true
    fi
    
    # Set up Android SDK environment
    cat >> "$TERMUX_HOME/.bashrc" << EOF

# Android SDK Configuration
export ANDROID_SDK_ROOT="$sdk_dir"
export ANDROID_HOME="$sdk_dir"
export PATH="\$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:\$ANDROID_SDK_ROOT/platform-tools:\$PATH"
EOF

    # Install essential Android packages
    if [[ -x "$sdk_dir/cmdline-tools/latest/bin/sdkmanager" ]]; then
        yes | "$sdk_dir/cmdline-tools/latest/bin/sdkmanager" --licenses 2>/dev/null || true
        "$sdk_dir/cmdline-tools/latest/bin/sdkmanager" "platform-tools" "build-tools;30.0.3" "platforms;android-30"
    fi
}

# Setup Superuser Terminal integration
setup_superuser_integration() {
    log "INFO" "Setting up Superuser Terminal integration..."
    
    # Copy main script to Termux home
    cp "$SCRIPT_DIR/Superuser_main" "$TERMUX_HOME/"
    chmod +x "$TERMUX_HOME/Superuser_main"
    
    # Copy GUI script
    if [[ -f "$SCRIPT_DIR/superuser_gui.py" ]]; then
        cp "$SCRIPT_DIR/superuser_gui.py" "$TERMUX_HOME/"
    fi
    
    # Create launcher script
    cat > "$TERMUX_HOME/launch_superuser_gui.sh" << 'EOF'
#!/bin/bash
# Superuser GUI Launcher for Termux

# Check for GUI environment
setup_gui_environment() {
    if [[ -z "$DISPLAY" ]]; then
        export DISPLAY=:1
        
        # Start VNC server if not running
        if ! pgrep -f "Xvnc" >/dev/null; then
            echo "Starting VNC server..."
            vncserver :1 -geometry 1280x720 -depth 24 >/dev/null 2>&1
            sleep 2
        fi
    fi
}

# Launch GUI
launch_gui() {
    setup_gui_environment
    
    if [[ -f "$HOME/superuser_gui.py" ]]; then
        echo "🚀 Launching Superuser Terminal GUI..."
        python3 "$HOME/superuser_gui.py"
    else
        echo "❌ GUI script not found. Running terminal version..."
        bash "$HOME/Superuser_main" interactive
    fi
}

launch_gui
EOF

    chmod +x "$TERMUX_HOME/launch_superuser_gui.sh"
    
    # Create desktop shortcut if GUI is available
    if command -v python3 >/dev/null 2>&1; then
        mkdir -p "$TERMUX_HOME/.local/share/applications"
        cat > "$TERMUX_HOME/.local/share/applications/superuser-terminal.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Enhanced Superuser Terminal
Comment=Manage Android superuser access
Exec=$TERMUX_HOME/launch_superuser_gui.sh
Icon=utilities-terminal
Terminal=false
Categories=System;Security;
EOF
    fi
}

# Configure termux-api integration
setup_termux_api() {
    log "INFO" "Setting up Termux API integration..."
    
    # Install Termux:API app if not present
    if ! pkg list-installed | grep -q "termux-api"; then
        pkg install -y termux-api
    fi
    
    # Create API helper functions
    cat > "$TERMUX_HOME/.config/termux_api_helpers.sh" << 'EOF'
#!/bin/bash
# Termux API Helper Functions

# Device information
get_device_info() {
    echo "=== Device Information ==="
    termux-telephony-deviceinfo 2>/dev/null || echo "Telephony info not available"
    echo "Battery: $(termux-battery-status 2>/dev/null | jq -r '.percentage // "Unknown"')%"
    echo "WiFi: $(termux-wifi-connectioninfo 2>/dev/null | jq -r '.ssid // "Not connected"')"
}

# Send notifications
notify() {
    local title="$1"
    local message="$2"
    termux-notification --title "$title" --content "$message" 2>/dev/null || true
}

# Camera integration
take_photo() {
    local output="${1:-$HOME/photo_$(date +%Y%m%d_%H%M%S).jpg}"
    termux-camera-photo "$output" 2>/dev/null && echo "Photo saved: $output"
}

# Location services
get_location() {
    termux-location 2>/dev/null | jq -r '.latitude, .longitude' 2>/dev/null || echo "Location not available"
}

# System control
set_brightness() {
    local level="$1"
    termux-brightness "$level" 2>/dev/null || echo "Brightness control not available"
}
EOF

    # Source API helpers in bashrc
    echo "source \"$TERMUX_HOME/.config/termux_api_helpers.sh\"" >> "$TERMUX_HOME/.bashrc"
}

# Create comprehensive tools menu
create_tools_menu() {
    log "INFO" "Creating tools and options menu..."
    
    cat > "$TERMUX_HOME/termux_tools_menu.sh" << 'EOF'
#!/bin/bash
# Termux Tools and Options Menu

# Color definitions
declare -A COLORS=(
    [RED]='\033[0;31m'
    [GREEN]='\033[0;32m'
    [CYAN]='\033[0;36m'
    [YELLOW]='\033[1;33m'
    [BLUE]='\033[0;34m'
    [PURPLE]='\033[0;35m'
    [NC]='\033[0m'
)

show_main_menu() {
    clear
    echo -e "${COLORS[PURPLE]}╔══════════════════════════════════════╗${COLORS[NC]}"
    echo -e "${COLORS[PURPLE]}║     🔧 TERMUX TOOLS & OPTIONS 🔧     ║${COLORS[NC]}"
    echo -e "${COLORS[PURPLE]}╚══════════════════════════════════════╝${COLORS[NC]}"
    echo ""
    echo -e "${COLORS[CYAN]}📱 ANDROID TOOLS:${COLORS[NC]}"
    echo "1. 🔐 Enhanced Superuser Terminal (GUI)"
    echo "2. 📲 ADB Tools & Device Management"
    echo "3. 🛠️  Android Development Environment"
    echo "4. 📱 Device Information & API"
    echo ""
    echo -e "${COLORS[CYAN]}🖥️  SYSTEM TOOLS:${COLORS[NC]}"
    echo "5. 🖼️  GUI Environment (VNC)"
    echo "6. 🌐 Network Tools & SSH"
    echo "7. 💾 Package Management"
    echo "8. 🔧 System Configuration"
    echo ""
    echo -e "${COLORS[CYAN]}⚙️  UTILITIES:${COLORS[NC]}"
    echo "9. 📝 Text Editors & IDEs"
    echo "10. 🗃️ File Management"
    echo "11. 🔒 Security Tools"
    echo "12. 📊 System Monitoring"
    echo ""
    echo "0. ❌ Exit"
    echo ""
    echo -n "Select option [0-12]: "
}

handle_android_tools() {
    case "$1" in
        1)
            echo -e "${COLORS[GREEN]}🚀 Launching Enhanced Superuser Terminal...${COLORS[NC]}"
            bash "$HOME/launch_superuser_gui.sh"
            ;;
        2)
            echo -e "${COLORS[GREEN]}📲 ADB Tools Menu${COLORS[NC]}"
            adb_tools_menu
            ;;
        3)
            echo -e "${COLORS[GREEN]}🛠️  Android Development Environment${COLORS[NC]}"
            android_dev_menu
            ;;
        4)
            echo -e "${COLORS[GREEN]}📱 Device Information${COLORS[NC]}"
            get_device_info
            read -p "Press Enter to continue..."
            ;;
    esac
}

adb_tools_menu() {
    echo ""
    echo "📲 ADB Tools:"
    echo "1. List connected devices"
    echo "2. Install APK"
    echo "3. Shell access"
    echo "4. Logcat viewer"
    echo "5. Screenshot"
    echo "6. Back to main menu"
    echo ""
    read -p "Select ADB option [1-6]: " adb_choice
    
    case "$adb_choice" in
        1) adb devices -l ;;
        2) read -p "Enter APK path: " apk; adb install "$apk" ;;
        3) adb shell ;;
        4) adb logcat ;;
        5) adb exec-out screencap -p > "screenshot_$(date +%Y%m%d_%H%M%S).png" ;;
        6) return ;;
    esac
    
    read -p "Press Enter to continue..."
}

android_dev_menu() {
    echo ""
    echo "🛠️  Android Development:"
    echo "1. Setup Android SDK"
    echo "2. Create new project"
    echo "3. Build tools"
    echo "4. Emulator management"
    echo "5. Back to main menu"
    echo ""
    read -p "Select development option [1-5]: " dev_choice
    
    case "$dev_choice" in
        1) 
            echo "Setting up Android SDK..."
            sdkmanager --list
            ;;
        2)
            echo "Android project creation tools would go here..."
            ;;
        3)
            echo "Available build tools:"
            ls "$ANDROID_SDK_ROOT/build-tools/" 2>/dev/null || echo "SDK not configured"
            ;;
        4)
            echo "Emulator management..."
            avdmanager list avd 2>/dev/null || echo "No AVDs configured"
            ;;
        5) return ;;
    esac
    
    read -p "Press Enter to continue..."
}

# Main menu loop
main() {
    while true; do
        show_main_menu
        read -r choice
        
        case "$choice" in
            0) 
                echo -e "${COLORS[GREEN]}👋 Goodbye!${COLORS[NC]}"
                exit 0
                ;;
            1|2|3|4)
                handle_android_tools "$choice"
                ;;
            5)
                echo -e "${COLORS[GREEN]}🖼️  Starting VNC server...${COLORS[NC]}"
                vncserver :1 -geometry 1280x720
                echo "Connect to localhost:5901 with VNC client"
                read -p "Press Enter to continue..."
                ;;
            6)
                echo -e "${COLORS[GREEN]}🌐 Network Tools${COLORS[NC]}"
                echo "Local IP: $(ifconfig 2>/dev/null | grep -E 'inet.*192\.168|inet.*10\.' | awk '{print $2}' | head -1)"
                echo "Starting SSH server..."
                sshd
                read -p "Press Enter to continue..."
                ;;
            7)
                echo -e "${COLORS[GREEN]}💾 Package Management${COLORS[NC]}"
                echo "1. Update packages: pkg update && pkg upgrade"
                echo "2. Search package: pkg search <name>"
                echo "3. Install package: pkg install <name>"
                echo "4. List installed: pkg list-installed"
                read -p "Press Enter to continue..."
                ;;
            8)
                echo -e "${COLORS[GREEN]}🔧 System Configuration${COLORS[NC]}"
                echo "Termux setup complete!"
                echo "Storage access: termux-setup-storage"
                read -p "Press Enter to continue..."
                ;;
            9)
                echo -e "${COLORS[GREEN]}📝 Available editors: nano, vim, emacs${COLORS[NC]}"
                read -p "Press Enter to continue..."
                ;;
            10)
                echo -e "${COLORS[GREEN]}🗃️  File managers: mc, ranger, nnn${COLORS[NC]}"
                read -p "Press Enter to continue..."
                ;;
            11)
                echo -e "${COLORS[GREEN]}🔒 Security tools available${COLORS[NC]}"
                read -p "Press Enter to continue..."
                ;;
            12)
                echo -e "${COLORS[GREEN]}📊 System stats:${COLORS[NC]}"
                echo "Uptime: $(uptime)"
                echo "Memory: $(free -h 2>/dev/null || echo 'N/A')"
                read -p "Press Enter to continue..."
                ;;
            *)
                echo -e "${COLORS[RED]}❌ Invalid option${COLORS[NC]}"
                sleep 1
                ;;
        esac
    done
}

main "$@"
EOF

    chmod +x "$TERMUX_HOME/termux_tools_menu.sh"
    
    # Add alias to bashrc
    echo "alias tools='bash \$HOME/termux_tools_menu.sh'" >> "$TERMUX_HOME/.bashrc"
}

# Main installation function
main() {
    echo -e "${COLORS[PURPLE]}╔══════════════════════════════════════════════════════╗${COLORS[NC]}"
    echo -e "${COLORS[PURPLE]}║         🚀 TERMUX AUTO-SETUP FOR ROOT@LOCALHOST       ║${COLORS[NC]}"
    echo -e "${COLORS[PURPLE]}║              Enhanced Superuser Terminal              ║${COLORS[NC]}"
    echo -e "${COLORS[PURPLE]}╚══════════════════════════════════════════════════════╝${COLORS[NC]}"
    echo ""
    
    log "INFO" "Starting comprehensive Termux setup..."
    
    # Check environment
    check_termux_environment
    
    # Install packages
    install_termux_packages
    install_gui_packages
    
    # Setup user accounts and auto-login
    setup_root_account
    setup_auto_login
    
    # Install Android tools
    install_android_tools
    
    # Setup integrations
    setup_superuser_integration
    setup_termux_api
    
    # Create tools menu
    create_tools_menu
    
    # Final configuration
    log "INFO" "Configuring final settings..."
    
    # Enable storage access
    if command -v termux-setup-storage >/dev/null 2>&1; then
        termux-setup-storage
    fi
    
    # Set up welcome message
    cat > "$TERMUX_HOME/.config/welcome_message.sh" << 'EOF'
#!/bin/bash
# Welcome message for Termux

echo -e "\033[0;32m╔══════════════════════════════════════════════════════╗\033[0m"
echo -e "\033[0;32m║        🔐 ENHANCED SUPERUSER TERMINAL READY 🔐       ║\033[0m"
echo -e "\033[0;32m╚══════════════════════════════════════════════════════╝\033[0m"
echo ""
echo -e "\033[1;36m🚀 Quick Commands:\033[0m"
echo "  • superuser          - Launch Enhanced Superuser Terminal"
echo "  • tools              - Open Tools & Options Menu"
echo "  • su-gui             - Launch GUI (if X11 available)"
echo ""
echo -e "\033[1;33m📱 Device Status:\033[0m"
echo "  • User: $(whoami)@localhost"
echo "  • Root: $(command -v tsu >/dev/null && echo "Available" || echo "Not available")"
echo "  • GUI: $(command -v vncserver >/dev/null && echo "VNC Ready" || echo "Terminal only")"
echo ""
EOF

    # Add welcome message to bashrc
    echo "source \"$TERMUX_HOME/.config/welcome_message.sh\"" >> "$TERMUX_HOME/.bashrc"
    
    # Create completion message
    echo ""
    log "INFO" "🎉 Termux auto-setup completed successfully!"
    echo ""
    echo -e "${COLORS[GREEN]}✅ Installation Summary:${COLORS[NC]}"
    echo "  📦 Essential packages installed"
    echo "  🖥️  GUI environment configured (VNC)"
    echo "  🔐 Root access configured (tsu)"
    echo "  📱 Android tools installed"
    echo "  🔧 Superuser Terminal integrated"
    echo "  🛠️  Tools menu created"
    echo ""
    echo -e "${COLORS[YELLOW]}🔄 To activate changes, restart Termux or run:${COLORS[NC]}"
    echo "  source ~/.bashrc"
    echo ""
    echo -e "${COLORS[CYAN]}🚀 Quick start commands:${COLORS[NC]}"
    echo "  • Type 'tools' for main menu"
    echo "  • Type 'superuser' for Enhanced Superuser Terminal"
    echo "  • Type 'su-gui' for GUI version (requires VNC client)"
    echo ""
    echo -e "${COLORS[PURPLE]}📖 For VNC GUI access:${COLORS[NC]}"
    echo "  1. Install VNC client on your device"
    echo "  2. Connect to localhost:5901"
    echo "  3. Password will be prompted on first VNC start"
    echo ""
}

# Execute main function
main "$@"