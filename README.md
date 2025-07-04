# Superuser-device

![CI Status](https://github.com/mathew-sudo/Superuser-device/workflows/Superuser%20CI%20Tests/badge.svg)
![Security Audit](https://img.shields.io/badge/security-audited-green)
![Platform](https://img.shields.io/badge/platform-Android-brightgreen)
![License](https://img.shields.io/badge/license-MIT-blue)

A comprehensive utility script for managing superuser access on Android devices. This enhanced tool provides secure installation, configuration, and management of the `su` superuser binary across all standard Android locations.

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

## ✨ Enhanced Features

### 🛡️ Security & Safety
- **Input validation** - All user inputs are sanitized and validated
- **Secure root elevation** - Safe root access mechanisms with validation
- **Automatic backups** - Critical files backed up before modification
- **Permission validation** - Comprehensive permission and ownership checks
- **SELinux awareness** - Detects and handles SELinux policies

### 🔧 System Management
- **Multi-architecture support** - ARM, ARM64, x86, x86_64 compatibility
- **Comprehensive diagnostics** - Detailed system information and compatibility checks
- **Dependency management** - Automatic detection and installation of required tools
- **Recovery mechanisms** - Error recovery and rollback capabilities
- **Interactive mode** - User-friendly menu-driven interface

### 📊 Monitoring & Logging
- **Comprehensive logging** - Detailed operation logs with timestamps
- **Performance monitoring** - Execution time and resource usage tracking
- **Status reporting** - Real-time progress and status updates
- **Troubleshooting guidance** - Built-in diagnostic and recovery suggestions

---

## 📋 Prerequisites

### System Requirements
- **Linux-based system** (Ubuntu 18.04+ recommended)
- **Root access** on the host system
- **USB debugging enabled** on Android device
- **Minimum 100MB free space** for tools and backups

### Required Tools
```bash
# Essential tools (auto-installed if missing)
sudo apt-get update
sudo apt-get install -y \
    git wget unzip curl \
    android-tools-adb android-tools-fastboot \
    build-essential cmake \
    shellcheck jq

# Optional but recommended
sudo apt-get install -y \
    android-sdk-platform-tools \
    android-sdk-build-tools
```

### Android Device Requirements
- **Android 5.0+** (API level 21+)
- **USB debugging enabled** in Developer Options
- **Bootloader unlocked** (for system modifications)
- **Custom recovery** (TWRP recommended) for safety

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

### Quick Start
```bash
# Clone the repository
git clone https://github.com/mathew-sudo/Superuser-device.git
cd Superuser-device

# Make executable
chmod +x Superuser_main

# Run comprehensive system check
sudo ./Superuser_main check

# Interactive mode (recommended for beginners)
sudo ./Superuser_main interactive
```

### Available Commands
```bash
# System operations
sudo ./Superuser_main check          # Full system check and validation
sudo ./Superuser_main backup         # Create backup of critical files
sudo ./Superuser_main interactive    # Launch interactive menu

# Android device operations  
sudo ./Superuser_main android-term   # Launch Android terminal via ADB
sudo ./Superuser_main android-user   # Display Android user information

# Help and information
./Superuser_main                     # Show available options
```

### Interactive Mode Features
1. **Full system check** - Comprehensive diagnostic and compatibility testing
2. **Permission management** - Fix and validate su binary permissions
3. **Android terminal** - Direct access to device shell
4. **User information** - Display device and user details
5. **Backup creation** - Create timestamped backups
6. **Log viewing** - Review operation logs and history

---

## 📂 Installation Locations

The script installs `su` binaries to all standard Android locations:

### Primary Locations
- `/system/bin/su` - Standard system binary location
- `/system/xbin/su` - Extended system binaries
- `/sbin/su` - System administration binaries

### Secondary Locations  
- `/su/bin/su` - Dedicated su directory
- `/su/xbin/su` - Extended su binaries
- `/system/sbin/su` - Alternative system location

### Specialized Locations
- `/magisk/.core/bin/su` - Magisk integration
- `/debug_ramdisk/su` - Debug/development builds
- `/system/xbin/daemonsu` - SuperSU compatibility
- `/system/xbin/busybox` - BusyBox integration

### Legacy/Alternative Locations
- `/bin/su`, `/xbin/su`, `/0/su` - Various ROM implementations

---

## 🔧 Advanced Configuration

### Environment Variables
```bash
# Logging configuration
export LOG_DIR="/custom/log/path"
export LOG_LEVEL="DEBUG"

# Test mode (safe for testing)
export DRY_RUN=1
export TEST_MODE=1

# Performance tuning
export TEST_TIMEOUT=600
export MAX_LOGS=20
```

### Custom Build Configuration
```bash
# Android NDK version
export ANDROID_NDK_VERSION="r25c"

# Target architectures
export TARGET_ARCH="arm64-v8a"
export ANDROID_API_LEVEL=29
```

---

## 🐞 Troubleshooting

### Common Issues

#### 1. Permission Denied Errors
```bash
# Symptoms: chmod/chown failures
# Solutions:
sudo mount -o remount,rw /system
setenforce 0  # Temporarily disable SELinux
adb shell su -c "mount -o remount,rw /"
```

#### 2. Device Not Found
```bash
# Check ADB connection
adb devices
adb kill-server && adb start-server

# Verify USB debugging
adb shell getprop ro.debuggable
```

#### 3. System Partition Read-Only
```bash
# Modern Android devices (A/B partitions)
adb shell su -c "mount -o remount,rw /"
adb shell su -c "mount -o remount,rw /system"

# Older devices
adb shell su -c "mount -o remount,rw /system /system"
```

#### 4. SELinux Policy Violations
```bash
# Check SELinux status
adb shell getenforce

# Temporary solution (not recommended for production)
adb shell su -c "setenforce 0"

# Permanent solution: Custom SELinux policy
# (Advanced users only)
```

### Recovery Procedures

#### Boot Loop Recovery
1. **Enter recovery mode** (Volume Down + Power)
2. **Restore NANDroid backup** or **Factory reset**
3. **Flash stock firmware** if necessary
4. **Restore from backup** after successful boot

#### System Corruption Recovery
1. **Boot to custom recovery** (TWRP)
2. **Mount system partition**
3. **Restore system backup**:
   ```bash
   adb push ./backups/system_backup.img /sdcard/
   adb shell recovery
   # Use recovery menu to restore
   ```

---

## 📊 Continuous Integration

### Automated Testing
- **Security audits** - Automated vulnerability scanning
- **Code quality** - ShellCheck linting and formatting
- **Multi-platform testing** - ARM, ARM64, x86, x86_64
- **Performance benchmarks** - Execution time and memory usage
- **Integration testing** - Real Android emulator testing

### CI Pipeline Status
[![CI Tests](https://github.com/mathew-sudo/Superuser-device/actions/workflows/ci.yml/badge.svg)](https://github.com/mathew-sudo/Superuser-device/actions)

View detailed test reports and coverage at: [CI Dashboard](https://github.com/mathew-sudo/Superuser-device/actions)

---

## 🔍 System Compatibility

### Supported Android Versions
- **Android 5.0 - 14** (API 21-34)
- **AOSP-based ROMs** (LineageOS, Pixel Experience, etc.)
- **Custom ROMs** with standard partition layouts
- **Magisk-rooted devices** (enhanced compatibility)

### Supported Architectures
- **ARM** (armv7a) - Most Android phones/tablets
- **ARM64** (aarch64) - Modern 64-bit devices  
- **x86** - Intel-based Android devices
- **x86_64** - 64-bit Intel Android devices

### Known Limitations
- **System-as-root devices** may require additional steps
- **A/B partition devices** need special handling
- **Heavily modified OEM ROMs** may have compatibility issues
- **Devices with enforced dm-verity** require disabling

---

## 🙏 Contributing

### Development Setup
```bash
# Fork and clone the repository
git clone https://github.com/your-username/Superuser-device.git
cd Superuser-device

# Install development dependencies
sudo apt-get install shellcheck shfmt

# Run tests locally
./scripts/run-tests.sh
```

### Contribution Guidelines
1. **Follow shell scripting best practices**
2. **Add comprehensive tests** for new features
3. **Update documentation** for changes
4. **Ensure security compliance** - no vulnerabilities
5. **Test on multiple devices** before submitting

---

## 📄 License & Credits

### License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

### Credits & Acknowledgments
- **[phhusson/superuser](https://github.com/phhusson/superuser)** - Core su implementation
- **Android Open Source Project** - Android platform foundation
- **Magisk Project** - Root management inspiration
- **XDA Developers Community** - Testing and feedback
- **GitHub Actions** - CI/CD infrastructure

---

## 📞 Support & Community

### Getting Help
- **GitHub Issues** - [Report bugs and request features](https://github.com/mathew-sudo/Superuser-device/issues)
- **Discussions** - [Community support and questions](https://github.com/mathew-sudo/Superuser-device/discussions)
- **Wiki** - [Detailed documentation and guides](https://github.com/mathew-sudo/Superuser-device/wiki)

### Security Issues
For security vulnerabilities, please email: security@example.com

**Do not create public issues for security vulnerabilities.**

---

## 📈 Changelog

### Version 1.0-prototype
- ✨ Enhanced security with input validation
- 🛡️ Secure root elevation mechanisms  
- 📊 Comprehensive system diagnostics
- 🔧 Interactive mode with menu interface
- 📝 Detailed logging and error reporting
- 🔄 Automatic backup and recovery
- 🧪 Extensive CI/CD testing pipeline

---

**⚠️ Final Reminder: Use at your own risk. Always maintain proper backups and understand the implications of system modifications.**