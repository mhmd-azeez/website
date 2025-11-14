#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

echo "Building site with Hugo..."
hugo --minify

echo "Build artifacts written to $(realpath docs)"
