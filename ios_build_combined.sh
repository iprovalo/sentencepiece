#!/bin/bash

#./ios_build_combined.sh
#1. This will configure and build targets for both static and dynamic libs.
#2. Build Settings -> Other Linker Flags - make sure has the file names as libsentencepiece.0.0.0 for @rpath
#3. Open build-os/Release-universal folder containing xcframework in Finder
#4. Drag and drop the dylib in XCode (check copy) to you target app project (lingofonex-ios)
#5. Make sure these are now linked to the Target in both Binary and Embed Libraries under Build Phases of the specific target
#6. Make sure these are findable - Build Settings of the specific target - Header and Library Search Paths include recursive references to the header folder src and build-ios folder of the sentencepiece

set -e

TEAM_ID="U4W5V9S4C3"
DEPLOYMENT_CONFIG=Release
ARCH="arm64;x86_64"
DEPLOYMENT_TARGET="14.0"


SOURCE_DIR="src/"
SOURCE_3RD_PARTY_DIR="third_party/"
BUILD_DIR=build-ios
DEST_HEADER_DIR="${BUILD_DIR}/include"

rm -Rf "${BUILD_DIR}"

cmake -B${BUILD_DIR} -GXcode -DCMAKE_SYSTEM_NAME=iOS \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=$DEPLOYMENT_TARGET \
    -DCMAKE_XCODE_ATTRIBUTE_DEVELOPMENT_TEAM="$TEAM_ID" \
    -DCMAKE_OSX_ARCHITECTURES=$ARCH

mkdir -p "${DEST_HEADER_DIR}"

cd ${BUILD_DIR}

xcodebuild -configuration $DEPLOYMENT_CONFIG -sdk iphoneos -target sentencepiece
xcodebuild -configuration $DEPLOYMENT_CONFIG -sdk iphoneos -target sentencepiece-static

xcodebuild -configuration $DEPLOYMENT_CONFIG -sdk iphonesimulator -target sentencepiece
xcodebuild -configuration $DEPLOYMENT_CONFIG -sdk iphonesimulator -target sentencepiece-static

cd ../

# Find and copy all header files while preserving the directory structure
find "${SOURCE_DIR}" -name '*.h' | while read -r header; do
    # Get the directory of the header file relative to the source directory
    relative_dir=$(dirname "${header#${SOURCE_DIR}/}")

    echo "copying $header to ${DEST_HEADER_DIR}/$relative_dir"

    # Create the corresponding directory in the destination directory
    mkdir -p "${DEST_HEADER_DIR}/${relative_dir}"

    # Copy the header file to the destination directory
    cp "${header}" "${DEST_HEADER_DIR}/${relative_dir}"
done

echo "Headers copied to ${DEST_HEADER_DIR}"

# Find and copy all header files while preserving the directory structure
find "${SOURCE_3RD_PARTY_DIR}" -name '*.h' | while read -r header; do
    # Get the directory of the header file relative to the source directory
    relative_dir=$(dirname "${header#${SOURCE_3RD_PARTY_DIR}/}")

    echo "copying $header to ${DEST_HEADER_DIR}/${SOURCE_3RD_PARTY_DIR}/$relative_dir"

    # Create the corresponding directory in the destination directory
    mkdir -p "${DEST_HEADER_DIR}/${SOURCE_3RD_PARTY_DIR}/${relative_dir}"

    # Copy the header file to the destination directory
    cp "${header}" "${DEST_HEADER_DIR}/${SOURCE_3RD_PARTY_DIR}/${relative_dir}"
done

echo "Third party Headers copied to ${DEST_HEADER_DIR}"

DEVICE_DIR=${BUILD_DIR}/src/${DEPLOYMENT_CONFIG}-iphoneos
SIMULATOR_DIR=${BUILD_DIR}/src/${DEPLOYMENT_CONFIG}-iphonesimulator
XCFRAMEWORK_DIR=${BUILD_DIR}/${DEPLOYMENT_CONFIG}-universal

xcodebuild -create-xcframework \
    -library ${DEVICE_DIR}/libsentencepiece.a \
    -headers ${DEST_HEADER_DIR} \
    -library ${SIMULATOR_DIR}/libsentencepiece.a \
    -headers ${DEST_HEADER_DIR} \
    -output ${XCFRAMEWORK_DIR}-static/sentencepiece.xcframework


xcodebuild -create-xcframework \
    -library ${DEVICE_DIR}/libsentencepiece.0.0.0.dylib \
    -headers ${DEST_HEADER_DIR} \
    -library ${SIMULATOR_DIR}/libsentencepiece.0.0.0.dylib \
    -headers ${DEST_HEADER_DIR} \
    -output ${XCFRAMEWORK_DIR}/sentencepiece.xcframework