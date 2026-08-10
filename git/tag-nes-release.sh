#!bash

set -euo pipefail

if [ "$#" -lt 2 ]; then
  echo "Usage: $0 version project-name"
  exit 1
fi

VERSION=$1
NAME=$2

shift 2

git tag -s -a "nes-v${VERSION}" -m "Release ${NAME} v${VERSION}" "$@"
git push origin tag "nes-v${VERSION}" "$@"

