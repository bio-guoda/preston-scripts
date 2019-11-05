#!/bin/bash
# Register https://archive.org/details/biodiversity-dataset-archives with hash-archive.org
#


function hash2ia {
  sed -e 's/hash:\/\/sha256\///g' | awk '{ print substr($1,1,2) "/" substr($1,3,2) "/" $1 }' | sed -e 's/^/https:\/\/archive.org\/download\/biodiversity-dataset-archives\/data.zip\/data\//g' | sed -e 's/^/https:\/\/hash-archive.org\/api\/enqueue\//g' | xargs -L1 curl
}

/usr/local/bin/preston history -l tsv | grep Version | cut -f1,3 | tr '\t' '\n' | grep -v "deeplinker\.bio/\.well-known/genid" | sort | uniq | grep "hash://sha256" | hash2ia 

/usr/local/bin/preston ls -l tsv | grep Version | cut -f1,3 | tr '\t' '\n' | grep -v "deeplinker\.bio/\.well-known/genid" | grep "hash://sha256" | head | sort | uniq | hash2ia 
