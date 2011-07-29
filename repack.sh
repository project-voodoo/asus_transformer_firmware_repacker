#!/bin/bash
#
# see README for details
#
# Copyright 2011 François SIMOND aka supercurio
#
# This program is free software. It comes without any warranty, to
# the extent permitted by applicable law. You can redistribute it
# and/or modify it under the terms of the Do What The Fuck You Want
# To Public License, Version 2, as published by Sam Hocevar. See
# http://sam.zoy.org/wtfpl/COPYING for more details.

BASE_DIR=`dirname $(readlink -f $0)`
TMP_DIR="$BASE_DIR/out"

log()
{
	echo -e "\n$1\n"
}

if test -n "$1" && test -f "$1" 2>/dev/null; then
	SOURCE=`readlink -f "$1"`
else
	log "Invalid source file ! ($1)"
	exit 1
fi

if test -n "$2" && test -d `dirname $2`; then
	OUTFILE="$2"
else
	OUTFILE="../repacked-`basename $SOURCE .zip`+root-CWR-update.zip"
fi

rm -r $TMP_DIR/* 2>/dev/null
mkdir -p $TMP_DIR/extraction
cd $TMP_DIR/extraction

log "First level zip extraction.."
unzip -x $SOURCE

if ! test -f blob; then
	log "2nd level zip extraction.."
	unzip -x ASUS/Update/*.zip
	rm -r ASUS/
fi

mkdir -p ../blob_stuff
if ln blob ../blob_stuff; then
	cd ../blob_stuff
else
	log "Missing blob!"
	exit 1
fi
log "Blob unpacking.."
blobunpack blob

log "Blob repacking.."
blobpack blob.HEADER ../repacked.blob \
	EBT blob.EBT \
	LNX blob.LNX \
	PT blob.PT
ln blob.APP ../system.ext4
cd ..

log "Building update.zip.."
cp -r $BASE_DIR/update_template/ update_zip/
mv system.ext4 update_zip/
ln repacked.blob update_zip/blob
for f in `ls $BASE_DIR/rooting/*`; do
	ln $f update_zip
done

cd update_zip
rm -f $OUTFILE
zip -r -9 $OUTFILE .
echo

ls -lh `readlink -f $OUTFILE`
