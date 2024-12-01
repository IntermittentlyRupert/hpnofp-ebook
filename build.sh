#!/bin/bash
set -Eeuo pipefail

export EPUBCHECK_VERSION="5.1.0"

rm -rf ./target

/bin/bash ./.github/scripts/build_full.sh
