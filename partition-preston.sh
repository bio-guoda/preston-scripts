#!/bin/bash
#
#  partition-preston.sh : Generates Internet Archive-friendly publication for Preston observatory. 
#
#  This script is not thoroughly tested, so please read it before running it.
#
set -xe

TMPDIR=$(mktemp -d -p $PWD/tmp)
cp $(which preston) $TMPDIR/preston.jar

preston verify --skip-hash-verification > $TMPDIR/verify.tsv

cat $TMP_DIR/verify.tsv | awk -F '\t' '{print $2 "\t" $1 "\t" $5 }' | sed 's+^.*data/+data/+g' | $TMP_DIR/files.tsv

cd $TMP_DIR
split --lines=90000 --numeric-suffixes files.tsv item 

gzip files.tsv

ls item0* -1 | parallel "cat {1} | sed s+^data+items/{1}+g" | gzip > files_split.tsv.gz

# create list of future dirs
zcat files_split.tsv.gz | awk -F '/' '{print $1 "/" $2 "/" $3 "/" $4}' | head | sort | uniq | gzip > files_split_dirs.tsv.gz

# make the directories
zcat files_split_dirs.tsv.gz | xargs -L1 mkdir -p 

paste <(zcat files.tsv.gz | cut -f1) <(zcat files_split.tsv.gz | cut -f1) | gzip > files_src_dst.tsv.gz


# create symlinks
zcat files_src_dst.tsv.gz | tr '\t' ' ' | pv -l | xargs -L1 ln -f -s

echo Internet Archive friendly Preston pub available in [$TMPDIR]
