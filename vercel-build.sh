#!/usr/bin/env bash
# Builds the Flutter web app for Vercel deployment.
#
# Vercel's build image does not ship the Flutter SDK, so this script fetches
# a pinned version, builds the release web bundle, and lets vercel.json point
# at the resulting build/web directory.
set -euo pipefail

FLUTTER_VERSION="3.44.4"
FLUTTER_DIR="$(pwd)/_flutter"

if [ ! -d "$FLUTTER_DIR" ]; then
  git clone https://github.com/flutter/flutter.git \
    --depth 1 \
    --branch "$FLUTTER_VERSION" \
    "$FLUTTER_DIR"
fi

export PATH="$PATH:$FLUTTER_DIR/bin"

flutter config --enable-web --no-analytics
flutter pub get
flutter build web --release
