#!/bin/bash
# Advanced Logging System for Enhanced Superuser Terminal
# Version: 1.1-enhanced

# Color definitions for log levels
declare -A LOG_COLORS=(
    [DEBUG]='\033[0;37m'    # White
    [INFO]='\033[0;32m'     # Green
    [WARN]='\033[1;33m'     # Yellow
    [ERROR]='\033[0;31m'    # Red
    [FATAL]='\033[1;31m'    # Bold Red
    [PERF]='\033[0;36m'     # Cyan
    [SECURITY]='\033[0;35m' # Purple
    [NC]='\033[0m'          # No Color
)

# Log configuration
LOG_BASE_DIR="/data/superuser/logs"
LOG_MAX_SIZE="10M"
LOG_MAX_FILES=20
LOG_RETENTION_DAYS=30

# Ensure log directory exists
setup_logging() {
    mkdir -p "$LOG_BASE_DIR" 2>/dev/null || {
        echo "Warning: Could not create log directory $LOG_BASE_DIR" >&2
        LOG_BASE_DIR="/tmp/superuser_logs"
        mkdir -p "$LOG_BASE_DIR" 2>/dev/null || {
            echo "Error: Could not create fallback log directory" >&2
            return 1
        }
    }
    
    # Create log files with proper structure
    touch "$LOG_BASE_DIR/superuser.log" 2>/dev/null
    touch "$LOG_BASE_DIR/performance.log" 2>/dev/null
    touch "$LOG_BASE_DIR/security.log" 2>/dev/null
    touch "$LOG_BASE_DIR/error.log" 2>/dev/null
    
    # Set proper permissions
    chmod 644 "$LOG_BASE_DIR"/*.log 2>/dev/null || true
}

# Advanced logging function with multiple outputs
advanced_log() {
    local level="${1:-INFO}"
    shift || true
    local message="${*:-No message provided}"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S' 2>/dev/null || echo "unknown-time")
    local caller_info=""
    
    # Get caller information
    if [[ "${BASH_SOURCE[2]:-}" ]]; then
        local caller_file="${BASH_SOURCE[2]##*/}"
        local caller_line="${BASH_LINENO[1]}"
        local caller_func="${FUNCNAME[2]:-main}"
        caller_info="[$caller_file:$caller_line:$caller_func]"
    fi
    
    # Format log entry
    local log_entry="[$timestamp] [$level] $caller_info $message"
    local colored_entry="${LOG_COLORS[$level]}$log_entry${LOG_COLORS[NC]}"
    
    # Output to console with colors (if terminal supports it)
    if [[ -t 1 ]] && [[ "${ENABLE_COLORS:-1}" == "1" ]]; then
        echo -e "$colored_entry"
    else
        echo "$log_entry"
    fi
    
    # Write to main log file
    echo "$log_entry" >> "$LOG_BASE_DIR/superuser.log" 2>/dev/null || {
        echo "$log_entry" >&2
    }
    
    # Write to specific log files based on level
    case "$level" in
        "PERF")
            echo "$log_entry" >> "$LOG_BASE_DIR/performance.log" 2>/dev/null
            ;;
        "SECURITY")
            echo "$log_entry" >> "$LOG_BASE_DIR/security.log" 2>/dev/null
            ;;
        "ERROR"|"FATAL")
            echo "$log_entry" >> "$LOG_BASE_DIR/error.log" 2>/dev/null
            ;;
    esac
    
    # Rotate logs if needed
    rotate_logs_if_needed
}

# Log rotation function
rotate_logs_if_needed() {
    for log_file in "$LOG_BASE_DIR"/*.log; do
        if [[ -f "$log_file" ]]; then
            local file_size
            file_size=$(stat -c%s "$log_file" 2>/dev/null || echo "0")
            
            # Check if file is larger than max size (10MB = 10485760 bytes)
            if [[ "$file_size" -gt 10485760 ]]; then
                rotate_log "$log_file"
            fi
        fi
    done
    
    # Clean old rotated logs
    cleanup_old_logs
}

# Rotate individual log file
rotate_log() {
    local log_file="$1"
    local base_name="${log_file%.log}"
    local timestamp
    timestamp=$(date '+%Y%m%d_%H%M%S')
    
    # Move current log to rotated version
    mv "$log_file" "${base_name}_${timestamp}.log" 2>/dev/null || {
        echo "Warning: Could not rotate log file $log_file" >&2
        return 1
    }
    
    # Create new empty log file
    touch "$log_file" 2>/dev/null
    chmod 644 "$log_file" 2>/dev/null || true
    
    # Compress rotated log
    if command -v gzip >/dev/null 2>&1; then
        gzip "${base_name}_${timestamp}.log" 2>/dev/null &
    fi
}

# Clean up old log files
cleanup_old_logs() {
    # Remove logs older than retention period
    find "$LOG_BASE_DIR" -name "*.log.*" -type f -mtime +$LOG_RETENTION_DAYS -delete 2>/dev/null || true
    
    # Keep only max number of rotated files
    for log_type in "superuser" "performance" "security" "error"; do
        local count
        count=$(ls -1 "$LOG_BASE_DIR/${log_type}_"*.log* 2>/dev/null | wc -l)
        
        if [[ "$count" -gt "$LOG_MAX_FILES" ]]; then
            local excess=$((count - LOG_MAX_FILES))
            ls -1t "$LOG_BASE_DIR/${log_type}_"*.log* 2>/dev/null | tail -$excess | xargs rm -f 2>/dev/null || true
        fi
    done
}

# Performance logging
log_performance() {
    local metric="$1"
    local value="$2"
    local unit="${3:-}"
    advanced_log "PERF" "METRIC: $metric = $value$unit"
}

# Security logging
log_security() {
    local event="$1"
    shift
    local details="$*"
    advanced_log "SECURITY" "EVENT: $event - $details"
}

# Error logging with stack trace
log_error_with_trace() {
    local error_msg="$1"
    advanced_log "ERROR" "$error_msg"
    
    # Add stack trace
    local i=1
    while [[ "${BASH_SOURCE[$i]:-}" ]]; do
        local file="${BASH_SOURCE[$i]##*/}"
        local line="${BASH_LINENO[$((i-1))]}"
        local func="${FUNCNAME[$i]:-main}"
        advanced_log "ERROR" "  at $func ($file:$line)"
        ((i++))
    done
}

# Log system information
log_system_info() {
    advanced_log "INFO" "System Info Logging Started"
    advanced_log "INFO" "Hostname: $(hostname 2>/dev/null || echo 'unknown')"
    advanced_log "INFO" "Kernel: $(uname -r 2>/dev/null || echo 'unknown')"
    advanced_log "INFO" "Architecture: $(uname -m 2>/dev/null || echo 'unknown')"
    
    if [[ -f "/proc/meminfo" ]]; then
        local total_mem
        total_mem=$(awk '/MemTotal/ {print int($2/1024) " MB"}' /proc/meminfo)
        advanced_log "INFO" "Total Memory: $total_mem"
    fi
    
    if command -v getprop >/dev/null 2>&1; then
        local android_ver
        android_ver=$(getprop ro.build.version.release 2>/dev/null || echo "unknown")
        advanced_log "INFO" "Android Version: $android_ver"
    fi
}

