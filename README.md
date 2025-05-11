# Superuser-device

## Building and Installing the su Binary for Android

### 1. Clone and Build the su Source

You can use the open-source [phhusson/superuser](https://github.com/phhusson/superuser) project.

```sh
git clone https://github.com/phhusson/superuser.git
cd superuser/su
# Set up NDK environment variables, e.g.:
export NDK=/path/to/android-ndk
export PATH=$NDK/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH

# For arm64 (aarch64)
aarch64-linux-android30-clang su.c -o su

# For arm (armeabi-v7a)
armv7a-linux-androideabi30-clang su.c -o su

# For x86
i686-linux-android30-clang su.c -o su# Superuser-device