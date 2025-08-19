# Enhanced Superuser Terminal - Command Reference

This document provides a comprehensive reference for all available commands and features in the Enhanced Superuser Terminal.

## 📚 Table of Contents

- [Basic Commands](#basic-commands)
- [Advanced Commands](#advanced-commands)
- [Interactive Mode](#interactive-mode)
- [Tool Launcher](#tool-launcher)
- [Utility Scripts](#utility-scripts)
- [Environment Variables](#environment-variables)
- [Configuration](#configuration)
- [Troubleshooting](#troubleshooting)

## 🚀 Basic Commands

### `check` (Default)
Run comprehensive system check including device compatibility, su binary detection, and system information.

```bash
./Superuser_main check
./Superuser_main  # Default command
```

**Output includes:**
- Device information (brand, model, Android version)
- Architecture and ABI details
- Memory and storage status
- SELinux status
- Root access indicators

### `fix`
Fix su binary permissions with enhanced safety checks and automatic backups.

```bash
./Superuser_main fix
```

**Features:**
- Validates su binaries before modification
- Creates timestamped backups
- Applies correct permissions (6755)
- Sets proper ownership (root:root)
- Provides detailed error reporting

### `backup`
Create enhanced backup of critical system files.

```bash
./Superuser_main backup
```

**Backup includes:**
- All detected su binaries
- System configuration files
- Timestamped backup directory
- Verification of backup integrity

## 🔧 Advanced Commands

### `setup`
Run initial setup with optimizations including directory structure creation and configuration.

```bash
./Superuser_main setup
```

**Actions performed:**
- Creates enhanced directory structure
- Generates configuration files
- Sets up environment profiles
- Installs tool launchers

### `build`
Build enhanced superuser directory structure only.

```bash
./Superuser_main build
```

**Creates:**
- `/data/superuser/bin/` - Executable scripts
- `/data/superuser/etc/` - Configuration files
- `/data/superuser/lib/` - Library files
- `/data/superuser/tmp/` - Temporary files
- `/data/superuser/backups/` - System backups
- `/data/superuser/logs/` - Log files
- `/data/superuser/docs/` - Documentation
- `/data/superuser/test-env/` - Testing environment
- `/data/superuser/scripts/` - Utility scripts
- `/data/superuser/config/` - Additional configurations
- `/data/superuser/tools/` - Additional tools

### `structure`
Create superuser directory structure without additional setup.

```bash
./Superuser_main structure
```

### `install`
Full installation with script deployment and system integration.

```bash
./Superuser_main install
```

**Installation includes:**
- Complete directory structure
- Script installation to `/data/superuser/bin/`
- Configuration file generation
- Environment setup
- Tool launcher creation

## 🔍 Diagnostic Commands

### `benchmark`
Run comprehensive system performance benchmark.

```bash
./Superuser_main benchmark
```

**Tests performed:**
- CPU performance
- Memory usage analysis
- Disk I/O performance
- Execution time measurement

### `network`
Check network connectivity and configuration.

```bash
./Superuser_main network
```

**Checks include:**
- DNS resolution testing
- Network interface status
- Connectivity scoring
- Network configuration analysis

### `security`
Run security audit and vulnerability assessment.

```bash
./Superuser_main security
```

**Security checks:**
- World-writable file detection
- Su binary permission verification
- Suspicious process detection
- Security scoring

### `optimize`
Get system optimization suggestions.

```bash
./Superuser_main optimize
```

**Optimization areas:**
- Memory usage recommendations
- Storage cleanup suggestions
- Performance tuning tips
- System load analysis

### `full`
Run complete diagnostic suite with all checks.

```bash
./Superuser_main full
```

**Includes all:**
- System information check
- Device compatibility check
- Network diagnostics
- Security audit
- Optimization suggestions

## 🎮 Interactive Mode

Launch the interactive menu-driven interface.

```bash
./Superuser_main interactive
./Superuser_main -i
```

### Standard Interactive Mode
```
=== Enhanced Superuser Terminal v1.1-enhanced ===
1. Run full system check
2. Fix su permissions
3. Android command terminal
4. Android user info
5. Create backup
6. View logs
7. Exit
```

### Termux Interactive Mode
Enhanced interface when running in Termux environment:

```
╔══════════════════════════════════════════════════════╗
║     🔐 ENHANCED SUPERUSER TERMINAL - TERMUX 🔐       ║
║                   v1.1-enhanced                      ║
╚══════════════════════════════════════════════════════╝

📱 ANDROID OPERATIONS:
1. 🔍 Full system check
2. 🔧 Fix su permissions
3. 📱 Android terminal
4. 📊 Device information
5. 💾 Create backup

🛠️ TERMUX TOOLS:
6. 🖥️ Launch GUI (VNC)
7. 🔧 Termux tools menu
8. 📝 View logs
9. ⚙️ System configuration

0. ❌ Exit
```

## 🛠️ Tool Launcher

Use the integrated tool launcher for quick access to commands.

```bash
superuser-tool <command> [options]
```

### Available Commands:
- `check` (c) - Run system checks
- `fix` (f) - Fix permissions
- `backup` (b) - Create backup
- `interactive` (i) - Launch interactive mode
- `benchmark` - Run performance tests
- `security` - Security audit
- `network` - Network diagnostics
- `help` (h) - Show help

### Examples:
```bash
superuser-tool check        # Quick system check
superuser-tool f            # Fix permissions (short form)
superuser-tool interactive  # Launch interactive mode
superuser-tool help         # Show available commands
```

## 🔧 Utility Scripts

### superuser-utils.sh
Quick utility functions for common tasks.

```bash
./superuser-utils.sh [command]
```

**Available commands:**
- `status` - Quick system status
- `check` - Quick su binary check
- `env` - Setup environment
- `backup` - Backup su binaries
- `help` - Show help

### Examples:
```bash
./superuser-utils.sh status   # Show quick system status
./superuser-utils.sh check    # Check su binaries
./superuser-utils.sh env      # Setup environment
```

## 🌐 Environment Variables

### Configuration Variables
```bash
export PARALLEL_JOBS=4              # Number of parallel jobs
export SKIP_ROOT_CHECK=0            # Skip root check (testing)
export DRY_RUN=0                    # Dry run mode
export DEBUG=1                      # Enable debug logging
export GUI_MODE=1                   # GUI mode for external interfaces
```

### Termux Variables
```bash
export TERMUX_ENV=1                 # Termux environment detected
export PREFIX=/data/data/com.termux/files/usr
export TERMUX_HOME=/data/data/com.termux/files/home
export TERMUX_APP_PACKAGE=com.termux
```

### Superuser Variables
```bash
export SUPERUSER_HOME=/data/superuser
export SUPERUSER_VERSION=1.1-enhanced
export ANDROID_DATA=/data
export ANDROID_ROOT=/system
```

## ⚙️ Configuration

### Profile Configuration
Located at `/data/superuser/etc/profile`

**Includes:**
- PATH configuration
- Environment variables
- Useful aliases
- Custom functions

### Useful Aliases
```bash
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias su-check='check_accessibility'
alias su-fix='fix_su_permissions'
alias su-backup='backup_critical_files'
alias su-logs='tail -f /data/superuser/logs/superuser.log'
```

### Custom Functions
```bash
su_status()    # Show superuser status
su-status      # Quick system status
su-check       # Quick su binary check
su-env         # Setup environment
```

## 🔨 GUI Mode Commands

For external GUI interfaces, use these special commands:

```bash
./Superuser_main gui-status      # Get system status
./Superuser_main gui-dependencies # Check dependencies
./Superuser_main gui-system-info  # Get system information
```

**Output format:**
- `GUI_STATUS:` - Status information
- `GUI_DEP:` - Dependency information
- `GUI_SYSINFO:` - System information
- `GUI_LOG:` - Log messages

## 📱 Android Integration

### ADB Commands
```bash
# Start Android command terminal
./Superuser_main android-terminal

# Get Android user information
./Superuser_main android-info
```

### Termux Integration
Automatic detection and integration with Termux environment:
- Enhanced interactive mode
- Termux API integration
- Storage access management
- Package management integration

## 🚨 Troubleshooting Commands

### Debug Mode
```bash
export DEBUG=1
./Superuser_main check
```

### View Logs
```bash
# View recent logs
tail -20 /data/superuser/logs/superuser.log

# Follow logs in real-time
tail -f /data/superuser/logs/superuser.log

# View all logs
cat /data/superuser/logs/superuser.log
```

### Test Mode
```bash
export DRY_RUN=1
./Superuser_main fix    # Test without making changes
```

### Force Skip Root Check
```bash
export SKIP_ROOT_CHECK=1
./Superuser_main check  # Run without root requirements
```

## 🔧 Command Combinations

### Quick Setup and Check
```bash
./Superuser_main setup && ./Superuser_main check
```

### Backup Before Fix
```bash
./Superuser_main backup && ./Superuser_main fix
```

### Complete System Analysis
```bash
./Superuser_main full > system_report.txt 2>&1
```

### Performance Monitoring
```bash
./Superuser_main benchmark && ./Superuser_main optimize
```

## 📊 Return Codes

- `0` - Success
- `1` - General error
- `2` - Permission denied
- `3` - File not found
- `4` - Command not found
- `5` - Network error

## 🆘 Getting Help

### Command Help
```bash
./Superuser_main help
./Superuser_main --help
./Superuser_main -h
```

### Tool Launcher Help
```bash
superuser-tool help
superuser-tool h
```

### Utility Help
```bash
./superuser-utils.sh help
```

### Interactive Help
In interactive mode, each option provides detailed information about its function.

---

**Note:** All commands should be run with appropriate permissions. Most commands require root access for full functionality.