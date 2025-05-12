# Superuser-device

A utility script to compile and install the `su` superuser binary for Android (ARMv7) devices and tablets.  
This script covers all standard Android locations for the `su` binary, from `/` to `/0`.

---

## ⚠️ Backup Recommendation

**Before running any root or system modification scripts, strongly back up your device:**
- Use `adb pull /system /path/to/backup/location` to back up your system partition.
- Consider full NANDroid or custom recovery backups for extra safety.
- Modifying `/system` can brick your device if not done carefully!

---

## 🚀 Usage Instructions

1. **Install prerequisites on your computer:**
    - Linux machine with `git`, `wget`, `unzip`, and `adb` installed.
    - Download and extract the [Android NDK](https://developer.android.com/ndk/downloads), or let the script download it for you.

2. **Download the script and make it executable:**
    ```sh
    git clone https://github.com/mathew-sudo/Superuser-device.git
    cd Superuser-device
    chmod +x Superuser_main
    ```

3. **Connect your Android device via USB and enable USB debugging.**

4. **Run the script as root:**
    ```sh
    sudo ./Superuser_main
    ```
    or (if in a root shell):
    ```sh
    ./Superuser_main
    ```

5. **What the script does:**
    - Downloads and sets up the Android NDK (if not already present).
    - Clones the [phhusson/superuser](https://github.com/phhusson/superuser) source.
    - Compiles the `su` binary for ARMv7.
    - Pushes the binary to your device and installs it in all standard locations:
        - `/system/bin/su`
        - `/system/xbin/su`
        - `/sbin/su`
        - `/su/bin/su`
        - `/su/xbin/su`
        - `/system/sbin/su`
        - `/magisk/.core/bin/su`
        - `/debug_ramdisk/su`
        - `/sbin/bin/su`
        - `/system/su`
        - `/system/xbin/daemonsu`
        - `/system/xbin/busybox`
        - `/su`
        - `/xbin/su`
        - `/bin/su`
        - `/0/su`

6. **Script output:**
    - Each install step is logged to the console.
    - The script attempts to set correct permissions (`6755`, `root:root`) for all `su` locations.
    - At the end, the script will test each installed `su` binary.

---

## 📂 Directory Paths

The script deliberately installs `su` into every common location used by ROMs, Magisk, or custom recoveries, from root `/` to `/0`.  
If a directory does not exist, it will be created (with `mkdir -p`).

---

## 🐞 Troubleshooting

- Some Android devices may restrict `/system` modifications (especially with A/B partitions or system-as-root).  
- For these, you may need a custom recovery (TWRP) or Magisk for full root access.
- Always check that your device remains bootable after modifying `/system`!

---

## 📢 Disclaimer

**Use at your own risk.**  
Modifying system binaries may void your warranty or brick your device.  
The author is not responsible for any damage or data loss.

---

## 🙏 Credits

- [phhusson/superuser](https://github.com/phhusson/superuser) for the open-source `su` implementation.
- Android Open Source Project.