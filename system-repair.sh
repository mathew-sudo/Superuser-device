#!/bin/bash
# System Repair Utility for Enhanced Superuser Terminal
# Version: 1.1-enhanced

# Source the main script for colors and functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "$SCRIPT_DIR/Superuser_main" ]]; then
    source "$SCRIPT_DIR/Superuser_main" 2>/dev/null || true
fi

# Color definitions (fallback if not sourced)
if [[ -z "${COLORS[RED]:-}" ]]; then
    declare -A COLORS=(
        [RED]='\033[0;31m'
        [GREEN]='\033[0;32m'
        [CYAN]='\033[0;36m'
        [YELLOW]='\033[1;33m'
        [BLUE]='\033[0;34m'
        [PURPLE]='\033[0;35m'
        [NC]='\033[0m'
    )
fi

# Repair configuration
REPAIR_LOG="/data/superuser/logs/repair.log"
BACKUP_DIR="/data/superuser/backups/repair_$(date +%Y%m%d_%H%M%S)"

# Ensure we're running as root
check_root() {
    if [[ "$(id -u)" -ne 0 ]]; then
        echo -e "${COLORS[RED]}Error: System repair must be run as root${COLORS[NC]}"
        exit 1
    fi
}

# Logging function for repair operations
repair_log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "[$timestamp] [$level] $message" | tee -a "$REPAIR_LOG" 2>/dev/null || true
    
    case "$level" in
        "ERROR")
            echo -e "${COLORS[RED]}[$level] $message${COLORS[NC]}"
            ;;
        "WARN")
            echo -e "${COLORS[YELLOW]}[$level] $message${COLORS[NC]}"
            ;;
        "SUCCESS")
            echo -e "${COLORS[GREEN]}[$level] $message${COLORS[NC]}"
            ;;
        *)
            echo -e "${COLORS[CYAN]}[$level] $message${COLORS[NC]}"
            ;;
    esac
}

# Create backup before repairs
create_repair_backup() {
    repair_log "INFO" "Creating backup before repairs..."
    mkdir -p "$BACKUP_DIR" 2>/dev/null || {
        repair_log "ERROR" "Failed to create backup directory"
        return 1
    }
    
    # Backup critical files
    local files_to_backup=(
        "/system/bin/su"
        "/system/xbin/su"
        "/sbin/su"
        "/su/bin/su"
        "/data/superuser/etc/profile"
    )
    
    for file in "${files_to_backup[@]}"; do
        if [[ -f "$file" ]]; then
            local backup_path="$BACKUP_DIR$(dirname "$file")"
            mkdir -p "$backup_path" 2>/dev/null
            cp "$file" "$backup_path/" 2>/dev/null && {
                repair_log "INFO" "Backed up: $file"
            } || {
                repair_log "WARN" "Failed to backup: $file"
            }
        fi
    done
    
    repair_log "SUCCESS" "Backup created at: $BACKUP_DIR"
}

# Fix common permission issues
fix_permissions() {
    repair_log "INFO" "Starting permission repair..."
    local fixed_count=0
    
    # Fix su binary permissions
    local su_paths=(
        "/system/bin/su" "/system/xbin/su" "/sbin/su" "/su/bin/su"
        "/su/xbin/su" "/system/sbin/su" "/magisk/.core/bin/su"
    )
    
    for su_path in "${su_paths[@]}"; do
        if [[ -f "$su_path" ]]; then
            # Check current permissions
            local current_perms
            current_perms=$(stat -c %a "$su_path" 2>/dev/null || echo "000")
            
            if [[ "$current_perms" != "6755" ]]; then
                chmod 6755 "$su_path" 2>/dev/null && {
                    repair_log "SUCCESS" "Fixed permissions for $su_path ($current_perms -> 6755)"
                    ((fixed_count++))
                } || {
                    repair_log "ERROR" "Failed to fix permissions for $su_path"
                }
            else
                repair_log "INFO" "$su_path already has correct permissions"
            fi
            
            # Check ownership
            local current_owner
            current_owner=$(stat -c "%U:%G" "$su_path" 2>/dev/null || echo "unknown:unknown")
            
            if [[ "$current_owner" != "root:root" ]]; then
                chown root:root "$su_path" 2>/dev/null && {
                    repair_log "SUCCESS" "Fixed ownership for $su_path ($current_owner -> root:root)"
                    ((fixed_count++))
                } || {
                    repair_log "ERROR" "Failed to fix ownership for $su_path"
                }
            else
                repair_log "INFO" "$su_path already has correct ownership"
            fi
        fi
    done
    
    # Fix superuser directory permissions
    if [[ -d "/data/superuser" ]]; then
        local dir_perms
        dir_perms=$(stat -c %a "/data/superuser" 2>/dev/null || echo "000")
        
        if [[ "$dir_perms" != "755" ]]; then
            chmod 755 "/data/superuser" 2>/dev/null && {
                repair_log "SUCCESS" "Fixed superuser directory permissions"
                ((fixed_count++))
            } || {
                repair_log "ERROR" "Failed to fix superuser directory permissions"
            }
        fi
        
        # Fix subdirectory permissions
        find "/data/superuser" -type d -exec chmod 755 {} \; 2>/dev/null && {
            repair_log "SUCCESS" "Fixed subdirectory permissions"
        } || {
            repair_log "WARN" "Some subdirectory permissions may not be fixed"
        }
    fi
    
    repair_log "INFO" "Permission repair completed. Fixed: $fixed_count items"
    return 0
}

# Fix corrupted configuration files
fix_configuration() {
    repair_log "INFO" "Starting configuration repair..."
    
    # Recreate superuser profile if missing or corrupted
    local profile_path="/data/superuser/etc/profile"
    local needs_fix=false
    
    if [[ ! -f "$profile_path" ]]; then
        repair_log "WARN" "Superuser profile missing"
        needs_fix=true
    elif ! grep -q "SUPERUSER_HOME" "$profile_path" 2>/dev/null; then
        repair_log "WARN" "Superuser profile appears corrupted"
        needs_fix=true
    fi
    
    if [[ "$needs_fix" == true ]]; then
        mkdir -p "$(dirname "$profile_path")" 2>/dev/null
        cat > "$profile_path" << 'EOF'
#!/system/bin/sh
# Enhanced Superuser Terminal Profile
# Version: 1.1-enhanced (Auto-repaired)

export PATH="/data/superuser/bin:/system/bin:/system/xbin:$PATH"
export SUPERUSER_HOME="/data/superuser"
export SUPERUSER_VERSION="1.1-enhanced"
export ANDROID_DATA="/data"
export ANDROID_ROOT="/system"

# Enhanced prompt
PS1='[\[\033[1;32m\]root\[\033[0m\]@\[\033[1;34m\]superuser\[\033[0m\]:\[\033[1;36m\]\w\[\033[0m\]]# '

# Useful aliases
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias grep='grep --color=auto'
alias su-repair='system-repair.sh'

echo "Enhanced Superuser Terminal Profile Loaded (Auto-repaired)"
EOF
        
        chmod 644 "$profile_path" 2>/dev/null && {
            repair_log "SUCCESS" "Recreated superuser profile"
        } || {
            repair_log "ERROR" "Failed to create superuser profile"
        }
    else
        repair_log "INFO" "Superuser profile is intact"
    fi
    
    repair_log "INFO" "Configuration repair completed"
}

# Fix SELinux issues
fix_selinux() {
    repair_log "INFO" "Checking SELinux configuration..."
    
    if command -v getenforce >/dev/null 2>&1; then
        local selinux_status
        selinux_status=$(getenforce 2>/dev/null || echo "Unknown")
        
        case "$selinux_status" in
            "Enforcing")
                repair_log "WARN" "SELinux is enforcing - this may block su operations"
                
                # Offer to set to permissive (temporary)
                read -p "Set SELinux to permissive mode temporarily? (y/N): " -r
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    setenforce 0 2>/dev/null && {
                        repair_log "SUCCESS" "SELinux set to permissive mode (temporary)"
                        repair_log "WARN" "This change is temporary and will revert on reboot"
                    } || {
                        repair_log "ERROR" "Failed to change SELinux mode"
                    }
                fi
                ;;
            "Permissive")
                repair_log "INFO" "SELinux is in permissive mode (good for su operations)"
                ;;
            "Disabled")
                repair_log "INFO" "SELinux is disabled"
                ;;
            *)
                repair_log "WARN" "Unknown SELinux status: $selinux_status"
                ;;
        esac
    else
        repair_log "INFO" "SELinux tools not available"
    fi
}

