#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
# Set the path to your Android NDK
export NDK=/opt/android-ndk

# Set the target Android API level (21 is a good minimum for modern devices)
export API=21

# --- Environment Setup ---
# Set the path to the NDK's prebuilt toolchain
export TOOLCHAIN=$NDK/toolchains/llvm/prebuilt/linux-x86_64/bin

# --- Prerequisite Check ---
# Ensure the inotify-tools source code is present
if [ ! -f "autogen.sh" ]; then
    echo "Error: 'autogen.sh' not found."
    echo "Please run this script from the root of the inotify-tools source directory."
    exit 1
fi

# Prepare the build system
./autogen.sh

# =================================================================
#                         Build for ARM64 (aarch64)
# =================================================================
echo " "
echo "Building for ARM64 (aarch64)..."

# Set architecture-specific environment variables
export TARGET_HOST=aarch64-linux-android
export AR=$TOOLCHAIN/llvm-ar
export CC=$TOOLCHAIN/${TARGET_HOST}${API}-clang
export AS=$CC
export CXX=$TOOLCHAIN/${TARGET_HOST}${API}-clang++
export LD=$TOOLCHAIN/ld
export RANLIB=$TOOLCHAIN/llvm-ranlib
export STRIP=$TOOLCHAIN/llvm-strip

# Configure the build for ARM64
# We build statically to avoid shared library issues on Android
./configure --host=$TARGET_HOST \
            --enable-static \
            --disable-shared

# Compile and strip the binary for a smaller size
make -j$(nproc)
$STRIP src/inotifywait src/inotifywatch

# Create an output directory and copy the binary
mkdir -p build_arm64
cp src/inotifywait build_arm64/
cp src/inotifywatch build_arm64/

# Clean up the build files for the next architecture
make distclean

# =================================================================
#                         Build for ARM32 (armv7a)
# =================================================================
echo " "
echo "Building for ARM32 (armv7a)..."

# Set architecture-specific environment variables
export TARGET_HOST=armv7a-linux-androideabi
export AR=$TOOLCHAIN/llvm-ar
export CC=$TOOLCHAIN/${TARGET_HOST}${API}-clang
export AS=$CC
export CXX=$TOOLCHAIN/${TARGET_HOST}${API}-clang++
export LD=$TOOLCHAIN/ld
export RANLIB=$TOOLCHAIN/llvm-ranlib
export STRIP=$TOOLCHAIN/llvm-strip

# Configure the build for ARM32
./configure --host=$TARGET_HOST \
            --enable-static \
            --disable-shared

# Compile and strip the binary
make -j$(nproc)
$STRIP src/inotifywait src/inotifywatch

# Create an output directory and copy the binary
mkdir -p build_arm32
cp src/inotifywait build_arm32/
cp src/inotifywatch build_arm32/

# Final cleanup
make distclean

echo " "
echo "Build complete! 🚀"
echo "ARM64 binaries are in: $(pwd)/build_arm64"
echo "ARM32 binaries are in: $(pwd)/build_arm32"