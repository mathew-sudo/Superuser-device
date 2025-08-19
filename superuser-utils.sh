#!/bin/bash
# Superuser Utilities Script
# Version: 1.1-enhanced
# Additional utility functions for the Enhanced Superuser Terminal

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

# Quick system status check
quick_status() {
    echo -e "${COLORS[CYAN]}=== Quick System Status ===${COLORS[NC]}"
    echo "Root: $(test "$(id -u)" -eq 0 && echo "✓ Active" || echo "✗ Not active")"
    echo "Superuser Dir: $(test -d /data/superuser && echo "✓ Present" || echo "✗ Missing")"
    echo "Memory: $(awk '/MemAvailable/ {printf "%.1f MB", $2/1024}' /proc/meminfo 2>/dev/null || echo "Unknown")"
    echo "Storage: $(df /data 2>/dev/null | tail -1 | awk '{print $5}' | sed 's/%/ used/' || echo "Unknown")"
    echo "Load: $(cut -d' ' -f1 /proc/loadavg 2>/dev/null || echo "Unknown")"
}

# Fast su binary check
quick_su_check() {
    echo -e "${COLORS[CYAN]}=== Quick Su Binary Check ===${COLORS[NC]}"
    local found=0
    local working=0
    
    for su_path in "/system/bin/su" "/system/xbin/su" "/su/bin/su"; do
        if [[ -f "$su_path" ]]; then
            ((found++))
            local perms
            perms=$(stat -c %a "$su_path" 2>/dev/null)
            if [[ "$perms" == "6755" ]]; then
                echo -e "${COLORS[GREEN]}✓${COLORS[NC]} $su_path ($perms)"
                ((working++))
            else
                echo -e "${COLORS[YELLOW]}!${COLORS[NC]} $su_path ($perms - needs fix)"
            fi
        fi
    done
    
    echo "Summary: $found found, $working properly configured"
}

# Environment setup
setup_environment() {
    echo -e "${COLORS[CYAN]}Setting up superuser environment...${COLORS[NC]}"
    
    # Source superuser profile if available
    if [[ -f "/data/superuser/etc/profile" ]]; then
        source /data/superuser/etc/profile
        echo -e "${COLORS[GREEN]}✓ Superuser profile loaded${COLORS[NC]}"
    fi
    
    # Add to PATH if not already there
    if [[ ":$PATH:" != *":/data/superuser/bin:"* ]]; then
        export PATH="/data/superuser/bin:$PATH"
        echo -e "${COLORS[GREEN]}✓ Superuser bin added to PATH${COLORS[NC]}"
    fi
    
    # Set useful aliases
    alias su-status='quick_status'
    alias su-check='quick_su_check'
    alias su-env='setup_environment'
}

# Simple backup function
backup_su_binaries() {
    local backup_dir
    backup_dir="/data/superuser/backups/$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    
    echo -e "${COLORS[CYAN]}Creating backup in $backup_dir...${COLORS[NC]}"
    
    for su_path in "/system/bin/su" "/system/xbin/su" "/su/bin/su"; do
        if [[ -f "$su_path" ]]; then
            cp "$su_path" "$backup_dir/" && \
            echo -e "${COLORS[GREEN]}✓ Backed up $su_path${COLORS[NC]}" || \
            echo -e "${COLORS[RED]}✗ Failed to backup $su_path${COLORS[NC]}"
        fi
    done
}

# Show usage
show_usage() {
    echo "Superuser Utilities v1.1-enhanced"
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  status      - Quick system status"
    echo "  check       - Quick su binary check"
    echo "  env         - Setup environment"
    echo "  backup      - Backup su binaries"
    echo "  help        - Show this help"
}

# Main function
main() {
    case "${1:-status}" in
        "status")
            quick_status
            ;;
        "check")
            quick_su_check
            ;;
        "env")
            setup_environment
            ;;
        "backup")
            backup_su_binaries
            ;;
        "help")
            show_usage
            ;;
        *)
            show_usage
            ;;
    esac
}

# Execute if run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi