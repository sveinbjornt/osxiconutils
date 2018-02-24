#!/bin/sh

XCODE_PROJ="osxiconutils.xcodeproj"

if [ ! -e "${XCODE_PROJ}" ]; then
    echo "Build script must be run from src root"
    exit 1
fi

BUILD_DIR="bin"

rm -r "${BUILD_DIR}" &> /dev/null
mkdir "${BUILD_DIR}" &> /dev/null

xcodebuild  -parallelizeTargets \
-project "${XCODE_PROJ}" \
-target "icns2image" \
-configuration "Release" \
CONFIGURATION_BUILD_DIR="${BUILD_DIR}" \
clean \
build

strip -x "${BUILD_DIR}/icns2image"

xcodebuild  -parallelizeTargets \
-project "${XCODE_PROJ}" \
-target "image2icns" \
-configuration "Release" \
CONFIGURATION_BUILD_DIR="${BUILD_DIR}" \
clean \
build

strip -x "${BUILD_DIR}/image2icns"

xcodebuild  -parallelizeTargets \
-project "${XCODE_PROJ}" \
-target "geticon" \
-configuration "Release" \
CONFIGURATION_BUILD_DIR="${BUILD_DIR}" \
clean \
build

strip -x "${BUILD_DIR}/geticon"

xcodebuild  -parallelizeTargets \
-project "${XCODE_PROJ}" \
-target "seticon" \
-configuration "Release" \
CONFIGURATION_BUILD_DIR="${BUILD_DIR}" \
clean \
build

strip -x "${BUILD_DIR}/seticon"

cp *.1 ${BUILD_DIR}/

zip osxiconutils.zip ${BUILD_DIR}/*



