#!/bin/sh

ARTIFACT_NAME="Harry Potter and the Nightmares of Futures Past"
ARTIFACT="$ARTIFACT_NAME.epub"
DIR=`dirname $0`

mkdir -p $DIR/target
rm -r $DIR/target/*
cp -r $DIR/mimetype $DIR/META-INF $DIR/OEBPS target/
for file in `ls $DIR/OEBPS/*ml $DIR/OEBPS/*.ncx $DIR/OEBPS/*.opf`; do
  # collapse whitespace for efficiency
  sed 's|\s\s\s*| |g' "$file" | tr -d '\n' > `echo $file | sed "s|$DIR/OEBPS/|$DIR/target/OEBPS/|"`
done
(cd target && zip -X0 "$ARTIFACT" mimetype && zip -r "$ARTIFACT" META-INF OEBPS)

if (which mutool 2>/dev/null); then
  echo "Converting to PDF..."
  (cd target && mutool convert -o "$ARTIFACT_NAME.pdf" "$ARTIFACT")
else
  echo "No PDF converter found. Consider installing MuPDF Tools."
fi
