#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 || ! "$1" =~ ^https:// ]]; then
  echo "Usage: $0 https://api.example.com/api [build-name] [build-number]" >&2
  exit 2
fi

API_BASE_URL="$1"
BUILD_NAME="${2:-1.0.0}"
BUILD_NUMBER="${3:-1}"
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

cd "$PROJECT_ROOT"
flutter build ipa \
  --release \
  --export-method app-store \
  --build-name="$BUILD_NAME" \
  --build-number="$BUILD_NUMBER" \
  --dart-define="API_BASE_URL=$API_BASE_URL"
