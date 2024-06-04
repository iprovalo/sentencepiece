#!/bin/bash

set -e
TEAM_ID="U4W5V9S4C3"

#./ios_build.sh build clean
# This will configure cmake build.  After this step, open the project in XCode and you may need to make some changes for the build time:
  #1. Build Settings -> Other Linker Flags - make sure has the file names as libsentencepiece.0.0.0 for @rpath
  #2. Check iphone and iPad under General on each specific target - this may not be required.
  #3. PROJECT LEVEL - Build Settings - Build Active Architecture Only - NO
  #4. Build all four - sentencepiece+static and sentencepiece_train+static separately, WHILE SPECIFYING BOTH arm64 AND x86_64 ARCHITECTURES in XCode
#Then run xcframework.sh to create a xcframework
#5. Open build-os/Debug-universal folder containing xcframework in Finder
#6. Drag and drop the dylib in XCode (Do not copy) to you target app project (lingofonex-ios)
#7. Make sure these are now linked to the Target in both Binary and Embed Libraries under Build Phases of the specific target
#8. Make sure these are findable - Build Settings of the specific target - Header and Library Search Paths include recursive references to the header folder src and build-ios folder of the sentencepiece


if [ "$1" == "help" ]; then
  echo "Run bash ios_build.sh build clean"
  exit
fi

if [ "$1" == "build" ] || [ "$1" == "configure" ]; then
echo "Running CMake configuration..."

# clean up old builds
if [ "$2" == "clean" ]; then rm -Rf build-ios; fi

# generate new builds
cmake -Bbuild-ios -GXcode -DCMAKE_SYSTEM_NAME=iOS \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=12.0 \
    -DCMAKE_XCODE_ATTRIBUTE_DEVELOPMENT_TEAM="$TEAM_ID" \
    -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64"
fi

#cp build_universal.sh build-ios/

#cd build-ios/

#./build_universal.sh