# Log viewer function
view_logs() {
    local log_type="${1:-all}"
    local lines="${2:-50}"
    
    case "$log_type" in
        "main"|"all")
            echo -e "\033[1;36m=== Main Log (last $lines lines) ===\033[0m"
            tail -$lines "$LOG_BASE_DIR/superuser.log" 2>/dev/null || echo "No main log found"
            ;;
        "performance"|"perf")
            echo -e "\033[1;36m=== Performance Log (last $lines lines) ===\033[0m"
            tail -$lines "$LOG_BASE_DIR/performance.log" 2>/dev/null || echo "No performance log found"
            ;;
        "security")
            echo -e "\033[1;36m=== Security Log (last $lines lines) ===\033[0m"
            tail -$lines "$LOG_BASE_DIR/security.log" 2>/dev/null || echo "No security log found"
            ;;
        "error")
            echo -e "\033[1;36m=== Error Log (last $lines lines) ===\033[0m"
            tail -$lines "$LOG_BASE_DIR/error.log" 2>/dev/null || echo "No error log found"
            ;;
        "summary")
            echo -e "\033[1;36m=== Log Summary ===\033[0m"
            for log_file in "$LOG_BASE_DIR"/*.log; do
                if [[ -f "$log_file" ]]; then
                    local count
                    count=$(wc -l < "$log_file" 2>/dev/null || echo "0")
                    local size
                    size=$(du -h "$log_file" 2>/dev/null | cut -f1 || echo "0B")
                    echo "$(basename "$log_file"): $count lines, $size"
                fi
            done
            ;;
        *)
            echo "Usage: view_logs [main|performance|security|error|summary] [lines]"
            return 1
            ;;
    esac
}

# Log search function
search_logs() {
    local pattern="$1"
    local log_type="${2:-all}"
    
    if [[ -z "$pattern" ]]; then
        echo "Usage: search_logs <pattern> [log_type]"
        return 1
    fi
    
    echo -e "\033[1;36m=== Searching for: '$pattern' ===\033[0m"
    
    case "$log_type" in
        "all")
            grep -r --color=auto "$pattern" "$LOG_BASE_DIR"/*.log 2>/dev/null || echo "No matches found"
            ;;
        *)
            local log_file="$LOG_BASE_DIR/${log_type}.log"
            if [[ -f "$log_file" ]]; then
                grep --color=auto "$pattern" "$log_file" 2>/dev/null || echo "No matches found"
            else
                echo "Log file not found: $log_file"
            fi
            ;;
    esac
}

# Export log functions for use in main script
export -f advanced_log
export -f log_performance
export -f log_security
export -f log_error_with_trace
export -f log_system_info
export -f view_logs
export -f search_logs
export -f setup_logging

# Initialize logging if script is sourced
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    setup_logging
fi

# Main function for standalone execution
main() {
    setup_logging
    
    case "${1:-help}" in
        "setup")
            setup_logging
            echo "Logging system initialized in $LOG_BASE_DIR"
            ;;
        "view")
            view_logs "$2" "$3"
            ;;
        "search")
            search_logs "$2" "$3"
            ;;
        "test")
            echo "Testing logging system..."
            advanced_log "INFO" "Test info message"
            advanced_log "WARN" "Test warning message"
            advanced_log "ERROR" "Test error message"
            log_performance "test_metric" "100" "ms"
            log_security "test_event" "Testing security logging"
            echo "Test completed. Check logs with: $0 view"
            ;;
        "clean")
            echo "Cleaning old logs..."
            cleanup_old_logs
            echo "Cleanup completed"
            ;;
        "help"|*)
            echo "Advanced Logging System for Enhanced Superuser Terminal"
            echo "Usage: $0 [command] [options]"
            echo ""
            echo "Commands:"
            echo "  setup           - Initialize logging system"
            echo "  view [type] [lines] - View logs (main/performance/security/error/summary)"
            echo "  search <pattern> [type] - Search in logs"
            echo "  test            - Test logging functionality"
            echo "  clean           - Clean old log files"
            echo "  help            - Show this help"
            echo ""
            echo "Examples:"
            echo "  $0 view main 100     # View last 100 lines of main log"
            echo "  $0 search ERROR      # Search for ERROR in all logs"
            echo "  $0 view summary      # Show log file summary"
            ;;
    esac
}

# Execute main function if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi