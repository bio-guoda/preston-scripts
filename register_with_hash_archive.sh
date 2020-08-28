#!/bin/bash
# Register all preston urls and associated provenance logs with hash-archive.org
#
#
# usage: 
#   ./register_with_hash_archive.sh [number of recent provenance versions to register]
# 

#set -x

if [[ $1 -gt 0 ]]
then
  TAIL="tail -n$1"
else
  TAIL="cat"
fi

HOST_URL="https://deeplinker.bio"

PROV_HASHES=$(/usr/local/bin/preston history -l tsv | cut -f1,3 | tr '\t' '\n' | grep hash | $TAIL)

echo $PROV_HASHES | tr ' ' '\n' | sort | uniq | sed -e 's+hash://sha256+https://deeplinker.bio+g' | sed -e 's+^+https://hash-archive.org/api/enqueue/+g' | xargs -L1 curl 

echo $PROV_HASHES | tr ' ' '\n' | xargs -L1 /usr/local/bin/preston cat | grep Version | cut -d' ' -f3 | sed -E $'s/^<//' | sed -E $'s/[> .]*//' | grep -v "deeplinker\.bio/\.well-known/genid" | sort | uniq | sed -e 's+hash://sha256+https://deeplinker.bio+g' | sed -e 's+^+https://hash-archive.org/api/enqueue/+g' | xargs -L1 curl 
