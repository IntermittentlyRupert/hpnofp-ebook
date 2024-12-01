#!/bin/bash
set -Eeuo pipefail

echo "Install Dependencies"
/bin/bash ./.github/scripts/install_dependencies.sh

echo "Build EPUB"
/bin/bash ./.github/scripts/build_epub.sh

echo "Check EPUB"
java -jar "./target/epubcheck/epubcheck.jar" "./target/hpnofp.epub"

echo "Build MOBI"
ebook-convert "target/hpnofp.epub" "target/hpnofp.mobi" --output-profile kindle_pw3

echo "Build PDF"
ebook-convert "target/hpnofp.epub" "target/hpnofp.pdf" --paper-size a4 --pdf-page-numbers --pdf-serif-family "EB Garamond" --pdf-standard-font serif
