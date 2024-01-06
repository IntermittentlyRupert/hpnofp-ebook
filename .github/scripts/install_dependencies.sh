#!/bin/bash
set -Eeuo pipefail

mkdir -p target

echo "Installing JRE..."
sudo apt-get update
sudo apt-get install -y default-jre libegl1 libopengl0 libxcb-cursor0

echo "Installing Calibre..."
wget -nv -O- https://download.calibre-ebook.com/linux-installer.sh | sudo sh /dev/stdin

echo "Downloading epubcheck..."
curl -L "https://github.com/w3c/epubcheck/releases/download/v$EPUBCHECK_VERSION/epubcheck-4.2.6.zip" -o "target/epubcheck-$EPUBCHECK_VERSION.zip"
unzip -o "./target/epubcheck-$EPUBCHECK_VERSION.zip" -d "./target"

echo "Downloading EB Garamond..."
curl -L "https://fonts.google.com/download?family=EB%20Garamond" -o "target/EB_Garamond.zip"
unzip -o "./target/EB_Garamond.zip" -d "./target/EB_Garamond"

echo "Installing EB Garamond..."
mkdir -p "/usr/share/fonts/truetype/custom"
mv "./target/EB_Garamond" "/usr/share/fonts/truetype/custom"
fc-cache -f -v

echo "Done."