# Fix file system issues
fix_filesystem() {
    repair_log "INFO" "Checking file system issues..."
    
    # Check if /system is mounted read-only
    if mount | grep -q "/system.*ro"; then
        repair_log "WARN" "/system is mounted read-only"
        
        # Attempt to remount as read-write
        read -p "Attempt to remount /system as read-write? (y/N): " -r
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            mount -o remount,rw /system 2>/dev/null && {
                repair_log "SUCCESS" "/system remounted as read-write"
                repair_log "WARN" "Remember to remount as read-only when done: mount -o remount,ro /system"
            } || {
                repair_log "ERROR" "Failed to remount /system"
            }
        fi
    else
        repair_log "INFO" "/system mount status is OK"
    fi
    
    # Check disk space
    local data_usage
    data_usage=$(df /data 2>/dev/null | tail -1 | awk '{print $5}' | sed 's/%//' || echo "0")
    
    if [[ "$data_usage" -gt 95 ]]; then
        repair_log "ERROR" "Critical: /data partition is ${data_usage}% full"
        repair_log "INFO" "Consider cleaning up files to free space"
    elif [[ "$data_usage" -gt 85 ]]; then
        repair_log "WARN" "/data partition is ${data_usage}% full"
    else
        repair_log "INFO" "/data partition usage is OK (${data_usage}%)"
    fi
}

# Fix broken symlinks
fix_symlinks() {
    repair_log "INFO" "Checking for broken symlinks..."
    
    local common_paths=(
        "/system/bin" "/system/xbin" "/sbin" "/su/bin"
    )
    
    for path in "${common_paths[@]}"; do
        if [[ -d "$path" ]]; then
            local broken_links
            broken_links=$(find "$path" -type l ! -exec test -e {} \; -print 2>/dev/null | wc -l)
            
            if [[ "$broken_links" -gt 0 ]]; then
                repair_log "WARN" "Found $broken_links broken symlinks in $path"
                
                # Remove broken symlinks
                find "$path" -type l ! -exec test -e {} \; -delete 2>/dev/null && {
                    repair_log "SUCCESS" "Removed broken symlinks from $path"
                } || {
                    repair_log "ERROR" "Failed to remove broken symlinks from $path"
                }
            else
                repair_log "INFO" "No broken symlinks in $path"
            fi
        fi
    done
}

# Comprehensive system repair
repair_all() {
    echo -e "${COLORS[CYAN]}╔══════════════════════════════════════════════════════╗${COLORS[NC]}"
    echo -e "${COLORS[CYAN]}║            System Repair Utility v1.1               ║${COLORS[NC]}"
    echo -e "${COLORS[CYAN]}╚══════════════════════════════════════════════════════╝${COLORS[NC]}"
    echo ""
    
    repair_log "INFO" "Starting comprehensive system repair..."
    
    # Create backup
    create_repair_backup || {
        repair_log "ERROR" "Backup creation failed - aborting repair"
        return 1
    }
    
    # Run all repair functions
    echo -e "${COLORS[YELLOW]}Phase 1: Permission Repair${COLORS[NC]}"
    fix_permissions
    
    echo -e "${COLORS[YELLOW]}Phase 2: Configuration Repair${COLORS[NC]}"
    fix_configuration
    
    echo -e "${COLORS[YELLOW]}Phase 3: SELinux Check${COLORS[NC]}"
    fix_selinux
    
    echo -e "${COLORS[YELLOW]}Phase 4: File System Check${COLORS[NC]}"
    fix_filesystem
    
    echo -e "${COLORS[YELLOW]}Phase 5: Symlink Repair${COLORS[NC]}"
    fix_symlinks
    
    repair_log "SUCCESS" "System repair completed"
    echo ""
    echo -e "${COLORS[GREEN]}✓ System repair completed successfully${COLORS[NC]}"
    echo -e "${COLORS[BLUE]}Backup created at: $BACKUP_DIR${COLORS[NC]}"
    echo -e "${COLORS[BLUE]}Repair log: $REPAIR_LOG${COLORS[NC]}"
}

