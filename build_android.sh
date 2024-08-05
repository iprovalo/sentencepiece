#!/usr/bin/env bash
set -ex

#"arm64-v8a", "armeabi-v7a", "x86", "x86_64"
android_abi=$1

#https://k2-fsa.github.io/sherpa/onnx/android/build-sherpa-onnx.html
#export ANDROID_NDK=/Users/iprovalov/Library/Android/sdk/ndk/21.4.7075529
if [ ! -d $ANDROID_NDK ]; then
  echo Please set the environment variable ANDROID_NDK before you run this script
  exit 1
fi

echo "ANDROID_NDK: $ANDROID_NDK"
sleep 1

if [ $android_abi = "armeabi-v7a" ]; then
  cmake -DCMAKE_TOOLCHAIN_FILE="$ANDROID_NDK/build/cmake/android.toolchain.cmake" \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_SHARED_LIBS=ON \
      -DCMAKE_INSTALL_PREFIX=./install \
      -DANDROID_ABI="$android_abi" \
      -DANDROID_ARM_NEON=ON \
      -DANDROID_PLATFORM=android-21 .
else
  cmake -DCMAKE_TOOLCHAIN_FILE="$ANDROID_NDK/build/cmake/android.toolchain.cmake" \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_SHARED_LIBS=ON \
      -DCMAKE_INSTALL_PREFIX=./install \
      -DANDROID_ABI="$android_abi" \
      -DANDROID_PLATFORM=android-21 .
fi

make -j4
make install/strip
rm -rf install/lib/pkgconfig