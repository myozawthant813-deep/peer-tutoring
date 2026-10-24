#!/bin/bash
set -e

# Install Flutter SDK
git clone https://github.com/flutter/flutter.git --depth 1 --branch 3.27.1 /tmp/flutter

export PATH="/tmp/flutter/bin:$PATH"

# Verify Flutter installation
flutter --version

# Enable Flutter Web
flutter config --enable-web

# Get dependencies and build
flutter pub get
flutter build web --release
