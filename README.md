# Enhanced Superuser Terminal

![CI Status](https://github.com/mathew-sudo/Superuser-device/workflows/Superuser%20CI%20Tests/badge.svg)
![Security Audit](https://img.shields.io/badge/security-audited-green)
![Platform](https://img.shields.io/badge/platform-Android-brightgreen)
![License](https://img.shields.io/badge/license-MIT-blue)

A comprehensive Android root management solution with advanced features for system administration, security auditing, and device maintenance.

## 🎯 Key Features

### 🔧 Core Functionality
- **Automated Su Binary Detection & Fixing** - Intelligent detection and permission repair
- **System Compatibility Checking** - Comprehensive device and environment analysis
- **Enhanced Backup & Recovery** - Timestamped backups with integrity verification
- **Interactive Mode** - User-friendly menu-driven interface
- **Termux Integration** - Seamless operation within Termux environment

### 🚀 Advanced Features
- **Performance Monitoring** - Real-time system health and performance tracking
- **Security Auditing** - Vulnerability assessment and security scoring
- **Network Diagnostics** - Connectivity testing and network analysis
- **System Repair Utility** - Automated fixing of common issues
- **Comprehensive Testing** - Built-in test framework for validation
- **Advanced Logging** - Multi-level logging with rotation and search

### 🛡️ Security & Safety
- **Enhanced Error Handling** - Robust error recovery and reporting
- **Input Validation** - Secure input processing and sanitization
- **Backup Before Changes** - Automatic backups before any modifications
- **Permission Verification** - Thorough validation of binary authenticity
- **SELinux Compatibility** - Works with various SELinux configurations

### 📱 Android Integration
- **Android Development Tools** - Complete Android project structure generation
- **ADB Integration** - Direct Android Debug Bridge integration
- **Device Information** - Detailed Android device and user information
- **Termux Support** - Enhanced features for Termux environment

## 🔒 Security Notice

**⚠️ CRITICAL SECURITY WARNING ⚠️**

This tool modifies critical system files and grants superuser access. Improper use can:
- **Brick your device** permanently
- **Void your warranty** completely
- **Compromise device security** if misconfigured
- **Cause data loss** or system instability

**Only use this tool if you:**
- Understand the risks involved
- Have experience with Android rooting
- Have proper device backups
- Accept full responsibility for consequences

---

## 📋 Requirements

- Android device with root access
- Terminal emulator (Termux recommended)
- Bash shell
- Basic system utilities (stat, chmod, chown, etc.)

---

## ⚠️ Backup Recommendation

**MANDATORY: Create comprehensive backups before proceeding**

### 1. System Partition Backup
```bash
# Full system backup via ADB
adb shell su -c "dd if=/dev/block/platform/*/by-name/system of=/sdcard/system_backup.img"
adb pull /sdcard/system_backup.img ./backups/

# Alternative: Use ADB pull
adb pull /system ./backups/system_backup/
```

### 2. Boot and Recovery Backups
```bash
# Boot partition
adb shell su -c "dd if=/dev/block/platform/*/by-name/boot of=/sdcard/boot_backup.img"
adb pull /sdcard/boot_backup.img ./backups/

# Recovery partition  
adb shell su -c "dd if=/dev/block/platform/*/by-name/recovery of=/sdcard/recovery_backup.img"
adb pull /sdcard/recovery_backup.img ./backups/
```

### 3. NANDroid Backup (Recommended)
```bash
# Using TWRP or custom recovery
# Create full NANDroid backup including:
# - System, Data, Boot, Recovery
# - EFS (Essential File System)
# - Persist partition
```

---

## 🚀 Installation & Usage

### Quick Installation

1. Download the files to your Android device
2. Make the installer executable:
   ```bash
   chmod +x install.sh
   ```
3. Run the installer as root:
   ```bash
   su -c ./install.sh
   ```

### Manual Installation

1. Run the main script to build the structure:
   ```bash
   ./Superuser_main build
   ```
2. Install the script to the superuser directory:
   ```bash
   ./Superuser_main install
   ```

### Basic Commands

```bash
# Run system check
superuser check

# Fix su permissions
superuser fix

# Create backup
superuser backup

# Launch interactive mode
superuser interactive

# Run full diagnostic suite
superuser full
```

### Interactive Mode

The interactive mode provides a user-friendly menu interface:

```bash
superuser interactive
```

### Tool Launcher

Use the tool launcher for quick access:

```bash
superuser-tool check    # Quick system check
superuser-tool fix      # Fix permissions
superuser-tool backup   # Create backup
```

---

## 🔧 Available Commands

| Command | Description |
|---------|-------------|
| `check` | Run comprehensive system check |
| `setup` | Initial setup with optimizations |
| `build` | Build enhanced directory structure |
| `structure` | Create directory structure only |
| `install` | Full installation with setup |
| `fix` | Fix su permissions with safety checks |
| `backup` | Create enhanced backup |
| `benchmark` | Run performance benchmark |
| `network` | Check network connectivity |
| `security` | Run security audit |
| `optimize` | Get optimization suggestions |
| `full` | Run complete diagnostic suite |
| `interactive` | Launch interactive mode |

---

## 🏗️ Directory Structure

```
/data/superuser/
├── bin/                 # Executable scripts and tools
│   ├── Superuser_main  # Main script
│   ├── superuser-tool  # Tool launcher
│   └── superuser-utils.sh # Utility functions
├── etc/                # Configuration files
│   └── profile         # Environment setup
├── lib/                # Library files
├── tmp/                # Temporary files
├── backups/            # System backups
├── logs/               # Log files
├── docs/               # Documentation
├── test-env/           # Testing environment
├── scripts/            # Utility scripts
├── config/             # Additional configurations
└── tools/              # Additional tools
```

---

## 🔒 Security Features

- **Input Validation**: All user inputs are validated for security
- **Safe Command Execution**: Protection against command injection
- **Backup Creation**: Automatic backups before making changes
- **Permission Verification**: Strict permission checking
- **Error Handling**: Comprehensive error handling and recovery

---

## 📊 Performance

The Enhanced Superuser Terminal is optimized for:
- Fast startup and execution
- Minimal resource usage
- Parallel processing where safe
- Efficient dependency checking

---

## 🐛 Troubleshooting

### Common Issues

1. **Permission Denied**
   ```bash
   # Ensure you're running as root
   su -c ./Superuser_main
   ```

2. **Command Not Found**
   ```bash
   # Add to PATH
   export PATH="/data/superuser/bin:$PATH"
   ```

3. **Log Access**
   ```bash
   # View recent logs
   tail -f /data/superuser/logs/superuser.log
   ```

### Debug Mode

Enable verbose logging:
```bash
export DEBUG=1
./Superuser_main check
```

---

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

---

## 📝 License

This project is provided as-is for educational and research purposes. Use at your own risk.

## ⚠️ Disclaimer

This software is designed for legitimate system administration purposes. Users are responsible for complying with applicable laws and regulations. The authors are not responsible for any misuse or damage caused by this software.

## 📞 Support & Community

### Getting Help
- **GitHub Issues** - [Report bugs and request features](https://github.com/mathew-sudo/Superuser-device/issues)
- **Discussions** - [Community support and questions](https://github.com/mathew-sudo/Superuser-device/discussions)
- **Wiki** - [Detailed documentation and guides](https://github.com/mathew-sudo/Superuser-device/wiki)

### Security Issues
For security vulnerabilities, please email: security@example.com

**Do not create public issues for security vulnerabilities.**

---

## 🔄 Version History

- **v1.1-enhanced**: Complete rewrite with advanced features
- **v1.0**: Initial release

---

**Made with ❤️ for the Android community**