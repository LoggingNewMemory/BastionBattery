#!/bin/bash

MODULES_DIR="Modules"
BUILD_DIR="Build"
mkdir -p "$BUILD_DIR"

welcome() {
    clear
    echo "---------------------------------"
    echo "      Yamada Module Builder      "
    echo "---------------------------------"
    echo ""
}

success() {
    echo "---------------------------------"
    echo "    Build Process Completed      "
    printf "     Ambatukam : %s seconds\n" "$SECONDS"
    echo "---------------------------------"
}

build_modules() {
    rm -rf "$BUILD_DIR"/*

    read -p "Enter Version (e.g., V1.0): " VERSION

    while true; do
        read -p "Enter Build Type (LAB/RELEASE): " BUILD_TYPE
        BUILD_TYPE=${BUILD_TYPE^^}
        if [[ "$BUILD_TYPE" == "LAB" || "$BUILD_TYPE" == "RELEASE" ]]; then
            break
        fi
        echo "Invalid input. Please enter LAB or RELEASE."
    done

    cd "$MODULES_DIR" || exit 1
    MODULE_ID=$(grep "^id=" "module.prop" | cut -d'=' -f2 | tr -d '[:space:]')

    sed -i "s/^version=.*$/version=$VERSION/" "module.prop"
    if [ -f "customize.sh" ]; then
        sed -i 's/^ui_print "Version : .*$/ui_print "Version : '"$VERSION"'"/' "customize.sh"
    fi

    ZIP_NAME="${MODULE_ID}-${VERSION}-${BUILD_TYPE}.zip"
    zip -q -r "../$BUILD_DIR/$ZIP_NAME" ./*
    echo "Created: $ZIP_NAME"

    cd ..
}

welcome
build_modules
success
