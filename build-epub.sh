#!/bin/sh

ARTIFACT="Harry Potter and the Nightmares of Futures Past.epub"
DIR=`dirname $0`
WORKING_DIR="$DIR/OEBPS"
TMP_DIR="$DIR/OEBPS_tmp"
BACKUP_DIR="$DIR/OEBPS_orig"

cp -r $WORKING_DIR $TMP_DIR
for file in `ls $WORKING_DIR/*ml $WORKING_DIR/*.ncx $WORKING_DIR/*.opf`; do
  # collapse whitespace for efficiency
  sed 's|\s\s\s*| |g' "$file" | tr -d '\n' > `echo $file | sed "s|$WORKING_DIR/|$TMP_DIR/|"`
done
mv $WORKING_DIR $BACKUP_DIR
mv $TMP_DIR $WORKING_DIR
rm "$DIR/$ARTIFACT"
(cd $DIR && zip -X0 "$ARTIFACT" mimetype && zip -r "$ARTIFACT" META-INF OEBPS)
rm -r $WORKING_DIR
mv $BACKUP_DIR $WORKING_DIR
