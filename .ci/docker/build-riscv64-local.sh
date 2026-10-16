#!/bin/bash

set -euo pipefail

IMAGE_NAME="${1:-pytorch-ci:riscv64}"
BUILD_ENVIRONMENT=pytorch-linux-noble-riscv64-py3.12-gcc14
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "$(uname -m)" != "riscv64" ]]; then
  echo "This image must be built on native riscv64 hardware." >&2
  exit 1
fi

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker is required to build ${IMAGE_NAME}." >&2
  exit 1
fi

if ! docker buildx version >/dev/null 2>&1; then
  echo "The Docker Buildx plugin is required to build ${IMAGE_NAME}." >&2
  exit 1
fi

cd "${SCRIPT_DIR}"
exec ./build.sh "${BUILD_ENVIRONMENT}" -t "${IMAGE_NAME}"
