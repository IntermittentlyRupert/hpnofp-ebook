#!/bin/sh

ARTIFACT_NAME="Harry Potter and the Nightmares of Futures Past"
ARTIFACT="$ARTIFACT_NAME.epub"
DIR=`dirname $0`
OUTPUT_DIR="$DIR/target"

clean () {
  rm -r $OUTPUT_DIR/*
}

minify_resources () {
  cp -r $DIR/mimetype $DIR/META-INF $DIR/OEBPS $OUTPUT_DIR/
  for file in `ls $DIR/OEBPS/*ml $DIR/OEBPS/*.ncx $DIR/OEBPS/*.opf`; do
    # collapse whitespace for efficiency
    sed 's|\s\s\s*| |g' "$file" | tr -d '\n' > `echo $file | sed "s|$DIR/OEBPS/|$OUTPUT_DIR/OEBPS/|"`
  done
}

make_epub () {
  SRC_DIR="$1"
  if [ $# -lt 2 ]; then
    DEST_FILE="$ARTIFACT"
  else
    DEST_FILE="$2"
  fi
  (cd "$SRC_DIR" && zip -X0 "$DEST_FILE" mimetype && zip -r "$DEST_FILE" META-INF OEBPS)
}

to_mobi () {
  if (which ebook-convert 2>/dev/null); then
    echo "Converting to MOBI using Calibre ebook-convert..."
    (cd $OUTPUT_DIR && ebook-convert "$ARTIFACT" .mobi)
  else
    echo "No MOBI converter found. Consider installing Calibre."
    return 1
  fi
}

to_pdf () {
  if (which ebook-convert 2>/dev/null); then
    echo "Converting to PDF using Calibre ebook-convert..."
    # try to use a Garamond font, otherwise just a Serif font
    SERIF_FONT=$(fc-list : family |grep "Garamond" |cut -d , -f 1 |head -1)
    if [ -z "$SERIF_FONT" ]; then
      SERIF_FONT=Serif
    fi
    (cd $OUTPUT_DIR && ebook-convert "$ARTIFACT" .pdf --paper-size a4 --pdf-page-numbers --pdf-serif-family "$SERIF_FONT" --pdf-standard-font serif)
  elif (which mutool 2>/dev/null); then
    echo "Converting to PDF using Mutool..."
    (cd $OUTPUT_DIR && mutool convert -o "$ARTIFACT_NAME.pdf" "$ARTIFACT")
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
      make_epub $OUTPUT_DIR
      to_mobi
      to_pdf
      ;;
    mobi)
      if [ ! -e "$OUTPUT_DIR/$ARTIFACT" ]; then
        make_epub $DIR "$OUTPUT_DIR/$ARTIFACT"
      fi
      to_mobi
      ;;
    pdf)
      if [ ! -e "$OUTPUT_DIR/$ARTIFACT" ]; then
        make_epub $DIR "$OUTPUT_DIR/$ARTIFACT"
      fi
      to_pdf
      ;;
    epub)
      minify_resources
      make_epub $OUTPUT_DIR
      ;;
    uncompressed_epub)
      make_epub $DIR "$OUTPUT_DIR/$ARTIFACT"
      ;;
    clean)
      clean
      ;;
    *)
      echo "Unrecognised build target: $BUILD_TARGET"
  esac
}

mkdir -p $OUTPUT_DIR
if [ $# -eq 0 ]; then
  make_target all
else
  for target in $@; do
    make_target "$target"
  done
fi
