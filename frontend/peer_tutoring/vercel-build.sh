#!/bin/bash
set -e

echo "Installing Flutter SDK..."

git clone https://github.com/flutter/flutter.git \
  --depth 1 \
  --branch 3.27.1 \
  /tmp/flutter

export PATH="/tmp/flutter/bin:$PATH"

echo "Checking Flutter installation..."
flutter --version

echo "Enabling Flutter Web..."
flutter config --enable-web

echo "Installing dependencies..."
flutter pub get

echo "Building PeerLink..."
flutter build web --release

echo "Flutter Web build completed successfully."
