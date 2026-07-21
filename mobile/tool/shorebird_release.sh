#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 3 ]]; then
  echo "Usage: $0 <release|patch> <android|ios> <https-api-url> [build-name] [build-number]" >&2
  exit 2
fi

ACTION="$1"
PLATFORM="$2"
API_BASE_URL="$3"
BUILD_NAME="${4:-1.0.0}"
BUILD_NUMBER="${5:-1}"
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

if [[ "$ACTION" != "release" && "$ACTION" != "patch" ]]; then
  echo "Action must be release or patch." >&2
  exit 2
fi
if [[ "$PLATFORM" != "android" && "$PLATFORM" != "ios" ]]; then
  echo "Platform must be android or ios." >&2
  exit 2
fi
if [[ ! "$API_BASE_URL" =~ ^https:// ]]; then
  echo "Production API_BASE_URL must start with https://" >&2
  exit 2
fi
if ! command -v shorebird >/dev/null 2>&1; then
  echo "Shorebird CLI is not installed. See https://docs.shorebird.dev" >&2
  exit 1
fi
if [[ ! -f "$PROJECT_ROOT/shorebird.yaml" ]]; then
  echo "Missing shorebird.yaml. Run shorebird init with the project owner account." >&2
  exit 1
fi

cd "$PROJECT_ROOT"
ARGS=("$ACTION" "$PLATFORM" "--" "--dart-define=API_BASE_URL=$API_BASE_URL")
if [[ "$ACTION" == "release" ]]; then
  ARGS+=("--build-name=$BUILD_NAME" "--build-number=$BUILD_NUMBER")
fi
shorebird "${ARGS[@]}"
