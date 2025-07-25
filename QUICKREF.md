# 🚀 Enhanced Superuser Terminal - Quick Reference

## 🏃 Quick Start
```bash
# Quick installation
chmod +x install.sh && su -c ./install.sh

# Basic usage
./Superuser_main check      # System check
./Superuser_main fix        # Fix permissions
./Superuser_main interactive # Interactive mode
```

## 📋 Essential Commands

| Command | Description | Example |
|---------|-------------|---------|
| `check` | System check (default) | `./Superuser_main` |
| `fix` | Fix su permissions | `./Superuser_main fix` |
| `backup` | Create backup | `./Superuser_main backup` |
| `interactive` | Interactive mode | `./Superuser_main -i` |
| `setup` | Initial setup | `./Superuser_main setup` |
| `full` | Complete diagnostics | `./Superuser_main full` |

## 🛠️ Tool Launcher

```bash
superuser-tool check        # Quick system check
superuser-tool fix          # Fix permissions
superuser-tool interactive  # Interactive mode
superuser-tool help         # Show help
```

## 🔧 Utility Scripts

```bash
./superuser-utils.sh status  # Quick status
./superuser-utils.sh check   # Su binary check
./superuser-utils.sh env     # Setup environment
```

## 📱 Android Commands

```bash
./Superuser_main android-terminal  # ADB shell
./Superuser_main android-info      # User info
./Superuser_main android           # Dev structure
```

## 🔍 Diagnostic Commands

```bash
./Superuser_main benchmark  # Performance test
./Superuser_main network    # Network check
./Superuser_main security   # Security audit
./Superuser_main optimize   # Optimization tips
```

## 🆘 Help & Info

```bash
./Superuser_main help       # Detailed help
./Superuser_main version    # Version info
./Superuser_main status     # Quick status
./Superuser_main env        # Environment info
./Superuser_main logs       # View logs
```

## 🎮 Interactive Mode Options

### Standard Mode:
1. Run full system check
2. Fix su permissions  
3. Android command terminal
4. Android user info
5. Create backup
6. View logs
7. Exit

### Termux Mode:
- Enhanced UI with emojis
- VNC server support
- Termux tools integration
- Storage management
- Package management

## 🌐 Environment Variables

```bash
export DEBUG=1              # Enable debug mode
export DRY_RUN=1            # Test mode (no changes)
export SKIP_ROOT_CHECK=1    # Skip root requirement
export PARALLEL_JOBS=4      # Parallel processing
```

## 📁 Directory Structure

```
/data/superuser/
├── bin/        # Executables
├── etc/        # Configuration
├── lib/        # Libraries
├── tmp/        # Temporary files
├── backups/    # System backups
├── logs/       # Log files
├── docs/       # Documentation
├── scripts/    # Utility scripts
├── config/     # Additional configs
└── tools/      # Additional tools
```

## 🔒 Useful Aliases
After running setup, these aliases are available:

```bash
su-check        # Check accessibility
su-fix          # Fix permissions
su-backup       # Create backup
su-logs         # View logs
su_status       # Show status
```

## 🚨 Common Issues

| Issue | Solution |
|-------|----------|
| Permission denied | Run with `su -c` |
| Command not found | Add to PATH: `export PATH="/data/superuser/bin:$PATH"` |
| Root check fails | Use `export SKIP_ROOT_CHECK=1` |
| SELinux blocks | Try `setenforce 0` (temporary) |

## 📊 Return Codes

- `0` - Success
- `1` - General error  
- `2` - Permission denied
- `3` - File not found
- `4` - Command not found
- `5` - Network error

## 🔗 Quick Links

- Full documentation: `README.md`
- Command reference: `COMMANDS.md`
- Utility help: `./superuser-utils.sh help`
- Tool launcher help: `superuser-tool help`

---
**📱 Enhanced Superuser Terminal v1.1-enhanced**  
*Complete Android root management solution*