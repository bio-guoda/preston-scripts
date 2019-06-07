#!/bin/bash
#
# Imports Preston data from https://deeplinker.bio into HDFS at hdfs://guoda/data/source=preston/data (for data) and hdfs://guoda/data/source=preston/prov (for data provenance).
#
# 
#

set -x

PRESTON_VERSION=0.0.12
wget https://github.com/bio-guoda/preston/releases/download/${PRESTON_VERSION}/preston.jar -O preston.jar

# list available dataset provenance graph, using deeplinker.bio as remote if needed.
java -jar preston.jar ls --remote https://deeplinker.bio/ > /dev/null

# verify existence and integrity of tracked content of biodiversity data graphs hosted by remote at deeplinker.bio 
# expected outcome is a list of all tracked content with status "missing", because the content is not expected two be local.
java -jar preston.jar verify --remote https://deeplinker.bio/ > verify.tsv

# copy preston provenance to prov directory
hdfs dfs -copyFromLocal -f data/ /guoda/data/source=preston/prov

# gather all preston tracked content
cat verify.tsv | sort | uniq > verify_sorted.tsv
cat verify_sorted.tsv | grep deeplinker > verify_sort_remote.tsv
cat verify_sorted.tsv | grep preston-archive > verify_sort_local.tsv
join verify_sort_remote.tsv verify_sort_local.tsv > verify_sort_remote_local.tsv 

# generate scripts to push preston tracked content into hdfs
cat verify_sort_remote_local.tsv | cut -d ' ' -f2,3 | sed -e "s/file:\/.*\/data\//| hdfs dfs -put -p - \/guoda\/data\/source=preston\/data\//g" | sed -e "s/https/curl https/g" > upload.sh
split upload.sh -n3 --additional-suffix=.sh -d upload
nohup bash upload00.sh &> upload00.log &
nohup bash upload01.sh &> upload01.log &
nohup bash upload02.sh &> upload02.log &
