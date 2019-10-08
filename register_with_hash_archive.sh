#!/bin/bash
# Register all preston urls and associated provenance logs with hash-archive.org
#

/usr/local/bin/preston history -l tsv | grep Version | cut -f1,3 | tr '\t' '\n' | grep -v "deeplinker\.bio/\.well-known/genid" | sort | uniq | sed -e 's/hash:\/\/sha256/https:\/\/deeplinker.bio/g' | sed -e 's/^/https:\/\/hash-archive.org\/api\/enqueue\//g' | xargs -L1 curl 

/usr/local/bin/preston ls -l tsv | grep Version | cut -f1,3 | tr '\t' '\n' | grep -v "deeplinker\.bio/\.well-known/genid" | sort | uniq | sed -e 's/hash:\/\/sha256/https:\/\/deeplinker.bio/g' | sed -e 's/^/https:\/\/hash-archive.org\/api\/enqueue\//g' | xargs -L1 curl 
