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

mkdir -p ../blob_suff
if cp -l blob ../blob_suff; then
	cd ../blob_suff
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
cp -l blob.APP ../system.ext4
cd ..

log "Building update.zip.."
mkdir -p update_zip/META-INF/com/google/android/
cp $BASE_DIR/update_res/updat* update_zip/META-INF/com/google/android/
mv system.ext4 update_zip/
cp -l repacked.blob update_zip/blob

OUTFILE="repacked-`basename $SOURCE .zip`-CWR-update.zip"
cd update_zip
zip -r -9 ../$OUTFILE .
echo

ls -lh `readlink -f ../$OUTFILE`
