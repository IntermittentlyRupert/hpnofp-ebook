#!/bin/bash
set -Eeuo pipefail

EPUB_FILE="$(pwd)/target/hpnofp.epub"

mkdir -p ./target/minified

echo "Minifying resources..."
cp -r ./src/. ./target/minified
for file in `find src | grep -E '\.(xhtml|css|ncx|opf|xml)$'`; do
  echo "  - $file"
  sed 's|\s\s\s*| |g' "$file" | tr -d '\n' > `echo $file | sed "s|src/|target/minified/|"`
done

pushd ./target/minified
trap 'popd' EXIT

echo "Building EPUB archive..."
zip -q -X0 "$EPUB_FILE" mimetype
zip -q -r "$EPUB_FILE" META-INF OEBPS

echo "Done."