# Interactive repair menu
interactive_repair() {
    while true; do
        clear
        echo -e "${COLORS[PURPLE]}╔══════════════════════════════════════════════════════╗${COLORS[NC]}"
        echo -e "${COLORS[PURPLE]}║               Interactive System Repair             ║${COLORS[NC]}"
        echo -e "${COLORS[PURPLE]}╚══════════════════════════════════════════════════════╝${COLORS[NC]}"
        echo ""
        echo "1. 🔧 Fix Permissions"
        echo "2. ⚙️  Fix Configuration"
        echo "3. 🛡️  Check SELinux"
        echo "4. 💾 Check File System"
        echo "5. 🔗 Fix Symlinks"
        echo "6. 🚀 Run All Repairs"
        echo "7. 📋 View Repair Log"
        echo "8. 💾 Create Backup Only"
        echo "9. ❌ Exit"
        echo ""
        echo -n "Select option [1-9]: "
        read -r choice
        
        case $choice in
            1)
                echo -e "${COLORS[CYAN]}Running permission repair...${COLORS[NC]}"
                create_repair_backup && fix_permissions
                ;;
            2)
                echo -e "${COLORS[CYAN]}Running configuration repair...${COLORS[NC]}"
                create_repair_backup && fix_configuration
                ;;
            3)
                echo -e "${COLORS[CYAN]}Checking SELinux...${COLORS[NC]}"
                fix_selinux
                ;;
            4)
                echo -e "${COLORS[CYAN]}Checking file system...${COLORS[NC]}"
                fix_filesystem
                ;;
            5)
                echo -e "${COLORS[CYAN]}Fixing symlinks...${COLORS[NC]}"
                fix_symlinks
                ;;
            6)
                repair_all
                ;;
            7)
                echo -e "${COLORS[CYAN]}Recent repair log entries:${COLORS[NC]}"
                tail -20 "$REPAIR_LOG" 2>/dev/null || echo "No repair log found"
                ;;
            8)
                echo -e "${COLORS[CYAN]}Creating backup...${COLORS[NC]}"
                create_repair_backup
                ;;
            9)
                echo -e "${COLORS[GREEN]}Exiting repair utility${COLORS[NC]}"
                break
                ;;
            *)
                echo -e "${COLORS[RED]}Invalid option. Please try again.${COLORS[NC]}"
                sleep 1
                ;;
        esac
        
        if [[ $choice != 9 ]]; then
            echo ""
            read -p "Press Enter to continue..."
        fi
    done
}

# Main function
main() {
    check_root
    
    # Ensure log directory exists
    mkdir -p "$(dirname "$REPAIR_LOG")" 2>/dev/null
    
    case "${1:-interactive}" in
        "all"|"full")
            repair_all
            ;;
        "permissions"|"perms")
            create_repair_backup && fix_permissions
            ;;
        "config"|"configuration")
            create_repair_backup && fix_configuration
            ;;
        "selinux")
            fix_selinux
            ;;
        "filesystem"|"fs")
            fix_filesystem
            ;;
        "symlinks"|"links")
            fix_symlinks
            ;;
        "backup")
            create_repair_backup
            ;;
        "log")
            tail -50 "$REPAIR_LOG" 2>/dev/null || echo "No repair log found"
            ;;
        "interactive"|"i")
            interactive_repair
            ;;
        "help"|"--help"|"-h")
            echo "System Repair Utility for Enhanced Superuser Terminal"
            echo "Usage: $0 [command]"
            echo ""
            echo "Commands:"
            echo "  all           - Run all repairs"
            echo "  permissions   - Fix permission issues"
            echo "  config        - Fix configuration issues"
            echo "  selinux       - Check SELinux issues"
            echo "  filesystem    - Check file system issues"
            echo "  symlinks      - Fix broken symlinks"
            echo "  backup        - Create backup only"
            echo "  log           - View repair log"
            echo "  interactive   - Launch interactive menu (default)"
            echo "  help          - Show this help"
            ;;
        *)
            echo "Unknown command: $1"
            echo "Use '$0 help' for available commands"
            exit 1
            ;;
    esac
}

# Execute main function if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi