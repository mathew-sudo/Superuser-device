#!/bin/bash
# Advanced Configuration Script for Enhanced Superuser Terminal
# Version: 1.1-enhanced
# This script provides advanced configuration options for power users

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

# Configuration file paths
CONFIG_DIR="/data/superuser/config"
MAIN_CONFIG="$CONFIG_DIR/superuser.conf"
ENV_CONFIG="$CONFIG_DIR/environment.conf"
ALIAS_CONFIG="$CONFIG_DIR/aliases.conf"

# Ensure we're running as root
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${COLORS[RED]}Error: This script must be run as root${COLORS[NC]}"
    exit 1
fi

# Create configuration directory
mkdir -p "$CONFIG_DIR" 2>/dev/null || {
    echo -e "${COLORS[RED]}Error: Cannot create config directory${COLORS[NC]}"
    exit 1
}

# Main configuration function
create_main_config() {
    echo -e "${COLORS[CYAN]}Creating main configuration...${COLORS[NC]}"
    
    cat > "$MAIN_CONFIG" << 'EOF'
# Enhanced Superuser Terminal Configuration
# Version: 1.1-enhanced

# Performance settings
PARALLEL_JOBS=4
MAX_LOGS=12
LOG_ROTATION_DAYS=7

# Security settings
REQUIRE_ROOT_CHECK=1
BACKUP_BEFORE_CHANGES=1
VALIDATE_SU_BINARIES=1

# Feature toggles
ENABLE_TERMUX_INTEGRATION=1
ENABLE_ANDROID_COMMANDS=1
ENABLE_NETWORK_DIAGNOSTICS=1
ENABLE_SECURITY_AUDIT=1
ENABLE_PERFORMANCE_BENCHMARK=1

# Path settings
SUPERUSER_HOME="/data/superuser"
BACKUP_DIR="/data/superuser/backups"
LOG_DIR="/data/superuser/logs"
SCRIPT_DIR="/data/superuser/scripts"

# Color scheme (0=disable, 1=enable)
ENABLE_COLORS=1
COLOR_SCHEME="default"

# Logging settings
LOG_LEVEL="INFO"  # DEBUG, INFO, WARN, ERROR, FATAL
ENABLE_PERFORMANCE_LOGGING=1
ENABLE_SYSLOG=0

# Network settings
NETWORK_TIMEOUT=10
DNS_SERVERS="8.8.8.8 1.1.1.1"
CONNECTIVITY_CHECK_HOSTS="google.com cloudflare.com"

# Advanced features
ENABLE_AUTO_BACKUP=1
AUTO_BACKUP_INTERVAL=24  # hours
ENABLE_HEALTH_MONITORING=1
HEALTH_CHECK_INTERVAL=60  # minutes

# Su binary paths (space-separated)
SU_BINARY_PATHS="/system/bin/su /system/xbin/su /sbin/su /su/bin/su"

# Environment isolation
ISOLATED_ENVIRONMENT=0
SANDBOX_MODE=0
EOF

    echo -e "${COLORS[GREEN]}✓ Main configuration created${COLORS[NC]}"
}

# Environment configuration
create_environment_config() {
    echo -e "${COLORS[CYAN]}Creating environment configuration...${COLORS[NC]}"
    
    cat > "$ENV_CONFIG" << 'EOF'
# Environment Configuration for Enhanced Superuser Terminal

# Path modifications
export PATH="/data/superuser/bin:/system/bin:/system/xbin:$PATH"
export SUPERUSER_HOME="/data/superuser"
export SUPERUSER_VERSION="1.1-enhanced"

# Android-specific environment
export ANDROID_DATA="/data"
export ANDROID_ROOT="/system"
export ANDROID_STORAGE="/storage"

# Development environment
export ANDROID_SDK_ROOT="/opt/android-sdk"
export JAVA_HOME="/usr/lib/jvm/default"
export GRADLE_HOME="/opt/gradle"

# Terminal settings
export TERM="xterm-256color"
export EDITOR="nano"
export PAGER="less"

# Termux compatibility
if [[ -d "/data/data/com.termux" ]]; then
    export TERMUX_ENV=1
    export PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"
    export TERMUX_HOME="${TERMUX_HOME:-/data/data/com.termux/files/home}"
fi

# Locale settings
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# Security settings
export HISTCONTROL="ignoredups:ignorespace"
export HISTSIZE=1000
export HISTFILESIZE=2000

# Performance settings
export PARALLEL_JOBS="${PARALLEL_JOBS:-4}"
export TMPDIR="/data/superuser/tmp"

# Debugging
if [[ "${DEBUG:-0}" == "1" ]]; then
    export PS4='+ ${BASH_SOURCE}:${LINENO}: ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
    set -x
fi
EOF

    echo -e "${COLORS[GREEN]}✓ Environment configuration created${COLORS[NC]}"
}

# Alias configuration
create_alias_config() {
    echo -e "${COLORS[CYAN]}Creating alias configuration...${COLORS[NC]}"
    
    cat > "$ALIAS_CONFIG" << 'EOF'
# Alias Configuration for Enhanced Superuser Terminal

# Basic aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Enhanced ls aliases
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Safety aliases
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Superuser-specific aliases
alias su-check='check_accessibility'
alias su-fix='fix_su_permissions'
alias su-backup='backup_critical_files'
alias su-restore='restore_from_backup'
alias su-logs='tail -f /data/superuser/logs/superuser.log'
alias su-status='quick_status'
alias su-env='setup_environment'
alias su-update='update_superuser_terminal'

# System monitoring aliases
alias meminfo='cat /proc/meminfo'
alias cpuinfo='cat /proc/cpuinfo'
alias diskusage='df -h'
alias processes='ps aux'
alias netstat='netstat -tuln'

# Android-specific aliases
alias adb-devices='adb devices'
alias adb-shell='adb shell'
alias adb-logcat='adb logcat'
alias android-version='getprop ro.build.version.release'
alias android-api='getprop ro.build.version.sdk'

# Termux-specific aliases (if in Termux environment)
if [[ "${TERMUX_ENV:-0}" == "1" ]]; then
    alias pkg-update='pkg update && pkg upgrade'
    alias pkg-search='pkg search'
    alias pkg-install='pkg install'
    alias termux-storage='termux-setup-storage'
    alias termux-api='termux-setup-api'
fi

# Git aliases (if git is available)
if command -v git >/dev/null 2>&1; then
    alias gs='git status'
    alias ga='git add'
    alias gc='git commit'
    alias gp='git push'
    alias gl='git log --oneline'
    alias gd='git diff'
fi

# Network aliases
alias ping4='ping -4'
alias ping6='ping -6'
alias wget-continue='wget -c'
alias curl-headers='curl -I'

# Development aliases
alias make-clean='make clean'
alias compile-debug='gcc -g -Wall'
alias python-server='python3 -m http.server'

# Security aliases
alias secure-delete='shred -vfz -n 3'
alias check-perms='find . -type f -perm /g+w,o+w -exec ls -l {} \;'
alias find-suid='find / -perm -4000 -type f 2>/dev/null'

# Function aliases
alias weather='curl wttr.in'
alias myip='curl ipinfo.io/ip'
alias speedtest='curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3 -'

# Quick navigation
alias home='cd $SUPERUSER_HOME'
alias logs='cd /data/superuser/logs'
alias scripts='cd /data/superuser/scripts'
alias backups='cd /data/superuser/backups'
EOF

    echo -e "${COLORS[GREEN]}✓ Alias configuration created${COLORS[NC]}"
}

# Create advanced functions file
create_advanced_functions() {
    echo -e "${COLORS[CYAN]}Creating advanced functions...${COLORS[NC]}"
    
    cat > "$CONFIG_DIR/functions.sh" << 'EOF'
#!/bin/bash
# Advanced Functions for Enhanced Superuser Terminal

# Quick system status with enhanced details
quick_status() {
    echo -e "\033[1;36m=== Enhanced System Status ===\033[0m"
    
    # Root status
    local root_status=$(test "$(id -u)" -eq 0 && echo "✅ Active" || echo "❌ Not active")
    echo "Root Access: $root_status"
    
    # Superuser directory
    local su_dir=$(test -d /data/superuser && echo "✅ Present" || echo "❌ Missing")
    echo "Superuser Directory: $su_dir"
    
    # Memory usage
    if [[ -f "/proc/meminfo" ]]; then
        local mem_total=$(awk '/MemTotal/ {printf "%.1f GB", $2/1024/1024}' /proc/meminfo)
        local mem_avail=$(awk '/MemAvailable/ {printf "%.1f GB", $2/1024/1024}' /proc/meminfo)
        echo "Memory: $mem_avail / $mem_total available"
    fi
    
    # Storage usage
    if command -v df >/dev/null 2>&1; then
        local storage=$(df /data 2>/dev/null | tail -1 | awk '{print $5 " used, " int($4/1024) " MB free"}')
        echo "Storage (/data): $storage"
    fi
    
    # System load
    if [[ -f "/proc/loadavg" ]]; then
        local load=$(cut -d' ' -f1-3 /proc/loadavg)
        echo "Load Average: $load"
    fi
    
    # Network status
    local network_status="❌ No connectivity"
    if ping -c 1 8.8.8.8 >/dev/null 2>&1; then
        network_status="✅ Connected"
    fi
    echo "Network: $network_status"
    
    # Android version
    if command -v getprop >/dev/null 2>&1; then
        local android_ver=$(getprop ro.build.version.release 2>/dev/null || echo "Unknown")
        local api_level=$(getprop ro.build.version.sdk 2>/dev/null || echo "Unknown")
        echo "Android: $android_ver (API $api_level)"
    fi
    
    echo "Timestamp: $(date)"
}

# Enhanced su binary check with detailed analysis
check_su_detailed() {
    echo -e "\033[1;36m=== Detailed Su Binary Analysis ===\033[0m"
    
    local su_paths=(
        "/system/bin/su" "/system/xbin/su" "/sbin/su" "/su/bin/su" 
        "/su/xbin/su" "/system/sbin/su" "/magisk/.core/bin/su"
    )
    
    local found=0
    local working=0
    
    for su_path in "${su_paths[@]}"; do
        if [[ -f "$su_path" ]]; then
            ((found++))
            echo -n "📁 $su_path: "
            
            # Check permissions
            local perms=$(stat -c %a "$su_path" 2>/dev/null || echo "000")
            local owner=$(stat -c %U "$su_path" 2>/dev/null || echo "unknown")
            local group=$(stat -c %G "$su_path" 2>/dev/null || echo "unknown")
            
            # Check if executable
            if [[ -x "$su_path" ]]; then
                echo -n "executable, "
            else
                echo -n "not executable, "
            fi
            
            echo "perms: $perms, owner: $owner:$group"
            
            # Test functionality
            if timeout 3 "$su_path" -c "id" >/dev/null 2>&1; then
                echo "   ✅ Functional"
                ((working++))
            else
                echo "   ❌ Not functional"
            fi
        fi
    done
    
    echo ""
    echo "Summary: $found binaries found, $working working"
}

# System cleanup function
cleanup_system() {
    echo -e "\033[1;36m=== System Cleanup ===\033[0m"
    
    # Clean temporary files
    echo "🧹 Cleaning temporary files..."
    rm -rf /data/superuser/tmp/* 2>/dev/null
    rm -rf /tmp/superuser_temp_* 2>/dev/null
    
    # Rotate logs
    echo "📋 Rotating logs..."
    if [[ -d "/data/superuser/logs" ]]; then
        find /data/superuser/logs -name "*.log" -mtime +7 -delete 2>/dev/null
    fi
    
    # Clean old backups
    echo "💾 Cleaning old backups..."
    if [[ -d "/data/superuser/backups" ]]; then
        find /data/superuser/backups -type d -mtime +30 -exec rm -rf {} + 2>/dev/null
    fi
    
    echo "✅ Cleanup completed"
}

# Network diagnostics function
network_diagnostics() {
    echo -e "\033[1;36m=== Network Diagnostics ===\033[0m"
    
    # Check DNS resolution
    echo "🌐 Testing DNS resolution..."
    for dns in "8.8.8.8" "1.1.1.1" "8.8.4.4"; do
        if nslookup google.com "$dns" >/dev/null 2>&1; then
            echo "   ✅ DNS $dns: Working"
        else
            echo "   ❌ DNS $dns: Failed"
        fi
    done
    
    # Check connectivity
    echo "🔗 Testing connectivity..."
    for host in "google.com" "github.com" "cloudflare.com"; do
        if ping -c 1 "$host" >/dev/null 2>&1; then
            echo "   ✅ $host: Reachable"
        else
            echo "   ❌ $host: Unreachable"
        fi
    done
    
    # Check network interfaces
    echo "🔌 Network interfaces:"
    if command -v ip >/dev/null 2>&1; then
        ip addr show | grep -E "^[0-9]+:|inet " | head -10
    else
        echo "   IP command not available"
    fi
}

# Performance monitoring
monitor_performance() {
    echo -e "\033[1;36m=== Performance Monitor ===\033[0m"
    
    # CPU usage
    if [[ -f "/proc/loadavg" ]]; then
        local load=$(cat /proc/loadavg)
        echo "📊 Load Average: $load"
    fi
    
    # Memory usage
    if [[ -f "/proc/meminfo" ]]; then
        echo "💾 Memory Usage:"
        awk '/MemTotal|MemFree|MemAvailable|Buffers|Cached/ {printf "   %s: %d MB\n", $1, $2/1024}' /proc/meminfo
    fi
    
    # Disk I/O
    if [[ -f "/proc/diskstats" ]]; then
        echo "💿 Disk Activity:"
        awk '{if($4>0) printf "   %s: %d reads, %d writes\n", $3, $4, $8}' /proc/diskstats | head -5
    fi
    
    # Process count
    local proc_count=$(ps aux | wc -l)
    echo "⚙️  Active Processes: $proc_count"
}

# Security check function
security_check() {
    echo -e "\033[1;36m=== Security Check ===\033[0m"
    
    # Check for world-writable files
    echo "🔍 Checking for world-writable files in sensitive locations..."
    local sensitive_dirs=("/system" "/data/local")
    for dir in "${sensitive_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            local count=$(find "$dir" -type f -perm -002 2>/dev/null | wc -l)
            if [[ "$count" -gt 0 ]]; then
                echo "   ⚠️  $dir: $count world-writable files found"
            else
                echo "   ✅ $dir: No world-writable files"
            fi
        fi
    done
    
    # Check SELinux status
    if command -v getenforce >/dev/null 2>&1; then
        local selinux=$(getenforce 2>/dev/null || echo "Unknown")
        echo "🛡️  SELinux Status: $selinux"
    fi
    
    # Check for debugging flags
    if [[ -f "/proc/sys/kernel/yama/ptrace_scope" ]]; then
        local ptrace=$(cat /proc/sys/kernel/yama/ptrace_scope)
        echo "🔐 Ptrace Scope: $ptrace"
    fi
}

# Export functions
export -f quick_status
export -f check_su_detailed
export -f cleanup_system
export -f network_diagnostics
export -f monitor_performance
export -f security_check
EOF

    chmod +x "$CONFIG_DIR/functions.sh"
    echo -e "${COLORS[GREEN]}✓ Advanced functions created${COLORS[NC]}"
}

# Create startup script
create_startup_script() {
    echo -e "${COLORS[CYAN]}Creating startup script...${COLORS[NC]}"
    
    cat > "$CONFIG_DIR/startup.sh" << 'EOF'
#!/bin/bash
# Startup Script for Enhanced Superuser Terminal

# Source configuration files
if [[ -f "/data/superuser/config/superuser.conf" ]]; then
    source /data/superuser/config/superuser.conf
fi

if [[ -f "/data/superuser/config/environment.conf" ]]; then
    source /data/superuser/config/environment.conf
fi

if [[ -f "/data/superuser/config/aliases.conf" ]]; then
    source /data/superuser/config/aliases.conf
fi

if [[ -f "/data/superuser/config/functions.sh" ]]; then
    source /data/superuser/config/functions.sh
fi

# Display startup banner
echo -e "\033[1;32m"
echo "╔══════════════════════════════════════════════════════╗"
echo "║     🔐 Enhanced Superuser Terminal Environment      ║"
echo "║                  Ready for Action                   ║"
echo "╚══════════════════════════════════════════════════════╝"
echo -e "\033[0m"

# Show quick status
quick_status

echo ""
echo "🚀 Type 'su_status' for detailed information"
echo "📚 Type 'help' for available commands"
echo "⚙️  Configuration loaded from /data/superuser/config/"
EOF

    chmod +x "$CONFIG_DIR/startup.sh"
    echo -e "${COLORS[GREEN]}✓ Startup script created${COLORS[NC]}"
}

# Main configuration menu
main_menu() {
    while true; do
        clear
        echo -e "${COLORS[PURPLE]}╔══════════════════════════════════════════════════════╗${COLORS[NC]}"
        echo -e "${COLORS[PURPLE]}║        🔧 Advanced Configuration Manager 🔧         ║${COLORS[NC]}"
        echo -e "${COLORS[PURPLE]}║           Enhanced Superuser Terminal               ║${COLORS[NC]}"
        echo -e "${COLORS[PURPLE]}╚══════════════════════════════════════════════════════╝${COLORS[NC]}"
        echo ""
        echo -e "${COLORS[CYAN]}Configuration Options:${COLORS[NC]}"
        echo "1. 📝 Create main configuration"
        echo "2. 🌐 Create environment configuration"
        echo "3. 🔗 Create alias configuration"
        echo "4. ⚡ Create advanced functions"
        echo "5. 🚀 Create startup script"
        echo "6. 📋 Create all configurations"
        echo "7. 🔍 View current configuration"
        echo "8. 🧹 Clean configuration directory"
        echo "9. ❌ Exit"
        echo ""
        echo -n "Select option [1-9]: "
        read -r choice
        
        case $choice in
            1)
                create_main_config
                ;;
            2)
                create_environment_config
                ;;
            3)
                create_alias_config
                ;;
            4)
                create_advanced_functions
                ;;
            5)
                create_startup_script
                ;;
            6)
                echo -e "${COLORS[GREEN]}Creating all configurations...${COLORS[NC]}"
                create_main_config
                create_environment_config
                create_alias_config
                create_advanced_functions
                create_startup_script
                echo -e "${COLORS[GREEN]}✅ All configurations created successfully!${COLORS[NC]}"
                ;;
            7)
                echo -e "${COLORS[CYAN]}Current configuration files:${COLORS[NC]}"
                ls -la "$CONFIG_DIR" 2>/dev/null || echo "No configuration files found"
                ;;
            8)
                echo -e "${COLORS[YELLOW]}Cleaning configuration directory...${COLORS[NC]}"
                if [[ -n "${CONFIG_DIR:?}" && -d "$CONFIG_DIR" ]]; then
                    rm -rf "${CONFIG_DIR:?}"/* 2>/dev/null
                    echo -e "${COLORS[GREEN]}✓ Configuration directory cleaned${COLORS[NC]}"
                else
                    echo -e "${COLORS[RED]}✗ Invalid configuration directory${COLORS[NC]}"
                fi
                ;;
            9)
                echo -e "${COLORS[GREEN]}👋 Configuration completed!${COLORS[NC]}"
                break
                ;;
            *)
                echo -e "${COLORS[RED]}❌ Invalid option. Please try again.${COLORS[NC]}"
                sleep 1
                ;;
        esac
        
        if [[ $choice != 9 ]]; then
            echo ""
            read -p "Press Enter to continue..."
        fi
    done
}

# Run main menu if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main_menu
fi