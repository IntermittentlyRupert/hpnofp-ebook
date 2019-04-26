#!/bin/sh

DIR=`dirname $0`
INPUT_DIR="$DIR/src"
OUTPUT_DIR="$DIR/target"
MINIFIED_DIR="$OUTPUT_DIR/minified"
ARTIFACT_NAME="Harry Potter and the Nightmares of Futures Past"
EPUB_ARTIFACT="$OUTPUT_DIR/$ARTIFACT_NAME.epub"

clean () {
  rm -r "$OUTPUT_DIR"
  mkdir "$OUTPUT_DIR"
}

minify_resources () {
  echo "Minifying resources..."
  mkdir -p "$MINIFIED_DIR"
  cp -r "$INPUT_DIR/mimetype" "$INPUT_DIR/META-INF" "$INPUT_DIR/OEBPS" "$MINIFIED_DIR/"
  for file in `ls $INPUT_DIR/OEBPS/*ml $INPUT_DIR/OEBPS/*.ncx $INPUT_DIR/OEBPS/*.opf`; do
    # collapse whitespace for efficiency
    sed 's|\s\s\s*| |g' "$file" | tr -d '\n' > `echo $file | sed "s|$INPUT_DIR/OEBPS/|$MINIFIED_DIR/OEBPS/|"`
  done
}

make_epub () {
  echo "Generating ePub..."
  SRC_DIR="$1"
  if [ $# -lt 2 ]; then
    DEST_FILE="$EPUB_ARTIFACT"
  else
    DEST_FILE="$2"
  fi
  # we need to force a non-relative path here
  CANONICAL_DEST_FILE="$(cd "$(dirname "$DEST_FILE")"; pwd)/$(basename "$DEST_FILE")"
  (cd $SRC_DIR && zip -q -X0 "$CANONICAL_DEST_FILE" mimetype && zip -q -r "$CANONICAL_DEST_FILE" META-INF OEBPS)
}

to_mobi () {
  if (which ebook-convert >/dev/null 2>&1); then
    echo "Converting to MOBI using Calibre ebook-convert..."
    ebook-convert "$EPUB_ARTIFACT" "$OUTPUT_DIR/$ARTIFACT_NAME.mobi" > /dev/null
  else
    echo "No MOBI converter found. Consider installing Calibre."
    return 1
  fi
}

to_pdf () {
  if (which ebook-convert >/dev/null 2>&1); then
    echo "Converting to PDF using Calibre ebook-convert..."
    # try to use a Garamond font, otherwise just a Serif font
    SERIF_FONT=$(fc-list : family |grep "Garamond" |cut -d , -f 1 |head -1)
    if [ -z "$SERIF_FONT" ]; then
      SERIF_FONT=Serif
    fi
    ebook-convert "$EPUB_ARTIFACT" "$OUTPUT_DIR/$ARTIFACT_NAME.pdf" --paper-size a4 --pdf-page-numbers --pdf-serif-family "$SERIF_FONT" --pdf-standard-font serif > /dev/null
  elif (which mutool >/dev/null 2>&1); then
    echo "Converting to PDF using Mutool..."
    mutool convert -o "$OUTPUT_DIR/$ARTIFACT_NAME.pdf" "$EPUB_ARTIFACT" > /dev/null
  else
    echo "No PDF converter found. Consider installing Calibre or MuPDF Tools."
    return 1
  fi
}

make_target () {
  BUILD_TARGET=$1
  case $BUILD_TARGET in
    all)
      clean
      minify_resources
      make_epub "$MINIFIED_DIR"
      to_mobi
      to_pdf
      ;;
    mobi)
      if [ ! -e "$EPUB_ARTIFACT" ]; then
        make_epub "$INPUT_DIR" "$EPUB_ARTIFACT"
      fi
      to_mobi
      ;;
    pdf)
      if [ ! -e "$EPUB_ARTIFACT" ]; then
        make_epub "$INPUT_DIR" "$EPUB_ARTIFACT"
      fi
      to_pdf
      ;;
    epub)
      minify_resources
      make_epub "$MINIFIED_DIR"
      ;;
    uncompressed_epub)
      make_epub "$INPUT_DIR" "$EPUB_ARTIFACT"
      ;;
    clean)
      clean
      ;;
    *)
      echo "Unrecognised build target: $BUILD_TARGET"
  esac
  echo "Done"
}

mkdir -p "$OUTPUT_DIR"
if [ $# -eq 0 ]; then
  make_target all
else
  for target in $@; do
    make_target "$target"
  done
fi
