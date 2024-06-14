#!/bin/bash


CONFIG=Release
# Define the source and destination directories
SOURCE_DIR="src/"
DEST_HEADER_DIR="build-ios/include"

# Create the destination directory if it doesn't exist
mkdir -p "${DEST_HEADER_DIR}"

# Find and copy all header files while preserving the directory structure
find "${SOURCE_DIR}" -name '*.h' | while read -r header; do
    # Get the directory of the header file relative to the source directory
    relative_dir=$(dirname "${header#${SOURCE_DIR}/}")
    
    # Create the corresponding directory in the destination directory
    mkdir -p "${DEST_HEADER_DIR}/${relative_dir}"
    
    # Copy the header file to the destination directory
    cp "${header}" "${DEST_HEADER_DIR}/${relative_dir}"
done

echo "Headers copied to ${DEST_HEADER_DIR}"    


DEVICE_DIR=build-ios/src/${CONFIG}-iphoneos
SIMULATOR_DIR=build-ios/src/${CONFIG}-iphonesimulator
XCFRAMEWORK_DIR=build-ios/${CONFIG}-universal

xcodebuild -create-xcframework \
    -library ${DEVICE_DIR}/libsentencepiece.0.0.0.dylib \
    -headers ${DEST_HEADER_DIR} \
    -library ${SIMULATOR_DIR}/libsentencepiece.0.0.0.dylib \
    -headers ${DEST_HEADER_DIR} \
    -output ${XCFRAMEWORK_DIR}/sentencepiece.xcframework
